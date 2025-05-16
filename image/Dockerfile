#syntax=docker/dockerfile:1
# see https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/reference.md
# see https://docs.docker.com/engine/reference/builder/#syntax
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: Apache-2.0
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-traefik-logrotate
#

# https://github.com/alpinelinux/docker-alpine/blob/master/Dockerfile
FROM alpine:3

LABEL maintainer="Vegard IT GmbH (vegardit.com)"

# https://github.com/hadolint/hadolint/wiki/DL3002 Last USER should not be root
# hadolint ignore=DL3002
USER root

ARG BASE_LAYER_CACHE_KEY

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# https://github.com/hadolint/hadolint/wiki/DL3018 Pin versions
# hadolint ignore=DL3018
RUN --mount=type=bind,source=.shared,target=/mnt/shared <<EOF
  #!/bin/ash
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

ARG BUILD_DATE
ARG GIT_BRANCH
ARG GIT_COMMIT_HASH
ARG GIT_COMMIT_DATE
ARG GIT_REPO_URL

LABEL \
  org.label-schema.schema-version="1.0" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$GIT_COMMIT_HASH \
  org.label-schema.vcs-url=$GIT_REPO_URL

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
  CRON_SCHEDULE="* * * * *" \
  CRON_LOG_LEVEL=8

COPY image/logrotate.conf.template /opt/logrotate.conf.template
COPY image/*.sh /opt/

RUN <<EOF
  #!/bin/ash
  echo "#################################################"
  echo "Writing build_info..."
  echo "#################################################"
  echo -e "
GIT_REPO:    $GIT_REPO_URL
GIT_BRANCH:  $GIT_BRANCH
GIT_COMMIT:  $GIT_COMMIT_HASH @ $GIT_COMMIT_DATE
IMAGE_BUILD: $BUILD_DATE" >/opt/build_info
  cat /opt/build_info

  chmod 444 /opt/logrotate.conf.template
  chmod 555 /opt/*.sh

EOF

COPY .shared/lib/bash-init.sh /opt/bash-init.sh

WORKDIR /root

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/bin/bash", "/opt/run.sh"]
