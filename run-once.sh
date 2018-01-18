#!/bin/bash
#
# Run this script once on your build hosts

echo "INFO: Getting new docker CLI"
git clone -b manifest-cmd https://github.com/clnperez/cli.git
make -f docker.Makefile cross
export PATH=${PATH}:$(pwd)/build

echo "INFO: You should add $(pwd)/build to your \$PATH"

echo "INFO: Registering handlers"
if [ $(uname -s) != "Darwin" ]; then
  docker run --rm --privileged multiarch/qemu-user-static:register
fi
