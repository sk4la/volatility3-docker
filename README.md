# Volatility 3, on Docker 🐳

This repository hosts some ready-to-use Docker images based on [Alpine Linux](https://alpinelinux.org/) embedding the newest Volatility 3 framework. Check out the [official Volatility 3 repository](https://github.com/volatilityfoundation/volatility3/) for more information.

Hmm, [why are these images not (yet) official?](https://github.com/volatilityfoundation/volatility3/pull/92)

> Be aware that debugging symbols are directly embedded into the images, which brings the size up for quite a bit. See [my pull request](https://github.com/volatilityfoundation/volatility3/pull/92) on the official repository for more details on this.

## Table of contents

- [Getting started](#getting-started)
  - [Basic usage](#basic-usage)
- [Advanced usage](#advanced-usage)
  - [Requirements](#requirements)
  - [Building the images](#building-the-images)
  - [Customization](#customization)
- [Support](#support)
- [License](#license)

## Getting started

All images are available of Docker Hub:

- [`sk4la/dwarf2json`](https://hub.docker.com/repository/docker/sk4la/dwarf2json)
- [`sk4la/pdbconv`](https://hub.docker.com/repository/docker/sk4la/pdbconv)
- [`sk4la/volatility`](https://hub.docker.com/repository/docker/sk4la/volatility)
- [`sk4la/volshell`](https://hub.docker.com/repository/docker/sk4la/volshell)

Pulling an image locally is as simple as:

```sh
docker pull sk4la/volatility
```

### Basic usage

Once the images have been pulled (or built), they can be instanciated inside fresh containers using:

```sh
docker run -v $PWD:/case --rm sk4la/dwarf2json
docker run -v $PWD:/case --rm sk4la/pdbconv
docker run -v $PWD:/case --rm sk4la/volatility
docker run -v $PWD:/case --rm -it sk4la/volshell
```

> Note that every artifact will be lost unless stored using a [volume](https://docs.docker.com/storage/volumes/) or [bind mount](https://docs.docker.com/storage/bind-mounts/).

## Advanced usage

### Requirements

Building and/or using these images requires Docker to be installed on the system. Please refer to the [official documentation](https://docs.docker.com/) for more details on how to install the Docker toolchain.

### Building the images

Building the complete lab is as simple as:

```sh
git clone https://github.com/sk4la/volatility3-docker.git && make -C volatility3-docker
```

> Note that these images are somewhat heavy (~2GB) since they embed some of the kernel [debug symbols](https://en.wikipedia.org/wiki/Debug_symbol/) for GNU/Linux, macOS and Microsoft Windows.

### Customization

Customizing the build is allowed through several environment variables:

- `ALPINE_VERSION` (defaults to `3.15`)
- `INSTALL_PREFIX` (defaults to `/usr`)
- `INSTALL_USER` (defaults to `root`)

## Support

In case you encounter a problem or want to suggest a new feature, please [submit a ticket](https://github.com/sk4la/volatility3-docker/issues). [Pull requests](https://github.com/sk4la/volatility3-docker/pulls) are also greatly appreciated.

## License

This piece of software is licensed under the [MIT License](https://github.com/sk4la/volatility3-docker/blob/master/LICENSE).
