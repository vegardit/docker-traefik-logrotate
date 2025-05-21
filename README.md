# vegardit/traefik-logrotate <a href="https://github.com/vegardit/traefik-logrotate/" title="GitHub Repo"><img height="30" src="https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/github.svg?sanitize=true"></a>

[![Build Status](https://github.com/vegardit/docker-traefik-logrotate/workflows/Build/badge.svg "GitHub Actions")](https://github.com/vegardit/docker-traefik-logrotate/actions?query=workflow%3ABuild)
[![License](https://img.shields.io/github/license/vegardit/docker-traefik-logrotate.svg?label=license)](#license)
[![Docker Pulls](https://img.shields.io/docker/pulls/vegardit/traefik-logrotate.svg)](https://hub.docker.com/r/vegardit/traefik-logrotate)
[![Docker Stars](https://img.shields.io/docker/stars/vegardit/traefik-logrotate.svg)](https://hub.docker.com/r/vegardit/traefik-logrotate)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.1%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

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
      LOGROTATE_START_INDEX: 1           # first rotated file is called access.1.log
      LOGROTATE_FILE_MODE: 0644          # file mode of the rotated file
      LOGROTATE_FILE_USER: root          # owning user of the rotated file
      LOGROTATE_FILE_GROUP: root         # owning group of the rotated file
      CRON_SCHEDULE: "* * * * *"
      CRON_LOG_LEVEL: 8                  # see https://unix.stackexchange.com/a/414010/378036
      # command to determine the id of the container running Traefik:
      TRAEFIK_CONTAINER_ID_COMMAND: docker ps --no-trunc --quiet --filter label=org.opencontainers.image.title=Traefik
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
```


## <a name="license"></a>License

All files in this repository are released under the [Apache License 2.0](LICENSE.txt).

Individual files contain the following tag instead of the full license text:
```
SPDX-License-Identifier: Apache-2.0
```

This enables machine processing of license information based on the SPDX License Identifiers that are available here: https://spdx.org/licenses/.
