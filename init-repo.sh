#!/bin/bash
#
# Run this to prepare and initialize new Docker image build repo

QEMU_VERSION="v2.9.1-1"
BUILD_ARCHS="x86_64 aarch64 arm"

# -----
set -e

if [[ ! -d $1 && ! -w $1 ]]; then
  echo ERROR: Please supply a valid, writeable directory path.
  echo ERROR: for example:
  echo ERROR: $0 /usr/src/docker-something
  exit 1
fi
cd $1
ABS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

if [[ $(uname -m) != "x86_64" ]]; then
  echo ERROR: This script is really used for building Docker images on x86_64 machines.
  exit 1
fi

if [[ $(uname -s) != "Darwin" ]]; then
  mkdir ${ABS_ROOT}/qemu
  cd ${ABS_ROOT}/qemu
  for target_arch in ${BUILD_ARCHS}; do
    wget -N https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/x86_64_qemu-${target_arch}-static.tar.gz
    tar -xvf x86_64_qemu-${target_arch}-static.tar.gz
    rm $1/x86_64_qemu-${target_arch}-static.tar.gz
  done
  cd ${ABS_ROOT}
else
  echo INFO: Running on Mac, skipping Qemu build.
fi

if [[ ! -f  ${ABS_ROOT}/Dockerfile.cross ]]; then
cat << EOF > ${ABS_ROOT}/Dockerfile.cross
FROM __BASEIMAGE_ARCH__/alpine:latest

__CROSS_COPY qemu/qemu-__QEMU_ARCH__-static /usr/bin/
EOF
else
  echo INFO: Dockerfile.cross already exists, skipping
fi
cp build.sh ${ABS_ROOT}
if [[ ! -f ${ABS_ROOT}/build.config ]]; then
  cp build.config ${ABS_ROOT}
fi

echo "build.sh" >> ${ABS_ROOT}/.gitignore
echo "build.config" >> ${ABS_ROOT}/.gitignore
