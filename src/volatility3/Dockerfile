# Volatility, on Docker 🐳
#
# See https://github.com/sk4la/volatility3-docker for more details.

ARG DOCKER_TAG_ALPINE="latest"

FROM "alpine:${DOCKER_TAG_ALPINE}" AS stage

ARG GIT_TAG_JPCERT_SYMBOLS="main"
ARG GIT_TAG_PYTHON_YARA="master"

RUN apk add --no-cache --virtual=stage \
        curl \
        gcc \
        git \
        linux-headers \
        musl-dev \
        python3-dev \
        unzip

RUN python3 -m ensurepip --default-pip

WORKDIR /stage

RUN git clone --branch="${GIT_TAG_JPCERT_SYMBOLS}" --recursive --single-branch \
    https://github.com/JPCERTCC/Windows-Symbol-Tables.git \
    symbols

RUN git clone --branch="${GIT_TAG_PYTHON_YARA}" --recursive --single-branch \
        https://github.com/VirusTotal/yara-python

WORKDIR /stage/yara-python

RUN python3 setup.py build

WORKDIR /stage

RUN curl --location --max-redirs 1 \
        https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip \
            --output windows.zip \
        https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip \
            --output linux.zip \
        https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip \
            --output mac.zip \
        https://downloads.volatilityfoundation.org/volatility3/symbols/SHA256SUMS \
            --output symbols.sha256 && \
    sha256sum -c \
        symbols.sha256

RUN apk --purge del \
        stage

FROM "alpine:${DOCKER_TAG_ALPINE}" AS production

ARG GIT_TAG_VOLATILITY3="stable"

ARG INSTALL_GROUP="ci"
ARG INSTALL_USER="unprivileged"
ARG INSTALL_PREFIX="/usr/local"

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

RUN addgroup -S "${INSTALL_GROUP}" && \
    adduser -DG -S "${INSTALL_USER}" -G "${INSTALL_GROUP}" -g "Unprivileged user,,,,"

RUN apk add --no-cache \
        bat \
        capstone \
        dumb-init \
        less \
        python3 && \
    apk add --no-cache --virtual=stage \
        gcc \
        git \
        libusb-dev \
        linux-headers \
        make \
        musl-dev \
        python3-dev

ENV PYTHONFAULTHANDLER="1"
ENV PYTHONHASHSEED="random"
ENV PYTHONUNBUFFERED="1"

RUN python3 -m ensurepip --default-pip && \
    python3 -m pip install --no-cache --upgrade \
        wheel && \
    python3 -m pip install --no-cache --upgrade \
        pefile \
        pycryptodome

WORKDIR "${INSTALL_PREFIX}/lib"

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_GROUP}" \
         /stage/yara-python \
         yara-python

WORKDIR "${INSTALL_PREFIX}/lib/yara-python"

RUN python3 setup.py install

RUN find . -type d -exec chmod 0755 "{}" \; && \
    find . -type f -exec chmod 0644 "{}" \;

WORKDIR "${INSTALL_PREFIX}/lib"

RUN git clone --branch="${GIT_TAG_VOLATILITY3}" --depth=1 --single-branch \
        https://github.com/volatilityfoundation/volatility3.git

WORKDIR "${INSTALL_PREFIX}/lib/volatility3"

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --requirement requirements.txt && \
    python3 setup.py install && \
    chmod 0755 \
        vol.py \
        volatility3/framework/symbols/windows/pdbconv.py && \
    for destination in "v3" "vol" "vol3" "volatility" "volatility3"; \
    do ln -sf \
        "${INSTALL_PREFIX}/lib/volatility3/vol.py" \
        "${INSTALL_PREFIX}/bin/${destination}"; \
    done && \
    ln -sf \
        "${INSTALL_PREFIX}/lib/volatility3/volatility3/framework/symbols/windows/pdbconv.py" \
        "${INSTALL_PREFIX}/bin/pdbconv"

ENV PATH="${INSTALL_PREFIX}/bin:${PATH}"

RUN apk --purge del \
        stage

WORKDIR "${INSTALL_PREFIX}/lib/volatility3/volatility3/symbols"

COPY --from=stage \
         /stage/linux.zip \
         linux.zip

COPY --from=stage \
         /stage/mac.zip \
         mac.zip

COPY --from=stage \
         /stage/windows.zip \
         windows.zip

COPY --from=stage \
         /stage/symbols/symbols/windows \
         windows

RUN find . -type d -exec chmod 0777 "{}" \; && \
    find . -type f -exec chmod 0666 "{}" \; && \
    find /usr/lib/python3* -type d -name symbols -exec chmod 0777 "{}" \;

COPY --chown=root:root \
         assets/aliases.sh \
         /etc/profile.d/

WORKDIR "${INSTALL_PREFIX}"

USER "${INSTALL_USER}"

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "volatility3" ]

CMD [ "--help" ]

ARG PRODUCT_AUTHOR="sk4la <sk4la.box+github@gmail.com>"
ARG PRODUCT_REPOSITORY="https://github.com/sk4la/volatility3-docker.git"

ARG PRODUCT_BUILD_DATE="-"
ARG PRODUCT_BUILD_COMMIT="-"

LABEL image.author="${PRODUCT_AUTHOR}"
LABEL image.commit="${PRODUCT_BUILD_COMMIT}"
LABEL image.date="${PRODUCT_BUILD_DATE}"
LABEL image.repository="${PRODUCT_REPOSITORY}"
