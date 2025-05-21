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
  exit 0
fi

log INFO "Notifying Traefik in container [$traefik_container_id]..."
docker kill --signal=USR1 "$traefik_container_id"
