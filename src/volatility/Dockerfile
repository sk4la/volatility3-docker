# Volatility, on Docker 🐳
#
# See https://github.com/sk4la/volatility3-docker for more details.

ARG ALPINE_VERSION="latest"

FROM "alpine:${ALPINE_VERSION}" AS stage

ARG GIT_TAG_PYTHON_YARA="master"

RUN apk add --no-cache --virtual=stage \
        curl \
        gcc \
        git \
        linux-headers \
        musl-dev \
        py3-pip \
        python3-dev

WORKDIR /stage

RUN git clone --branch="${GIT_TAG_PYTHON_YARA}" --recursive --single-branch \
        https://github.com/VirusTotal/yara-python

WORKDIR /stage/yara-python

RUN python3 setup.py build

RUN apk --purge del \
        stage

FROM "alpine:${ALPINE_VERSION}" AS production

ARG GIT_TAG_VOLATILITY="stable"
ARG GIT_TAG_VOLATILITY_COMMUNITY="master"

ARG INSTALL_GROUP="ci"
ARG INSTALL_USER="unprivileged"
ARG INSTALL_PREFIX="/usr/local"

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

RUN addgroup -S "${INSTALL_GROUP}" && \
    adduser -DG -S "${INSTALL_USER}" -G "${INSTALL_GROUP}" -g "Unprivileged user,,,,"

RUN apk add --no-cache \
        bat \
        dumb-init \
        jpeg \
        less \
        libxml2 \
        libxslt \
        python2 \
        zlib && \
    apk add --no-cache --virtual=stage \
        g++ \
        gcc \
        git \
        jpeg-dev \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        musl-dev \
        openssl-dev \
        python2-dev \
        swig \
        zlib-dev

ENV PYTHONFAULTHANDLER="1"
ENV PYTHONHASHSEED="random"
ENV PYTHONUNBUFFERED="1"

RUN python2 -m ensurepip --default-pip && \
    python2 -m pip install --no-cache --upgrade \
        wheel && \
    python2 -m pip install --no-cache --upgrade \
        distorm3 \
        lxml \
        openpyxl \
        pefile \
        pillow==6 \
        pycoin \
        pycrypto \
        ujson

RUN python2 -m pip install --no-cache --upgrade \
        colorama \
        construct \
        haystack \
        pysocks \
        pysphere \
        requests \
        simplejson

WORKDIR "${INSTALL_PREFIX}/lib"

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_GROUP}" \
         /stage/yara-python \
         yara-python

WORKDIR "${INSTALL_PREFIX}/lib/yara-python"

RUN python setup.py install

RUN find . -type d -exec chmod 0755 "{}" \; && \
    find . -type f -exec chmod 0644 "{}" \;

WORKDIR "${INSTALL_PREFIX}/lib"

RUN git clone --branch="${GIT_TAG_VOLATILITY}" --depth=1 --single-branch \
        https://github.com/volatilityfoundation/volatility.git

WORKDIR "${INSTALL_PREFIX}/lib/volatility"

RUN python2 setup.py install && \
    chmod 0755 \
        vol.py && \
    for destination in "v2" "vol" "vol2" "volatility" "volatility2"; \
    do ln -sf \
        "${INSTALL_PREFIX}/lib/volatility/vol.py" \
        "${INSTALL_PREFIX}/bin/${destination}"; \
    done

ENV PATH="${INSTALL_PREFIX}/bin:${PATH}"

WORKDIR "${INSTALL_PREFIX}/lib/volatility/contrib/plugins"

RUN git clone --branch="${GIT_TAG_VOLATILITY_COMMUNITY}" --depth=1 --single-branch \
        https://github.com/volatilityfoundation/community.git

RUN apk --purge del \
        stage

COPY --chown=root:root \
         assets/aliases.sh \
         /etc/profile.d/

WORKDIR "${INSTALL_PREFIX}"

USER "${INSTALL_USER}"

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "volatility" ]

CMD [ "--help" ]

ARG PRODUCT_AUTHOR="sk4la <sk4la.box+github@gmail.com>"
ARG PRODUCT_REPOSITORY="https://github.com/sk4la/volatility3-docker.git"

ARG PRODUCT_BUILD_COMMIT="-"
ARG PRODUCT_BUILD_DATE="-"

LABEL image.author="${PRODUCT_AUTHOR}"
LABEL image.commit="${PRODUCT_BUILD_COMMIT}"
LABEL image.date="${PRODUCT_BUILD_DATE}"
LABEL image.repository="${PRODUCT_REPOSITORY}"
