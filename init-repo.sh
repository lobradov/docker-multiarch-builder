#!/bin/bash
#
# Run this to prepare and initialize new Docker image build repo

QEMU_VERSION="v2.9.1-1"
BUILD_ARCHS="x86_64 aarch64 arm"

# -----
set -e

ABS_FROM="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d $1 && ! -w $1 ]]; then
  echo ERROR: Please supply a valid, writeable directory path.
  echo ERROR: for example:
  echo ERROR: $0 /usr/src/docker-something
  exit 1
fi

ABS_DEST="$(cd $1 && pwd)"
echo INFO: Setting up ${ABS_DEST} from ${ABS_FROM}
if [[ $(uname -m) != "x86_64" ]]; then
  echo ERROR: This script is really used for building Docker images on x86_64 machines.
  exit 1
fi

if [[ $(uname -s) != "Darwin" ]]; then
  mkdir -p ${ABS_DEST}/qemu ${ABS_FROM}/qemu
  for target_arch in ${BUILD_ARCHS}; do
    [[ -f ${ABS_FROM}/qemu/x86_64_qemu-${target_arch}-static.tar.gz ]] || wget -N -P ${ABS_FROM}/qemu https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/x86_64_qemu-${target_arch}-static.tar.gz
    tar -xvf ${ABS_FROM}/qemu/x86_64_qemu-${target_arch}-static.tar.gz -C ${ABS_DEST}
  done
else
  echo INFO: Running on Mac, skipping Qemu build.
fi

if [[ ! -f  ${ABS_DEST}/Dockerfile.cross ]]; then
cat << EOF > ${ABS_DEST}/Dockerfile.cross
FROM __BASEIMAGE_ARCH__/alpine:latest

__CROSS_COPY qemu/qemu-__QEMU_ARCH__-static /usr/bin/
EOF
else
  echo INFO: Dockerfile.cross already exists, skipping
fi
cp ${ABS_FROM}/build.sh ${ABS_DEST}
if [[ ! -f ${ABS_DEST}/build.config ]]; then
  cp ${ABS_FROM}/build.config ${ABS_DEST}
fi

[[ $(fgrep -c "build.sh" ${ABS_DEST}/.gitignore) -eq 0 ]] && echo "build.sh" >> ${ABS_DEST}/.gitignore
[[ $(fgrep -c "build.config" ${ABS_DEST}/.gitignore) -eq 0 ]] && echo "build.config" >> ${ABS_DEST}/.gitignore
