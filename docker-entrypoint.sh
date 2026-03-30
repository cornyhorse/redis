#!/bin/sh
set -e

# Allow the container to be started with `--user`
if [ "$1" = 'redis-server' ] && [ "$(id -u)" = '0' ]; then
    find . \! -user redis -exec chown redis '{}' +
    exec su-exec redis "$0" "$@"
fi

# Handle `redis-server` with a config file argument
if [ "$1" = 'redis-server' ] && [ -f "$2" ]; then
    shift
    set -- redis-server "$@"
fi

exec "$@"
