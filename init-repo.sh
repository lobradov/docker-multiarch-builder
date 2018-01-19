#!/bin/bash
#
# Run this to prepare and initialize new Docker image build repo

if [[ -f build.config ]]; then
  source ./build.config
fi

# Fail on empty params

# -----
set -e

if [ $(uname -m) != "x86_64"]; then
  echo ERROR: This script is really used for building Docker images on x86_64 machines.
  exit 1
fi

if [ $(uname -s) != "Linux" ]; then
  mkdir qemu
  cd qemu
  for target_arch in ${BUILD_ARCHS}; do
    wget -N https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/x86_64_qemu-${target_arch}-static.tar.gz
    tar -xvf x86_64_qemu-${target_arch}-static.tar.gz
    rm x86_64_qemu-${target_arch}-static.tar.gz
  done
  cd ..
fi

cat << EOF > Dockerfile.cross
FROM __BASEIMAGE_ARCH__/!!!image

__CROSS_COPY qemu/qemu-__QEMU_ARCH__-static /usr/bin/
EOF
