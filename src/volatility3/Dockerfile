# Volatility, on Docker 🐳
#
# See https://github.com/sk4la/volatility3-docker for more details.

ARG ALPINE_VERSION

FROM "alpine:${ALPINE_VERSION}" AS stage

ARG GIT_TAG_PYTHON_YARA="master"

RUN apk add --no-cache --virtual=.build \
        curl \
        gcc \
        git \
        musl-dev \
        python3-dev \
        unzip

RUN python3 -m ensurepip --default-pip

WORKDIR /stage

RUN git clone --branch="${GIT_TAG_PYTHON_YARA}" --depth=1 --recursive --single-branch \
        https://github.com/VirusTotal/yara-python

WORKDIR /stage/yara-python

RUN python3 setup.py build

WORKDIR /stage

RUN curl -fL https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip -o windows.zip && \
    unzip windows.zip && \
    curl -fL https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip -o linux.zip && \
    unzip linux.zip && \
    curl -fL https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip -o mac.zip && \
    unzip mac.zip -d mac

RUN apk --purge del \
        .build

FROM "alpine:${ALPINE_VERSION}" AS production

ARG GIT_TAG_VOLATILITY3="stable"

ARG INSTALL_GROUP="ci"
ARG INSTALL_USER="unprivileged"
ARG INSTALL_PREFIX="/usr/local"

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

RUN addgroup -S "${INSTALL_GROUP}" && \
    adduser -DG -S "${INSTALL_USER}" -G "${INSTALL_GROUP}" -g "Unprivileged user,,,,"

RUN apk add --no-cache \
        python3 && \
    apk add --no-cache --virtual=.build \
        gcc \
        git \
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

RUN python3 setup.py install && \
    for destination in "v3" "vol" "vol3" "volatility" "volatility3"; \
    do ln -sf \
        "${INSTALL_PREFIX}/lib/volatility3/vol.py" \
        "${INSTALL_PREFIX}/bin/${destination}"; \
    done

ENV PATH="${INSTALL_PREFIX}/bin:${PATH}"

RUN apk --purge del \
        .build

WORKDIR "${INSTALL_PREFIX}/lib/volatility3/volatility3/symbols"

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_GROUP}" \
         /stage/linux \
         linux

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_GROUP}" \
         /stage/mac \
         mac

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_GROUP}" \
         /stage/windows \
         windows

RUN find . -type d -exec chmod 0755 "{}" \; && \
    find . -type f -exec chmod 0644 "{}" \;

WORKDIR "${INSTALL_PREFIX}"

USER "${INSTALL_USER}"

ENTRYPOINT [ "/usr/bin/env", "volatility3" ]

CMD [ "--help" ]

ARG PRODUCT_AUTHOR="sk4la <sk4la@gmail.com>"
ARG PRODUCT_REPOSITORY="https://github.com/sk4la/volatility3-docker.git"

ARG PRODUCT_BUILD_DATE
ARG PRODUCT_BUILD_COMMIT

LABEL image.author="${PRODUCT_AUTHOR}"
LABEL image.repository="${PRODUCT_REPOSITORY}"

LABEL image.date="${PRODUCT_BUILD_DATE}"
LABEL image.commit="${PRODUCT_BUILD_COMMIT}"
