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
fi

if [[ $(uname -m) != "x86_64" ]]; then
  echo ERROR: This script is really used for building Docker images on x86_64 machines.
  exit 1
fi

if [[ $(uname -s) != "Darwin" ]]; then
  mkdir $1/qemu
  cd qemu
  for target_arch in ${BUILD_ARCHS}; do
    wget -N -P $1 https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/x86_64_qemu-${target_arch}-static.tar.gz
    tar -xvf $1/x86_64_qemu-${target_arch}-static.tar.gz -C $1/qemu
    rm $1/x86_64_qemu-${target_arch}-static.tar.gz
  done
else
  echo INFO: Running on Mac, skipping Qemu build.
fi

if [[ ! -f  $1/Dockerfile.cross ]]; then
cat << EOF > $1/Dockerfile.cross
FROM __BASEIMAGE_ARCH__/alpine:latest

__CROSS_COPY qemu/qemu-__QEMU_ARCH__-static /usr/bin/
EOF
else
  echo INFO: Dockerfile.cross already exists, skipping
fi
cp build.sh $1
if [[ ! -f $1/build.config ]]; then
  cp build.config $1
fi
