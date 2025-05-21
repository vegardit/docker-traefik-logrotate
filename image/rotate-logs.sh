#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: Apache-2.0
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-traefik-logrotate

# shellcheck disable=SC1091  # Not following: /opt/bash-init.sh was not specified as input
source /opt/bash-init.sh  # https://github.com/vegardit/docker-shared/blob/v1/lib/bash-init.sh

#################################################
# perform log rotation
#################################################
log INFO "########## logrotate START ##########"

/usr/sbin/logrotate --verbose /etc/logrotate.conf 2> >(sed 's/^/  /' >&2)

log INFO "########## logrotate END ############"
