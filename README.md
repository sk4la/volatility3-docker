# Volatility, on Docker 🐳

This repository hosts some ready-to-use Docker images based on [Alpine Linux](https://alpinelinux.org/) embedding the Volatility framework, including the newest Volatility 3 framework. Check out the official [Volatility](https://github.com/volatilityfoundation/volatility/) and [Volatility 3](https://github.com/volatilityfoundation/volatility3/) repositories for more information.

All images are directly available on Docker Hub:

<p align="center">
  <a href="https://hub.docker.com/r/sk4la/volatility3"><img alt="sk4la/volatility3" src="https://img.shields.io/github/actions/workflow/status/sk4la/volatility3-docker/volatility3.yml?branch=master&label=sk4la/volatility3&style=for-the-badge&logo=docker&logoColor=white"/></a>
  <a href="https://hub.docker.com/r/sk4la/volatility"><img alt="sk4la/volatility" src="https://img.shields.io/github/actions/workflow/status/sk4la/volatility3-docker/volatility-edge.yml?branch=master&label=sk4la/volatility&style=for-the-badge&logo=docker&logoColor=white"/></a>
  <a href="https://hub.docker.com/r/sk4la/dwarf2json"><img alt="sk4la/dwarf2json" src="https://img.shields.io/github/actions/workflow/status/sk4la/volatility3-docker/dwarf2json-edge.yml?branch=master&label=sk4la/dwarf2json&style=for-the-badge&logo=docker&logoColor=white"/></a>
</p>

By the way, [why are these images not (yet) official?](https://github.com/volatilityfoundation/volatility3/pull/92)

## What's in the box?

- [`sk4la/volatility3`](https://hub.docker.com/r/sk4la/volatility) ⭐ (version [2.5.0](https://github.com/volatilityfoundation/volatility3/releases/tag/v2.5.0) from September 27, 2023)
  - The latest release of the official [Volatility 3](https://github.com/volatilityfoundation/volatility3) project
  - The [community-maintained plugins](https://github.com/volatilityfoundation/community3) for Volatility 3
  - The [official symbol tables](https://github.com/volatilityfoundation/volatility3#symbol-tables) for Windows, macOS and GNU/Linux provided by the Volatility Foundation
  - The [symbol tables](https://github.com/JPCERTCC/Windows-Symbol-Tables) provided by the [JPCERT/CC](https://www.jpcert.or.jp/) for the ongoing Windows 11+ support

> The `latest` and `stable` tags, as well as the literal version number (e.g `2.5.0`) all point to the [latest official release](https://github.com/volatilityfoundation/volatility3/releases). In order to follow the development cycle of Volatility 3, an `edge` tag has been added, which points to the current state of the `master` branch—which could be unstable. Power-users should feel free to use this one at their own expense. The `sk4la/volatility3` and `sk4la/volatility3:edge` images are built every week in order to include the newest symbols.

- [`sk4la/volatility`](https://hub.docker.com/r/sk4la/volatility)
  - The latest release of the official [Volatility](https://github.com/volatilityfoundation/volatility) project (unmaintained since 2020)
  - The [community-maintained plugins](https://github.com/volatilityfoundation/community) for Volatility

- [`sk4la/dwarf2json`](https://hub.docker.com/r/sk4la/dwarf2json)
  - The official [dwarf2json](https://github.com/volatilityfoundation/dwarf2json) project

Please [let me know](#support) if there is anything missing or if you would like to see something else added to the mix.

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
docker run -it -v $PWD:/workspace --entrypoint volshell sk4la/volatility3 -f /workspace/volatile.mem
```

> The `--interactive` and `--tty` options (or their short versions, respectively `-i` and `-t`) are needed in order to keep the terminal open while interacting with the containerized application.

Note that every produced artifact will be lost unless stored using a [volume](https://docs.docker.com/storage/volumes/) or [bind mount](https://docs.docker.com/storage/bind-mounts/) (as demonstrated here using the `--volume` option).

> As determining the correct memory layout usually takes a bit of time, running Volatility interactively (i.e. instantiating the container using the `--interactive` flag) is preferred, although retrieving the configuration file using a volume is also possible. See the [examples](#examples) for practical use cases.

## Examples

These images can be used either interactively or as a throwaway solution for punctual issues.

<details>
  <summary>Example #1: Interactive session using Volatility3 command-line interface (CLI)</summary>

### Example #1: Interactive session using Volatility3 command-line interface (CLI)

The following is a practical example of using Volatility 3 (and more precisely the `sk4la/volatility3` Docker image) to dump a process executable from a volatile memory image.

> :bulb: Long options are used here on purpose. For more details on the Docker CLI, please refer to [the official documentation](https://docs.docker.com/engine/reference/commandline/cli/).

First, begin by instantiating a new container based on the `sk4la/volatility3` image:

```sh
docker container run --entrypoint ash --interactive --tty --volume "$PWD:/home/unprivileged/workspace" --workdir /home/unprivileged/workspace sk4la/volatility3
```

Then, inside the newly-created container, use Volatility 3 to parse the memory image and write the configuration to disk:

```sh
volatility3 --file volatile.mem --log volatile.mem.log --renderer pretty --save-config volatile.mem.json windows.info
```

The configuration file `volatile.mem.json` can then be used as a basis for the upcoming runs using the `--config` flag—so that Volatility no longer has to crawl the image to find the right structures.

Next, extract the list of processes by executing Volatility 3 again using the previously generated configuration:

```sh
volatility3 --config volatile.mem.json --file volatile.mem --log volatile.mem.log --renderer pretty windows.pslist
```

For post-processing, it is usually easier to dump the results in CSV or JSON format:

```sh
mkdir volatile.mem.results

volatility3 --config volatile.mem.json --file volatile.mem --log volatile.mem.log --quiet --renderer csv windows.pslist | tee -a volatile.mem.results/pslist.csv
```

The file `~/workspace/volatile.mem.results/pslist.csv` should contain the CSV-formatted results of the `windows.pslist.PsList` plugin.

For dumping a process image, first create a directory that will contain all future extractions, then execute Volatility again using the same `windows.pslist.PsList` plugin, but this time adding the `--dump` flag:

```sh
mkdir volatile.mem.dat

volatility3 --config volatile.mem.json --file volatile.mem --log volatile.mem.log --output-dir volatile.mem.dat --renderer pretty windows.pslist --dump --pid 2700
```

The binary sample should reside in the `~/workspace/volatile.mem.dat` directory, ready to be analyzed by a reverse engineer.

Actually, all _dumper_ plugins (i.e. a Volatility plugin that is able to dump raw content from the memory image) should support the `--output-dir` option, which is quite convenient in an analysis workflow.

> Volatility is verbose but not necessarily precise when it comes to errors. When an error is raised, you should always increase the verbosity level (using `-vvv` for example) in order to get maximum details about what is going on, and eventually submit an issue on [the official Volatility 3 repository](https://github.com/volatilityfoundation/volatility3/issues) if you deem it necessary.

</details>

<details>
  <summary>Example #2: Generate an ISF file for a specific NT kernel build using <tt>pdbconv</tt></summary>

### Example #2: Generate an ISF file for a specific NT kernel build using `pdbconv`

This is very straightforward, simply instanciate a new container based on the `sk4la/volatility3` image using the `pdbconv` entrypoint:

```sh
docker container run --entrypoint pdbconv --volume "$PWD:/home/unprivileged/workspace" --workdir /home/unprivileged/workspace sk4la/volatility3 --guid ce7ffb00c20b87500211456b3e905c471 --keep --pattern ntkrnlmp.pdb
```

This will generate the [Intermediate Symbol File (ISF) file](https://volatility3.readthedocs.io/en/latest/symbol-tables.html) `ce7ffb00c20b87500211456b3e905c47-1.json.xz` in the current working directory, which will hint Volatility at how to handle this specific build in order to retrieve the information.

> Note that this will fetch the correct PDB file from the official [Microsoft Internet Symbol Server](https://msdl.microsoft.com/download/symbols) so this method will not work inside air-gapped environments. See [JPCERTCC's repository](https://github.com/JPCERTCC/Windows-Symbol-Tables) and [blog post](https://blogs.jpcert.or.jp/en/2021/09/volatility3_offline.html) for more details on how to retrieve the GUID from your own binaries and use Volatility 3 inside air-gapped environments.

The ISF file must then be placed either in the main symbols directory (located at `$INSTALL_PREFIX/lib/volatility3/volatility3/symbols/windows` by default) or in the current working directory, under the `symbols` subdirectory (e.g. `./symbols/windows/ntkrnlmp.pdb/ce7ffb00c20b87500211456b3e905c47-1.json.xz`). You can also use the `--symbol-dirs` option in addition to Docker's `--volume` option in order to provide the newly-created ISF files to Volatility.

</details>

<details>
  <summary>Example #3: Using the Docker images inside air-gapped environments</summary>

### Example #3: Using the Docker images inside air-gapped environments

This section explains how to use the Docker images inside air-gapped (or disconnected) environments. This can turn out to be useful when analyzing volatile memory samples inside isolated forensic labs.

> :bulb: This procedure is not specific to the Docker images hosted in this repository and can be used for any Docker image.

First, fetch the image locally—here using the `sk4la/volatility3` image as an example:

```sh
docker image pull sk4la/volatility3
```

Then, export it to disk as a compressed tar archive:

```sh
docker image save sk4la/volatility3 | gzip --best --stdout > sk4la-volatility3-latest.tar.gz
```

> Compression (here using GNU `gzip`) is not necessary but is usually recommended for heavier images, since it usually allows to save up a lot of space—although at the expense of speed.

The resulting archive should be present in the current directory as `sk4la-volatility3-latest.tar.gz`.

This compressed image can then be shipped to the air-gapped workstation (using a USB flash drive for example) and then loaded as follows:

```sh
gzip --decompress --stdout sk4la-volatility3-latest.tar.gz | docker image load
```

The image should then be ready for use. It is possible to check the presence of the image on the system by running the command:

```sh
docker image list
```

</details>

<details>
  <summary>Example #4: Overloading the Docker images to fit your needs</summary>

### Example #4: Overloading the Docker images to fit your needs

If you feel that the original image lacks useful stuff, you can either suggest it by [submitting a ticket](https://github.com/sk4la/volatility3-docker/issues) or you can overload the base image yourself in order to adapt it to your needs.

In order to do this, simply create a new `Dockerfile` based off one of the images from this repository—for example `sk4la/volatility3`:

```docker
FROM sk4la/volatility3

USER root

RUN apk add $STUFF

USER unprivileged
```

> By default, all of the images provided in this repository do not run as `root`—they run as the `unprivileged` user. For actions necessitating superuser privileges, it is necessary to switch user temporarily, as shown in the example.

Then, build the image by executing the `docker image build --tag volatility3-overloaded .` command. The newly-created Docker image should then appear in the local repository.

> Please have a look at the [original `Dockerfile`](src/volatility3/Dockerfile) if you need a hint on how everything is setup.

</details>

<details>
  <summary>Example #5: Using community plugins with Volatility 2</summary>

### Example #5: Using community plugins with Volatility 2

The `sk4la/volatility` image includes all community plugins from the official [volatilityfoundation/community](https://github.com/volatilityfoundation/community) repository. By default, those are stored in `/usr/local/share/volatility/plugins/community`.

> You can list all included plugins using the `--help` or `--info` flags (e.g. `podman run sk4la/volatility:edge --plugins=/usr/local/share/volatility/plugins --info`). The loading order is non-deterministic and some plugins fail to load because of missing dependencies (some are just not on PyPI anymore) or because their design is not quite suitable for distribution, so you may need to run it multiple times for it to load the plugin you are looking for. I advise instead using each plugin individually in order to avoid loading dysfunctional plugins.

To load a specific community plugin (example with JPCERT's APT17 plugin):

```sh
docker container run sk4la/volatility:edge --plugins /usr/local/share/volatility/plugins/community/JPCERT apt17scan --help
```

Please note that many plugins made for Volatility 2 have not been maintained for years and might be dysfunctional.

</details>

<details>
  <summary>Example #6: Using community plugins with Volatility 3</summary>

### Example #6: Using community plugins with Volatility 3

The `sk4la/volatility3` and `sk4la/volatility3:edge` images include all community plugins from the official [volatilityfoundation/community3](https://github.com/volatilityfoundation/community3) repository. By default, those are stored in `/usr/local/share/volatility3/plugins/community3`.

> You can list all included plugins using the `--help` flag (e.g. `podman run sk4la/volatility3:edge --plugin-dirs=/usr/local/share/volatility3/plugins --help`). Please note that many of these plugins have not been maintained a while and might be dysfunctional. I advise instead using each plugin individually in order to avoid loading dysfunctional plugins.

To load a specific community plugin (example with the Multi YARA plugin):

```sh
docker container run sk4la/volatility3:edge --plugin-dirs /usr/local/share/volatility3/plugins/community3/Silva_Multi_Yara/ multiyara --help
```

</details>

## Support

In case you encounter a problem or want to suggest a new feature relative to these Docker images, please [submit a ticket](https://github.com/sk4la/volatility3-docker/issues). [Pull requests](https://github.com/sk4la/volatility3-docker/pulls) are also greatly appreciated.

## License

This piece of software is licensed under the [Volatility Software License](https://www.volatilityfoundation.org/license/).
