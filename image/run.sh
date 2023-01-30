#!/usr/bin/env bash
#
# Copyright 2021-2022 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: Apache-2.0
#
# Author: Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-traefik-logrotate
#

source /opt/bash-init.sh # https://github.com/vegardit/docker-shared/blob/v1/lib/bash-init.sh

#################################################
# print header
#################################################
cat <<'EOF'
*********************
* TRAEFIK LOGROTATE *
*********************

EOF

cat /opt/build_info
echo

log INFO "Timezone is $(date +"%Z %z")"


#################################################
# load custom init script if specified
#################################################
if [[ -f $INIT_SH_FILE ]]; then
  log INFO "Loading [$INIT_SH_FILE]..."
  source "$INIT_SH_FILE"
fi


#################################################
# generate logrotate config
#################################################

log_directory=$(dirname "$LOGROTATE_LOGS")
if [[ ! -e $log_directory ]]; then
  log ERROR "Directory [$log_directory] does not exist! Verify LOGROTATE_LOGS environment variable and volume mount."
  exit 1
fi

log INFO "Generating [/etc/logrotate.conf] based on template [/opt/logrotate.conf.template]..."
if interpolated=$(interpolate < /opt/logrotate.conf.template); then
  echo "$interpolated" > /etc/logrotate.conf
  chmod 644 /etc/logrotate.conf
  cat /etc/logrotate.conf | sed 's/^/  /'
else
  exit $?
fi


#################################################
# configure and start cron deamon
#################################################
log INFO "Scheduling logrotate cronjob..."
echo "$CRON_SCHEDULE /opt/rotate-logs.sh" | crontab -

log INFO "Starting cron daemon..."
exec /usr/sbin/crond -f -l $CRON_LOG_LEVEL
