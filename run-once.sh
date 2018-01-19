#!/bin/bash
#
# Run this script once on your build hosts

set -e

if [[ ! $(type -P docker) ]]; then
  echo ERROR: No docker installer. 1>&2
  exit 1
fi

if [[ ! $(type -P make) ]]; then
  echo ERROR: No docker installer. 1>&2
  exit 1
fi


echo "INFO: Getting new docker CLI"
if [ ! -d cli ]; then
  git clone -b manifest-cmd https://github.com/clnperez/cli.git || \
    echo ERROR: Could not clone the repository 1>&2 &&
  cd cli
else
  cd cli
  git pull
fi
make -f docker.Makefile cross

export PATH=${PATH}:$(pwd)/build
echo "INFO: You should permanently add $(pwd)/build to your \$PATH"
echo "$ echo export PATH=${PATH}:$(pwd)/build >> ~/.profile"

if [ $(uname -s) != "Darwin" ]; then
  echo "INFO: Registering handlers - requires sudo!"
  sudo docker run --rm --privileged multiarch/qemu-user-static:register
fi
