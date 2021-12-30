# MIT License
#
# Copyright (c) 2022 sk4la <sk4la.box@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Docker image based on Alpine Linux embedding the Volatility 3 framework (https://github.com/volatilityfoundation/volatility3).
#
# Maintained by sk4la <sk4la.box@gmail.com>.
#
# To build:
#   $ docker build -t sk4la/volatility:latest .
#
# Additionaly, one can set the following build arguments (using the --build-arg option) to customize the build:
#   - ALPINE_VERSION [3.15]
#   - INSTALL_PREFIX [/usr]
#   - INSTALL_USER [root]
#
# To run as a standalone container:
#   $ docker run -v $PWD:/case:ro --rm --cap-drop ALL sk4la/volatility
#   $ docker run -v $PWD:/case:ro --rm --cap-drop ALL sk4la/volatility -f /case/volatile.dmp windows.info
#
# One can also remove the ":ro" suffix (in the -v option) to allow writing to disk.
#
# See https://github.com/sk4la/volatility3-docker for details.

ARG ALPINE_VERSION

FROM "docker.io/library/alpine:${ALPINE_VERSION}" AS stage

ARG INSTALL_USER

USER "${INSTALL_USER}"

WORKDIR /tmp/build

# Install system dependencies
RUN apk add --no-cache --virtual=.build \
        curl \
        gcc \
        git \
        musl-dev \
        python3-dev \
        unzip

RUN python3 -m ensurepip --default-pip

# Build the Python bindings for YARA
RUN git clone --recursive \
        https://github.com/VirusTotal/yara-python

WORKDIR /tmp/build/yara-python

RUN python3 setup.py build

WORKDIR /tmp/build

# Fetch the symbols from the Volatility 3 framework
RUN curl -fL https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip -o windows.zip && \
    unzip windows.zip

RUN curl -fL https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip -o linux.zip && \
    unzip linux.zip

RUN curl -fL https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip -o mac.zip && \
    unzip mac.zip -d mac

RUN apk --purge del \
        .build

FROM "docker.io/library/alpine:${ALPINE_VERSION}"

ARG PRODUCT_AUTHOR
ARG PRODUCT_BUILD_COMMIT
ARG PRODUCT_BUILD_DATE
ARG PRODUCT_REPOSITORY
ARG PRODUCT_VERSION

ARG INSTALL_USER
ARG INSTALL_PREFIX

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

ENV PYTHONFAULTHANDLER="1"
ENV PYTHONHASHSEED="random"
ENV PYTHONUNBUFFERED="1"

USER "${INSTALL_USER}"

WORKDIR "${INSTALL_PREFIX}/lib"

# Install system dependencies
RUN apk add --no-cache \
        python3 && \
    apk add --no-cache --virtual=.build \
        gcc \
        git \
        musl-dev \
        python3-dev

RUN python3 -m ensurepip --default-pip && \
    python3 -m pip install --no-cache --upgrade \
        pycryptodome

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_USER}" \
         /tmp/build/yara-python \
         yara-python

RUN find . -type d -exec chmod 0755 "{}" \; && \
    find . -type f -exec chmod 0644 "{}" \;

# Install the Volatility 3 framework
RUN git clone --branch=stable --depth=1 --single-branch \
        https://github.com/volatilityfoundation/volatility3.git

WORKDIR "${INSTALL_PREFIX}/lib/volatility3"

RUN python3 setup.py install && \
    ln -sf \
        "${INSTALL_PREFIX}/bin/vol" \
        "${INSTALL_PREFIX}/bin/volatility"

WORKDIR "${INSTALL_PREFIX}/lib/yara-python"

# Install the Python bindings for YARA
RUN python3 setup.py install

WORKDIR "${INSTALL_PREFIX}/lib/volatility3/volatility3/symbols"

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_USER}" \
         /tmp/build/linux \
         linux

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_USER}" \
         /tmp/build/mac \
         mac

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_USER}" \
         /tmp/build/windows \
         windows

RUN find . -type d -exec chmod 0755 "{}" \; && \
    find . -type f -exec chmod 0644 "{}" \;

RUN apk --purge del \
        .build

WORKDIR /

ENTRYPOINT [ "/usr/bin/env", "volatility" ]

CMD [ "--help" ]

LABEL image.author="${PRODUCT_AUTHOR}"
LABEL image.commit="${PRODUCT_BUILD_COMMIT}"
LABEL image.date="${PRODUCT_BUILD_DATE}"
LABEL image.repository="${PRODUCT_REPOSITORY}"
LABEL image.version="${PRODUCT_VERSION}"
