# vegardit/traefik-logrotate <a href="https://github.com/vegardit/traefik-logrotate/" title="GitHub Repo"><img height="30" src="https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/github.svg?sanitize=true"></a>

[![Build Status](https://github.com/vegardit/docker-traefik-logrotate/workflows/Build/badge.svg "GitHub Actions")](https://github.com/vegardit/docker-traefik-logrotate/actions?query=workflow%3ABuild)
[![License](https://img.shields.io/github/license/vegardit/docker-traefik-logrotate.svg?label=license)](#license)
[![Docker Pulls](https://img.shields.io/docker/pulls/vegardit/traefik-logrotate.svg)](https://hub.docker.com/r/vegardit/traefik-logrotate)
[![Docker Stars](https://img.shields.io/docker/stars/vegardit/traefik-logrotate.svg)](https://hub.docker.com/r/vegardit/traefik-logrotate)

1. [What is it?](#what-is-it)
1. [Usage](#usage)
1. [License](#license)


## <a name="what-is-it"></a>What is it?

A lightweight, multi-arch Docker image based on [alpine:3](https://hub.docker.com/_/alpine/tags?name=3) to be used in conjunction with
a dockerized [Traefik](https://traefik.io) instance to rotate [Traefik's access logs](https://doc.traefik.io/traefik/observability/access-logs/).

Automatically rebuilt **weekly** to include the latest OS security fixes.


## <a name="usage"></a>Usage

Example `docker-compose.yml`:

```yaml
services:

  traefik:
    image: traefik:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /var/log/traefik:/var/log/traefik:rw  # folder containing access.log file
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
    # ... other configurations


  logrotate:
    image: vegardit/traefik-logrotate:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:rw # required to send USR1 signal to Traefik after log rotation
      - /var/log/traefik:/var/log/traefik:rw # folder containing access.log file
    environment:
      TZ: "Europe/Berlin"
      # all environment variables are optional and show the default values:
      LOGROTATE_LOGS: "/var/log/traefik/*.log" # log files to rotate, directory must match volume mount
      LOGROTATE_TRIGGER_INTERVAL: daily  # rotate daily, must be one of: daily, weekly, monthly, yearly
      LOGROTATE_TRIGGER_SIZE: 50M        # rotate if log file size reaches 50MB
      LOGROTATE_MAX_BACKUPS: 14          # keep 14 backup copies per rotated log file
      LOGROTATE_MAX_AGE_DAYS: 14         # remove older archives during rotation; 0 disables age-based removal
      LOGROTATE_IFEMPTY: "false"        # set to "true" to rotate empty logs too
      LOGROTATE_START_INDEX: 1           # first rotated file is called access.1.log (ignored when dateext is enabled)
      LOGROTATE_USE_DATEEXT: false       # use date extension instead of numbers (e.g., access.log-20240814)
      LOGROTATE_DATEFORMAT: "-%Y%m%d"    # date format for rotated files when dateext is enabled
      LOGROTATE_FILE_MODE: 0644          # file mode of the rotated file
      LOGROTATE_FILE_USER: root          # owning user of the rotated file
      LOGROTATE_FILE_GROUP: root         # owning group of the rotated file
      CRON_SCHEDULE: "* * * * *"
      CRON_LOG_LEVEL: 8                  # see https://unix.stackexchange.com/a/414010/378036
      # command to determine the id of the container running Traefik:
      TRAEFIK_CONTAINER_ID_COMMAND: docker ps --no-trunc --quiet --filter label=org.opencontainers.image.title=Traefik
      # optional: command to run after log rotation, e.g. restart goaccess or call a custom script
      POST_LOGROTATE_COMMAND: ""         # example: "docker restart goaccess" or "/opt/post-logrotate.sh"
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
```

### Rotation Scenarios

Merge the settings from the relevant scenario into the `logrotate` service's `environment` block above.

#### Target a 14-day retention limit

Use daily rotation with 12 archives when logs should be removed within 14 days.
Together with the active file, this retains roughly 13 days and leaves about one day of margin.

```yaml
environment:
  LOGROTATE_TRIGGER_INTERVAL: daily
  LOGROTATE_IFEMPTY: "true"
  LOGROTATE_MAX_AGE_DAYS: "12"
  LOGROTATE_MAX_BACKUPS: "12"
```

`LOGROTATE_IFEMPTY: "true"` keeps rotation and cleanup running on days without requests.
Size-triggered rotations can shorten the retained history.

This target assumes successful daily rotation; downtime or failed runs can delay deletion.
Age-based cleanup uses archive modification times and runs only during rotation,
so setting `LOGROTATE_MAX_AGE_DAYS: "14"` alone does not enforce a 14-day deadline for individual log entries.

#### Keep 14 archives and rotate at 50 MiB

Use this when you want to limit the number of archives and rotate large logs, regardless of their age.

```yaml
environment:
  LOGROTATE_TRIGGER_INTERVAL: daily
  LOGROTATE_TRIGGER_SIZE: 50M
  LOGROTATE_MAX_BACKUPS: "14"
  LOGROTATE_MAX_AGE_DAYS: "0"
  LOGROTATE_IFEMPTY: "false"
```

This keeps up to 14 archives per log file, plus the active file.
`LOGROTATE_MAX_AGE_DAYS: "0"` disables age-based deletion.
Empty logs are skipped, so archives can remain indefinitely if no new requests arrive.

Nonempty logs rotate daily or sooner when they exceed 50 MiB.
With the default cron schedule, sizes are checked once per minute; files can grow beyond the threshold between checks.
Compression also affects archive sizes, so these settings do not impose a fixed disk-space quota.

### Date-based Log Rotation

To use date-based naming for rotated files instead of numbered suffixes, enable the `dateext` option:

```yaml
services:
  logrotate:
    image: vegardit/traefik-logrotate:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:rw
      - /var/log/traefik:/var/log/traefik:rw
    environment:
      LOGROTATE_USE_DATEEXT: "true"       # Enable date-based naming
      LOGROTATE_DATEFORMAT: "-%Y%m%d"     # Results in: access.log-20240814.gz
      # Alternative formats:
      # LOGROTATE_DATEFORMAT: ".%Y-%m-%d" # Results in: access.log.2024-08-14.gz
      # LOGROTATE_DATEFORMAT: "_%Y%m%d_%H" # Results in: access.log_20240814_15.gz (hourly)
```

When `LOGROTATE_USE_DATEEXT` is enabled:
- Rotated files will be named with dates (e.g., `access.log-20240814.gz`)
- The `LOGROTATE_START_INDEX` setting is ignored
- Files are sorted lexically, so use year-month-day format for proper ordering
- Supported format specifiers: `%Y` (year), `%m` (month), `%d` (day), `%H` (hour), `%M` (minute), `%S` (second)


## <a name="license"></a>License

All files in this repository are released under the [Apache License 2.0](LICENSE.txt).

Individual files contain the following tag instead of the full license text:
```
SPDX-License-Identifier: Apache-2.0
```

This enables machine processing of license information based on the SPDX License Identifiers that are available here: https://spdx.org/licenses/.
