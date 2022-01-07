# Volatility, on Docker 🐳

This repository hosts some ready-to-use Docker images based on [Alpine Linux](https://alpinelinux.org/) embedding the Volatility framework, including the newest Volatility 3 framework. Check out the official [Volatility](https://github.com/volatilityfoundation/volatility/) and [Volatility 3](https://github.com/volatilityfoundation/volatility3/) repositories for more information.

[Why are these images not (yet) official?](https://github.com/volatilityfoundation/volatility3/pull/92)

> Be aware that debugging symbols for Volatility 3 are directly embedded into the images, which brings the size up for quite a bit. See [my pull request](https://github.com/volatilityfoundation/volatility3/pull/92) on the official repository for more details on this.

## Table of contents

- [Getting started](#getting-started)
  - [Basic usage](#basic-usage)
- [Support](#support)
- [License](#license)

## Getting started

All images are available on Docker Hub:

- [![`sk4la/volatility3:edge`](https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/volatility3-edge?label=sk4la/volatility3:edge&style=flat-square)](https://hub.docker.com/r/sk4la/volatility3) (newest addition for Volatility3 v2.0.0 preview! 🔥)
- [![`sk4la/volatility3:stable`](https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/volatility3-stable?label=sk4la/volatility3:stable&style=flat-square)](https://hub.docker.com/r/sk4la/volatility3)
- [![`sk4la/dwarf2json:stable`](https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/dwarf2json-stable?label=sk4la/dwarf2json:stable&style=flat-square)](https://hub.docker.com/r/sk4la/dwarf2json)

The following are old images that are only here for backward compatibility (you should not use these):

- [`sk4la/volatility`](https://hub.docker.com/repository/docker/sk4la/volatility): moved to `sk4la/volatility3` for coherence with the Volatility naming convention
- [`sk4la/volshell`](https://hub.docker.com/repository/docker/sk4la/volshell): replaced by `sk4la/volatility3` with `--entrypoint volshell`
- [`sk4la/pdbconv`](https://hub.docker.com/repository/docker/sk4la/pdbconv): replaced by `sk4la/volatility3` with `--entrypoint pdbconv`

Building and/or using these images requires Docker to be installed on the system. Please refer to the [official documentation](https://docs.docker.com/) for more details on how to install the Docker toolchain.

Pulling an image locally is as simple as:

```sh
docker pull sk4la/volatility3
```

### Basic usage

Once the images have been pulled (or built), they can be instanciated inside fresh containers using:

```sh
docker run -v $PWD:/workspace sk4la/dwarf2json
docker run -v $PWD:/workspace sk4la/volatility3
docker run -v $PWD:/workspace --entrypoint volshell -it sk4la/volatility3
docker run -v $PWD:/workspace --entrypoint pdbconv sk4la/volatility3
```

> Note that every artifact will be lost unless stored using a [volume](https://docs.docker.com/storage/volumes/) or [bind mount](https://docs.docker.com/storage/bind-mounts/).

## Support

In case you encounter a problem or want to suggest a new feature, please [submit a ticket](https://github.com/sk4la/volatility3-docker/issues). [Pull requests](https://github.com/sk4la/volatility3-docker/pulls) are also greatly appreciated.

## License

This piece of software is licensed under the [Volatility Software License](https://www.volatilityfoundation.org/license/).
