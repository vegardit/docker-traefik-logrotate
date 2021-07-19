#/bin/bassh
#
# Copyright 2021 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: Apache-2.0
#
# Author: Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-traefik-logrotate
#

source /opt/bash-init.sh

#################################################
# notify Traefik
#################################################
TRAEFIK_CONAINER_ID_COMMAND="${TRAEFIK_CONAINER_ID_COMMAND:-docker ps --quiet --filter ancestor=traefik}"

log INFO "Determining Traefik PID using [$TRAEFIK_CONAINER_ID_COMMAND]..."
traefik_container_id=$(eval "${TRAEFIK_CONAINER_ID_COMMAND}")

if [ -z $traefik_container_id ]; then
  log WARN "Could not determine Traefik PID. Is Traefik running?"
  exit 0
fi

log INFO "Notifying Traefik in container [$traefik_container_id]..."
docker kill --signal=USR1 $traefik_container_id
