# Volatility, on Docker 🐳

This repository hosts some ready-to-use Docker images based on [Alpine Linux](https://alpinelinux.org/) embedding the Volatility framework, including the newest Volatility 3 framework. Check out the official [Volatility](https://github.com/volatilityfoundation/volatility/) and [Volatility 3](https://github.com/volatilityfoundation/volatility3/) repositories for more information.

[Why are these images not (yet) official?](https://github.com/volatilityfoundation/volatility3/pull/92)

## Getting started

All images are directly available on Docker Hub:

<p align="center">
  <a href="https://hub.docker.com/r/sk4la/dwarf2json"><img alt="sk4la/dwarf2json" src="https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/dwarf2json?label=sk4la/dwarf2json&style=for-the-badge"/></a>
  <a href="https://hub.docker.com/r/sk4la/volatility"><img alt="sk4la/volatility" src="https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/volatility?label=sk4la/volatility&style=for-the-badge"/></a>
  <a href="https://hub.docker.com/r/sk4la/volatility3"><img alt="sk4la/volatility3" src="https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/volatility3?label=sk4la/volatility3&style=for-the-badge"/></a>
</p>

Building and/or using these images requires Docker to be installed on the system. Please refer to the [official documentation](https://docs.docker.com/) for more details on how to install and use the Docker toolchain.

> Be aware that debugging symbols for Volatility 3 are embedded into the images, which brings the size up for quite a bit. See [my pull request](https://github.com/volatilityfoundation/volatility3/pull/92) on the official repository for more details on this.

### Basic usage

Once the images have been pulled (or built), they can be instanciated inside fresh containers using `docker run`, for example:

```sh
docker run --volume $PWD:/case:ro sk4la/volatility3
```

Or a more complete example:

```sh
docker run --volume $PWD:/case:ro sk4la/volatility3 --file /case/volatile.mem windows.pslist.PsList
```

In order to use the Volatility shell (a.k.a. the [volshell](https://volatility3.readthedocs.io/en/latest/volshell.html)) or other entrypoints, use the `--entrypoint` option when instanciating the container:

```sh
docker run --entrypoint volshell --interactive --tty --volume $PWD:/case:ro sk4la/volatility3
```

> The `--interactive` and `--tty` options are needed in order to keep the terminal open while interacting with the containerized application.

Note that every artifact will be lost unless stored using a [volume](https://docs.docker.com/storage/volumes/) or [bind mount](https://docs.docker.com/storage/bind-mounts/) (as demonstrated here using the `--volume` option).

## Support

In case you encounter a problem or want to suggest a new feature, please [submit a ticket](https://github.com/sk4la/volatility3-docker/issues). [Pull requests](https://github.com/sk4la/volatility3-docker/pulls) are also greatly appreciated.

## License

This piece of software is licensed under the [Volatility Software License](https://www.volatilityfoundation.org/license/).
