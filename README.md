# Volatility, on Docker 🐳

This repository hosts some ready-to-use Docker images based on [Alpine Linux](https://alpinelinux.org/) embedding the Volatility framework, including the newest Volatility 3 framework. Check out the official [Volatility](https://github.com/volatilityfoundation/volatility/) and [Volatility 3](https://github.com/volatilityfoundation/volatility3/) repositories for more information.

All images are directly available on Docker Hub:

<p align="center">
  <a href="https://hub.docker.com/r/sk4la/dwarf2json"><img alt="sk4la/dwarf2json" src="https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/dwarf2json?label=sk4la/dwarf2json&style=for-the-badge"/></a>
  <a href="https://hub.docker.com/r/sk4la/volatility"><img alt="sk4la/volatility" src="https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/volatility?label=sk4la/volatility&style=for-the-badge"/></a>
  <a href="https://hub.docker.com/r/sk4la/volatility3"><img alt="sk4la/volatility3" src="https://img.shields.io/github/workflow/status/sk4la/volatility3-docker/volatility3?label=sk4la/volatility3&style=for-the-badge"/></a>
</p>

By the way, [why are these images not (yet) official?](https://github.com/volatilityfoundation/volatility3/pull/92)

## Getting started

Building and/or using these images requires Docker to be installed on the system. Please refer to the [official documentation](https://docs.docker.com/) for more details on how to install and use the Docker toolchain.

### Building the images

As these images are built using GitHub Actions, the steps for building them are not explicitly documented here. Please refer directly to [the CI workflows](https://github.com/sk4la/volatility3-docker/tree/master/.github/workflows) if you wish to build them locally.

> :warning: Be aware that [symbol packs](https://github.com/volatilityfoundation/volatility3#symbol-tables) for Volatility 3 are directly embedded into the `sk4la/volatility3` image, which brings the size up for quite a bit. See [my pull request](https://github.com/volatilityfoundation/volatility3/pull/92) on the official repository for more details on this.

### Basic usage

Once the images have been pulled (or built), they can be instantiated inside fresh containers using `docker run`, for example:

```sh
docker run -v $PWD:/workspace sk4la/volatility3
```

Or a more complete example:

```sh
docker run -v $PWD:/workspace sk4la/volatility3 -f /workspace/volatile.mem windows.pslist
```

In order to use the Volatility shell (a.k.a. the [volshell](https://volatility3.readthedocs.io/en/latest/volshell.html)) or other entrypoints, use the `--entrypoint` option when instantiating the container:

```sh
docker run -i -t -v $PWD:/workspace --entrypoint volshell sk4la/volatility3
```

> The `--interactive` and `--tty` options (or their short versions, respectively `-i` and `-t`) are needed in order to keep the terminal open while interacting with the containerized application.

Note that every produced artifact will be lost unless stored using a [volume](https://docs.docker.com/storage/volumes/) or [bind mount](https://docs.docker.com/storage/bind-mounts/) (as demonstrated here using the `--volume` option).

> As determining the correct memory layout usually takes a bit of time, running Volatility interactively (i.e. instantiating the container using the `--interactive` flag) is preferred, although retrieving the configuration file using a volume is also possible. See the [examples](#examples) for practical use cases.

## Examples

These images can be used either interactively or as a throwaway solution for punctual problematics.

<details>
  <summary>Example #1: Interactive session using Volatility3 command-line interface (CLI)</summary>

### Example #1: Interactive session using Volatility3 command-line interface (CLI)

The following is a practical example of using Volatility 3 (and more precisely the `sk4la/volatility3` Docker image) to dump a process executable from a volatile memory image.

> :bulb: Long options are used here on purpose. For more details on the Docker CLI, please refer to [the official documentation](https://docs.docker.com/engine/reference/commandline/cli/).

First, begin by instantiating a new container based on the `sk4la/volatility3` image:

```sh
docker container run \
    --entrypoint ash \
    --init \
    --interactive \
    --tty \
    --volume "$PWD:/home/unprivileged/workspace" \
    --workdir /home/unprivileged/workspace \
    sk4la/volatility3
```

Then, inside the newly-created container, use Volatility 3 to parse the memory image and write the configuration to disk:

```sh
volatility3 \
    --file volatile.mem \
    --log volatile.mem.log \
    --renderer pretty \
    --write-config \
    windows.info
```

The configuration file `config.json` should reside in the current directory. This configuration can then be used as a basis for the upcoming runs using the `--config` flag—so that Volatility no longer has to crawl the image to find the right structures.

Next, extract the list of processes by executing Volatility 3 again using the previously generated configuration:

```sh
volatility3 \
    --config config.json \
    --file volatile.mem \
    --log volatile.mem.log \
    --renderer pretty \
    windows.pslist
```

For post-processing, it is usually easier to dump the results in CSV or JSON format:

```sh
mkdir volatile.mem.results

volatility3 \
    --config config.json \
    --file volatile.mem \
    --log volatile.mem.log \
    --quiet \
    --renderer csv \
    windows.pslist \
    | tee -a volatile.mem.results/pslist.csv
```

The file `~/workspace/volatile.mem.results/pslist.csv` should contain the CSV-formatted results of the `windows.pslist.PsList` plugin.

For dumping a process image, first create a directory that will contain all future extractions, then execute Volatility again using the same `windows.pslist.PsList` plugin, but this time adding the `--dump` flag:

```sh
mkdir volatile.mem.dat

volatility3 \
    --config config.json \
    --file volatile.mem \
    --log volatile.mem.log \
    --output-dir volatile.mem.dat \
    --renderer pretty \
    windows.pslist \
        --dump \
        --pid 2700
```

The binary sample should reside in the `~/workspace/volatile.mem.dat` directory, ready to be analyzed by a reverse engineer.

Actually, all _dumper_ plugins (i.e. a Volatility plugin that is able to dump raw content from the memory image) should support the `--output-dir` option, which is quite convenient in an analysis workflow.

> Volatility is verbose but not necessarily precise when it comes to errors. When an error is raised, you should always increase the verbosity level (using `-vvv` for example) in order to get maximum details about what is going on, and eventually submit an issue on [the official Volatility 3 repository](https://github.com/volatilityfoundation/volatility3/issues) if you deem it necessary.

</details>

<details>
  <summary>Example #2: Generate an ISF file for a specific NT kernel build using <tt>pdbconv</tt></summary>

### Example #2: Generate an ISF file for a specific NT kernel build using `pdbconv`

This is very straighforward, simply instanciate a new container based on the `sk4la/volatility3` image using the `pdbconv` entrypoint:

```sh
docker container run \
    --entrypoint pdbconv \
    --init \
    --volume "$PWD:/home/unprivileged/workspace" \
    --workdir /home/unprivileged/workspace \
    sk4la/volatility3 --guid ce7ffb00c20b87500211456b3e905c471 --keep --pattern ntkrnlmp.pdb
```

This will generate the [Intermediate Symbol File (ISF) file](https://volatility3.readthedocs.io/en/latest/symbol-tables.html) `ce7ffb00c20b87500211456b3e905c47-1.json.xz` in the current working directory, which will hint Volatility at how to handle this specific build in order to retrieve the information.

> Note that this will fetch the correct PDB file from the official [Microsoft Internet Symbol Server](https://msdl.microsoft.com/download/symbols) so this method will not work in air-gapped environments. See the [JPCERTCC repository](https://github.com/JPCERTCC/Windows-Symbol-Tables) and [blog post](https://blogs.jpcert.or.jp/en/2021/09/volatility3_offline.html) for more details on how to retrieve the GUID from your own binaries and use Volatility 3 in air-gapped environments.

The ISF file must then be placed either in the main symbols directory (located at `$INSTALL_PREFIX/lib/volatility3/volatility3/symbols/windows` by default) or in the current working directory, under the `symbols` subdirectory (e.g. `./symbols/windows/ntkrnlmp.pdb/ce7ffb00c20b87500211456b3e905c47-1.json.xz`). You can also use the `--symbol-dirs` option in addition to Docker's `--volume` option in order to provide the newly-created ISF files to Volatility.

</details>

## Support

In case you encounter a problem or want to suggest a new feature relative to these Docker images, please [submit a ticket](https://github.com/sk4la/volatility3-docker/issues). [Pull requests](https://github.com/sk4la/volatility3-docker/pulls) are also greatly appreciated.

## License

This piece of software is licensed under the [Volatility Software License](https://www.volatilityfoundation.org/license/).
