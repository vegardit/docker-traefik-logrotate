#!/usr/bin/env bash
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
# perform log rotation
#################################################
log INFO "########## logrotate START ##########"

/usr/sbin/logrotate --verbose /etc/logrotate.conf 2> >(sed 's/^/  /' >&2)

log INFO "########## logrotate END ############"
