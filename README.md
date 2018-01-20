# docker-multiarch-builder
Simple framework for building multi-arch images.

## Preparing your build machine

Run following commands on a host only once:
```bash
$ sudo ./run-once.sh
```

This will download necessary docker CLI binaries, put them in path and register necessary binfmt_misc handlers.

## Initializing your project

When you want to create your Docker project, run this first:

```bash
$ mkdir /usr/src/docker-project-name
$ ./init-repo.sh /usr/src/docker-project-name
```

This will download static qemu binaries into your project `qemu/` directory, prepare a stub of your Dockerfile.cross, and provide a local copy of your `build.sh` and `build.config` that you should use to build your images.

## Configuring build process

Build configuration is in `build.config` in your project directory. It has number of parameters:
- REPO - name of your hub.docker.com repository. You should already be logged in and have write access to this repository.
- IMAGE_NAME - image name that you would like to build. Probably your project name.
- IMAGE_VERSION - leave empty for "latest"
- DOCKER_CLI_PATH - path where docker CLI that supports manifest command is. You can leave it empty if you added it to path.
- TARGET_ARCHES - list of target architectures you would like to build.

Naturally, you should also edit your `Dockerfile.cross` and put meaningful build instructions. Just make sure __CROSS_COPY is placed before any RUN.

Keep `__BASEIMAGE_ARCH__`, `__CROSS_COPY` and `__QEMU_ARCH__` placeholder, as they are used to generate temporary Dockerfiles for each of the build architectures.

To actually build, tag images and push all of them + fat manifest to repository:
```
cd /usr/src/docker-project-name
./build.sh
```
(NOTE: You need to be logged in to the repository)
