#syntax=docker/dockerfile:1
# see https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/reference.md
# see https://docs.docker.com/engine/reference/builder/#syntax
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: Apache-2.0
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-traefik-logrotate

# https://hub.docker.com/_/alpine/tags?name=3
# https://github.com/alpinelinux/docker-alpine/blob/master/Dockerfile
ARG BASE_IMAGE=alpine:3

#############################################################
# build final image
#############################################################

# https://github.com/hadolint/hadolint/wiki/DL3006 Always tag the version of an image explicitly
# hadolint ignore=DL3006
FROM ${BASE_IMAGE} as final

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

ARG BASE_LAYER_CACHE_KEY

# https://github.com/hadolint/hadolint/wiki/DL3018 Pin versions
# hadolint ignore=DL3018
RUN --mount=type=bind,source=.shared,target=/mnt/shared <<EOF
  /mnt/shared/cmd/alpine-install-os-updates.sh

  echo "#################################################"
  echo "Installing required packages..."
  echo "#################################################"
  apk add --no-cache \
    bash \
    docker-cli \
    gzip \
    logrotate \
    tar \
    tini \
    tzdata

  /mnt/shared/cmd/alpine-cleanup.sh

EOF

ARG OCI_authors
ARG OCI_title
ARG OCI_description
ARG OCI_source
ARG OCI_revision
ARG OCI_version
ARG OCI_created

ARG GIT_BRANCH
ARG GIT_COMMIT_DATE

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL \
  org.opencontainers.image.title="$OCI_title" \
  org.opencontainers.image.description="$OCI_description" \
  org.opencontainers.image.source="$OCI_source" \
  org.opencontainers.image.revision="$OCI_revision" \
  org.opencontainers.image.version="$OCI_version" \
  org.opencontainers.image.created="$OCI_created"

LABEL maintainer="$OCI_authors"

# Default configuration: can be overridden at the docker command line
ENV \
  INIT_SH_FILE='' \
  #
  TRAEFIK_CONTAINER_ID_COMMAND="docker ps --no-trunc --quiet --filter label=org.opencontainers.image.title=Traefik" \
  LOGROTATE_LOGS="/var/log/traefik/*.log" \
  LOGROTATE_TRIGGER_INTERVAL=daily \
  LOGROTATE_TRIGGER_SIZE=50M \
  LOGROTATE_MAX_BACKUPS=14 \
  LOGROTATE_START_INDEX=1 \
  LOGROTATE_FILE_MODE=0644 \
  LOGROTATE_FILE_USER=root \
  LOGROTATE_FILE_GROUP=root \
  LOGROTATE_USE_DATEEXT=false \
  LOGROTATE_DATEFORMAT="-%Y%m%d" \
  POST_LOGROTATE_COMMAND='' \
  CRON_SCHEDULE="* * * * *" \
  CRON_LOG_LEVEL=8

COPY image/logrotate.conf.template /opt/logrotate.conf.template
COPY image/*.sh /opt/

RUN <<EOF
  echo "#################################################"
  echo "Writing build_info..."
  echo "#################################################"
  cat <<EOT >/opt/build_info
GIT_REPO:    $OCI_source
GIT_BRANCH:  $GIT_BRANCH
GIT_COMMIT:  $OCI_revision @ $GIT_COMMIT_DATE
IMAGE_BUILD: $OCI_created
EOT
  cat /opt/build_info

  chmod 444 /opt/logrotate.conf.template
  chmod 555 /opt/*.sh

EOF

COPY .shared/lib/bash-init.sh /opt/bash-init.sh

WORKDIR /root

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/bin/bash", "/opt/run.sh"]
