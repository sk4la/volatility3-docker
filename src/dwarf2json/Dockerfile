# Volatility, on Docker 🐳
#
# See https://github.com/sk4la/volatility3-docker for more details.

ARG DOCKER_TAG_ALPINE="latest"

FROM "alpine:${DOCKER_TAG_ALPINE}" AS stage

ARG GIT_TAG_DWARF2JSON="master"

RUN apk add --no-cache --virtual=stage \
        git \
        go

WORKDIR /stage

RUN git clone --branch="${GIT_TAG_DWARF2JSON}" --depth=1 --single-branch \
        https://github.com/volatilityfoundation/dwarf2json.git

WORKDIR /stage/dwarf2json

RUN go build -ldflags="-s -w"

RUN apk --purge del \
        stage

FROM "alpine:${DOCKER_TAG_ALPINE}" AS production

ARG INSTALL_GROUP="ci"
ARG INSTALL_USER="unprivileged"
ARG INSTALL_PREFIX="/usr/local"

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

VOLUME /tmp /var/tmp

RUN apk add --no-cache \
        dumb-init

RUN addgroup -S "${INSTALL_GROUP}" && \
    adduser -DHG -S "${INSTALL_USER}" -G "${INSTALL_GROUP}" -g "Unprivileged user,,,,"

WORKDIR "${INSTALL_PREFIX}/bin"

COPY --from=stage --chown="${INSTALL_USER}:${INSTALL_GROUP}" \
         /stage/dwarf2json/dwarf2json \
         dwarf2json

RUN chmod 0755 \
        dwarf2json

ENV PATH="${INSTALL_PREFIX}/bin:${PATH}"

WORKDIR "${INSTALL_PREFIX}"

USER "${INSTALL_USER}"

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "dwarf2json" ]

CMD [ "--help" ]

ARG PRODUCT_AUTHOR="sk4la <sk4la.box+github@gmail.com>"
ARG PRODUCT_REPOSITORY="https://github.com/sk4la/volatility3-docker.git"

ARG PRODUCT_BUILD_DATE="-"
ARG PRODUCT_BUILD_COMMIT="-"

LABEL image.author="${PRODUCT_AUTHOR}"
LABEL image.commit="${PRODUCT_BUILD_COMMIT}"
LABEL image.date="${PRODUCT_BUILD_DATE}"
LABEL image.repository="${PRODUCT_REPOSITORY}"
