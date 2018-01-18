#!/bin/bash
#
# Run this script once on your build hosts

if [[ ${EUID} -ne 0 ]]; then
  echo ERROR: This script should be run as root. 1>&2
  exit 1
fi

if [[ ! $(type -P docker) ]]; then
  echo ERROR: No docker installer. 1>&2
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

echo "INFO: You should permanently add $(pwd)/build to your \$PATH"

echo "INFO: Registering handlers"
if [ $(uname -s) != "Darwin" ]; then
  docker run --rm --privileged multiarch/qemu-user-static:register
fi
