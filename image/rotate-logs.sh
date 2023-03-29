#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: Apache-2.0
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-traefik-logrotate
#

source /opt/bash-init.sh

#################################################
# perform log rotation
#################################################
log INFO "########## logrotate START ##########"

/usr/sbin/logrotate --verbose /etc/logrotate.conf 2> >(sed 's/^/  /' >&2)

log INFO "########## logrotate END ############"
