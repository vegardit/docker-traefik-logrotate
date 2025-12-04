#!/bin/bash
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: Apache-2.0
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-traefik-logrotate

# shellcheck disable=SC1091  # Not following: /opt/bash-init.sh was not specified as input
source /opt/bash-init.sh  # https://github.com/vegardit/docker-shared/blob/v1/lib/bash-init.sh

#################################################
# notify Traefik
#################################################
TRAEFIK_CONTAINER_ID_COMMAND="${TRAEFIK_CONTAINER_ID_COMMAND:-docker ps --no-trunc --quiet --filter label=org.opencontainers.image.title=Traefik}"

log INFO "Determining Traefik PID using [$TRAEFIK_CONTAINER_ID_COMMAND]..."
traefik_container_id=$(eval "${TRAEFIK_CONTAINER_ID_COMMAND}")

if [[ -z $traefik_container_id ]]; then
  log WARN "Could not determine Traefik PID. Is Traefik running?"
else
  log INFO "Notifying Traefik in container [$traefik_container_id]..."
  if ! docker kill --signal=USR1 "$traefik_container_id"; then
    log WARN "Failed to send USR1 signal to Traefik container [$traefik_container_id]"
  fi
fi

#################################################
# execute optional post-rotation command
#################################################
if [[ -n ${POST_LOGROTATE_COMMAND:-} ]]; then
  log INFO "Executing POST_LOGROTATE_COMMAND: [$POST_LOGROTATE_COMMAND]..."
  if ! bash -lc "$POST_LOGROTATE_COMMAND"; then
    log WARN "POST_LOGROTATE_COMMAND failed with exit code $?"
  fi
fi
