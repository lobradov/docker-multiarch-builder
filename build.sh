#!/bin/bash
#
# Run this to build, tag and create fat-manifest for your images


set -e

if [[ -f build.config ]]; then
  source ./build.config
else
  echo ERROR: ./build.config not found.
  exit 1
fi

# Fail on empty params
if [[ -z ${REPO} || -z ${IMAGE_NAME} || -z ${TARGET_ARCHES} ]]; then
  echo ERROR: Please set build parameters.
  exit 1
fi

# Determine OS and Arch.
build_os=$(uname -s | tr '[:upper:]' '[:lower:]' )
build_uname_arch=$(uname -m | tr '[:upper:]' '[:lower:]' )

case ${build_uname_arch} in
  x86_64  ) build_arch=amd64 ;;
  aarch64 ) build_arch=arm ;;
  arm*    ) build_arch=arm ;;
  *)
    echo ERROR: Sorry, unsuppoted architecture ${native_arch};
    exit 1
    ;;
esac

echo INFO: Looing for docker-${build_os}-${build_arch} in PATH and in ${DOCKER_CLI_PATH%/}
docker_bin_path=$( type -P docker-${build_os}-${build_arch} ${DOCKER_CLI_PATH%/}/docker-${build_os}-${build_arch})

if [[ ! -x ${docker_bin_path} ]]; then
  echo ERROR: Missing Docker CLI with manifest command \(docker_bin_path: ${docker_bin_path}\)
  exit 1
fi

if [[ -z ${IMAGE_VERSION} ]]; then
  IMAGE_VERSION="latest"
fi

for docker_arch in ${TARGET_ARCHES}; do
  case ${docker_arch} in
    amd64       ) qemu_arch="x86_64" ;;
    arm32v[6-7] ) qemu_arch="arm" ;;
    arm64v8     ) qemu_arch="aarch64" ;;
    *)
      echo ERROR: Unknown target arch.
      exit 1
  esac
  cp Dockerfile.cross Dockerfile.${docker_arch}
  sed -i "" "s|__BASEIMAGE_ARCH__|${docker_arch}|g" Dockerfile.${docker_arch}
  sed -i "" "s|__QEMU_ARCH__|${qemu_arch}|g" Dockerfile.${docker_arch}
  if [[ ${docker_arch} == "amd64" || ${build_os} == "darwin" ]]; then
    sed -i "" "/__CROSS_/d" Dockerfile.${docker_arch}
  else
    sed -i "" "s/__CROSS_//g" Dockerfile.${docker_arch}
  fi
  ${docker_bin_path} build -f Dockerfile.${docker_arch} -t ${REPO}/${IMAGE_NAME}:${docker_arch}-${IMAGE_VERSION} .
  ${docker_bin_path} push ${REPO}/${IMAGE_NAME}:${docker_arch}-${IMAGE_VERSION}
  arch_images="${arch_images} ${REPO}/${IMAGE_NAME}:${docker_arch}-${IMAGE_VERSION}"
  rm Dockerfile.${docker_arch}
done

echo INFO: Creating fat manifest for ${REPO}/${IMAGE_NAME}:${IMAGE_VERSION}
echo INFO: with subimages: ${arch_images}
${docker_bin_path} manifest create --amend ${REPO}/${IMAGE_NAME}:${IMAGE_VERSION} ${arch_images}
for docker_arch in ${TARGET_ARCHES}; do
  case ${docker_arch} in
    amd64       ) annotate_flags="" ;;
    arm32v[6-7] ) annotate_flags="--os linux --arch arm" ;;
    arm64v8     ) annotate_flags="--os linux --arch arm64 --variant armv8" ;;
  esac
  echo INFO: Annotating arch: ${docker_arch} with \"${annotate_flags}\"
  ${docker_bin_path} manifest annotate ${REPO}/${IMAGE_NAME}:${IMAGE_VERSION} ${REPO}/${IMAGE_NAME}:${docker_arch}-${IMAGE_VERSION} ${annotate_flags}
done
echo INFO: Pushing ${REPO}/${IMAGE_NAME}:${IMAGE_VERSION}
${docker_bin_path} manifest push ${REPO}/${IMAGE_NAME}:${IMAGE_VERSION}
