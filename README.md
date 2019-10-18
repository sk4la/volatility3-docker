# Volatility 3 framework on Docker

This repository hosts some ready-to-use Docker images embedding the newest Volatility 3 framework. Check the [official Volatility repository](https://github.com/volatilityfoundation/volatility3/) for more information.

These images are based on the [Alpine Linux](https://alpinelinux.org/) distribution.

## Getting Started

Follow these steps to get a copy of the project up and running.

### Prerequisites

Using these images requires Docker to be installed on the system. Please refer to the [online documentation](https://docs.docker.com/) for more details on how to install the Docker toolchain.

### Building

Building the complete lab is as simple as:

```sh
$ git clone https://github.com/sk4la/volatility3-docker.git
$ make -C volatility3-docker
```

Note that these images are somewhat heavy (~2GB) since they embed some of the kernel [debug symbols](https://en.wikipedia.org/wiki/Debug_symbol/) for GNU/Linux, macOS and Microsoft Windows.

> These images are also available on the [Docker Hub](https://hub.docker.com/u/sk4la/).

### Usage

Once the images have been built, they can be instanciated inside fresh containers using:

```sh
$ docker run -v "${PWD}:/case" --rm --cap-drop=ALL sk4la/volatility
$ docker run -v "${PWD}:/case" --rm --cap-drop=ALL -it sk4la/volshell
$ docker run -v "${PWD}:/case" --rm --cap-drop=ALL sk4la/pdb2json
```

Note that every artifact will be lost unless stored through the [bound volume](https://docs.docker.com/storage/bind-mounts/).

### Environment variables

Customizing the build is allowed through several environment variables:

* `DEF_ALPINE_VERSION` (defaults to `3.10`)
* `DEF_INSTALL_PREFIX` (defaults to `/usr`)
* `DEF_USERNAME` (defaults to `root`)

## Versioning

Please refer to the current Git repository to retrieve the latest version of the project.

## Copyright & Licensing

This piece of software is distributed "as is" and without any warranty whatsoever.
