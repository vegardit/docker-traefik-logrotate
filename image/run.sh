#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: Apache-2.0
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-traefik-logrotate

# shellcheck disable=SC1091  # Not following: /opt/bash-init.sh was not specified as input
source /opt/bash-init.sh  # https://github.com/vegardit/docker-shared/blob/v1/lib/bash-init.sh

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
  # shellcheck disable=SC1090  # ShellCheck can't follow non-constant source
  source "$INIT_SH_FILE"
fi


#################################################
# creating user/group if required
#################################################
# to prevent logorate error "error: /etc/logrotate.conf:13 unknown user '1234'"
if [[ $LOGROTATE_FILE_USER =~ ^[0-9]+$ ]] && ! getent passwd "$LOGROTATE_FILE_USER" >/dev/null; then
  log INFO "Creating user with UID [$LOGROTATE_FILE_USER]..."
  adduser "u$LOGROTATE_FILE_USER" -u "$LOGROTATE_FILE_USER" -D -H
fi

if [[ $LOGROTATE_FILE_GROUP =~ ^[0-9]+$ ]] && ! getent group "$LOGROTATE_FILE_GROUP" >/dev/null; then
  log INFO "Creating group with GID [$LOGROTATE_FILE_GROUP]..."
  addgroup "g$LOGROTATE_FILE_GROUP" -g "$LOGROTATE_FILE_GROUP"
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

if [[ ${LOGROTATE_USE_DATEEXT} == "true" ]]; then
  export LOGROTATE_NAMING_CONFIG="dateext
  dateformat ${LOGROTATE_DATEFORMAT}"
else
  export LOGROTATE_NAMING_CONFIG="start ${LOGROTATE_START_INDEX}"
fi

if interpolated=$(interpolate < /opt/logrotate.conf.template); then
  echo "$interpolated" > /etc/logrotate.conf
  chmod 644 /etc/logrotate.conf
  sed 's/^/  /' /etc/logrotate.conf
else
  exit $?
fi


#################################################
# configure and start cron deamon
#################################################
log INFO "Scheduling logrotate cronjob..."
echo "$CRON_SCHEDULE /opt/rotate-logs.sh" | crontab -

log INFO "Starting cron daemon..."
exec /usr/sbin/crond -f -l "$CRON_LOG_LEVEL"
