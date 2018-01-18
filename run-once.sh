#!/bin/bash
#
# Run this script once on your build hosts

if [ ! -x $(which docker) ]; then
  echo ERROR: No docker installer.
  exit 1
fi

echo "INFO: Getting new docker CLI"
if [ ! -d cli ]; then
  git clone -b manifest-cmd https://github.com/clnperez/cli.git
  cd cli
else
  cd cli
  git pull
fi
make -f docker.Makefile cross
export PATH=${PATH}:$(pwd)/build

echo "INFO: You should add $(pwd)/build to your \$PATH"

echo "INFO: Registering handlers"
if [ $(uname -s) != "Darwin" ]; then
  docker run --rm --privileged multiarch/qemu-user-static:register
fi
