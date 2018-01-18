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
$ cd <your_project_folder>
$ ../<path_to_multiarch_builder>/init-repo.sh
```

This will download static qemu binaries and prepare a stub of your Dockerfile.cross that you should use. 

## Building your docker images
