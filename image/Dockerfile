#syntax=docker/dockerfile:1.2
# Copyright 2021-2022 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: Apache-2.0
#
# Author: Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-traefik-logrotate
#

# https://github.com/alpinelinux/docker-alpine/blob/master/Dockerfile
FROM alpine:3

LABEL maintainer="Vegard IT GmbH (vegardit.com)"

USER root

ARG BASE_LAYER_CACHE_KEY

RUN --mount=type=bind,source=.shared,target=/mnt/shared \
  set -eu && \
  /mnt/shared/cmd/alpine-install-os-updates.sh && \
  #
  echo "#################################################" &&\
  echo "Installing required packages..." && \
  echo "#################################################" &&\
  apk --no-cache add \
     bash \
     docker-cli \
     gzip \
     logrotate \
     tar \
     tzdata \
     tini \
     && \
  #
  /mnt/shared/cmd/alpine-cleanup.sh

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
  TRAEFIK_CONTAINER_ID_COMMAND="docker ps --quiet --filter ancestor=traefik" \
  LOGROTATE_LOGS="/var/log/traefik/*.log" \
  LOGROTATE_TRIGGER_INTERVAL=daily \
  LOGROTATE_TRIGGER_SIZE=50M \
  LOGROTATE_MAX_BACKUPS=14 \
  LOGROTATE_START_INDEX=1 \
  CRON_SCHEDULE="* * * * *" \
  CRON_LOG_LEVEL=8

COPY image/logrotate.conf.template /opt/logrotate.conf.template
COPY image/*.sh /opt/

RUN \
  set -eu && \
  echo -e "\
GIT_REPO:    $GIT_REPO_URL\n\
GIT_BRANCH:  $GIT_BRANCH\n\
GIT_COMMIT:  $GIT_COMMIT_HASH @ $GIT_COMMIT_DATE\n\
IMAGE_BUILD: $BUILD_DATE\n" >/opt/build_info && \
  cat /opt/build_info && \
  #
  chmod 444 /opt/logrotate.conf.template && \
  chmod 555 /opt/*.sh

COPY .shared/lib/bash-init.sh /opt/bash-init.sh

WORKDIR /root

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/bin/bash", "/opt/run.sh"]
