# Volatility, on Docker 🐳

This repository hosts some ready-to-use Docker images based on [Alpine Linux](https://alpinelinux.org/) embedding the newest Volatility 3 framework. Check out the [official Volatility 3 repository](https://github.com/volatilityfoundation/volatility3/) for more information.

[Why are these images not (yet) official?](https://github.com/volatilityfoundation/volatility3/pull/92)

> Be aware that debugging symbols are directly embedded into the images, which brings the size up for quite a bit. See [my pull request](https://github.com/volatilityfoundation/volatility3/pull/92) on the official repository for more details on this.

## Table of contents

- [Getting started](#getting-started)
  - [Basic usage](#basic-usage)
- [Support](#support)
- [License](#license)

## Getting started

All images are available of Docker Hub:

- [`sk4la/dwarf2json`](https://hub.docker.com/repository/docker/sk4la/dwarf2json)
- [`sk4la/volatility3`](https://hub.docker.com/repository/docker/sk4la/volatility3)
- [`sk4la/pdbconv`](https://hub.docker.com/repository/docker/sk4la/pdbconv) (only for backward compatibility, please consider `--entrypoint=pdbconv` from now on)
- [`sk4la/volatility`](https://hub.docker.com/repository/docker/sk4la/volatility) (only for backward compatibility, moved to `sk4la/volatility3` for better coherence)
- [`sk4la/volshell`](https://hub.docker.com/repository/docker/sk4la/volshell) (only for backward compatibility, please consider `--entrypoint=volshell` from now on)

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

This piece of software is licensed under the [​Volatility Software License](https://www.volatilityfoundation.org/license/).
