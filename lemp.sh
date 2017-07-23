#!/bin/bash

# Copyright 2017 Michael Nguyen
#
# This file is part of DLEMP.
#
# DLEMP is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# DLEMP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with DLEMP. If not, see http://www.gnu.org/licenses/.


# Listen for a SIGTERM signal from the Docker daemon to kill the processes and stop the script.
trap stop SIGTERM

# Echos the help text for the script.
help() {
    echo "lemp.sh <command> [arguments]"
    echo "COMMANDS:"
    echo "- help : Lists all possible commands in the LEMP script."
    echo "- start: Starts the LEMP stack, including MySQL, PHP, and NGINX."
}

# Starts the NGINX and PHP processes and waits on a kill signal.
start() {
    php5-fpm -R &
    PID[0]=$!
    if [ "$1" == "dev" ]; then
        echo "Starting container in development mode"
        nginx -c /etc/nginx/nginx.dev.conf &
    else
        nginx -c /etc/nginx/nginx.conf &
    fi
    PID[1]=$!

    # Wait for these processes to complete, as they are only responsible for startup.
    for process in "${PID[@]}"
    do
        wait $process
    done


    echo "Processes started. Now waiting on processes..."

    # This gets the PIDs for the actual master processes for NGINX and PHP.
    NGINX=`pgrep -f "master process nginx"`
    PHP=`pgrep -f "php-fpm: master process"`

    # Since these aren't considered child processes, we sleep the script instead of actually "waiting".
    while [ -e "/proc/$NGINX" ] || [ -e "/proc/$PHP" ]; do
        sleep 1
    done

    # Once both processes come down, we can stop the script.
    echo "All processes have ended. Shutting down..."
}

# If SIGTERM is received, a kill signal will be fired to NGINX and PHP.
stop() {
    echo "Kill signal received, killing processes..."
    kill $NGINX
    kill $PHP
}

# This just checks for the command arguments.
case $1 in
    "start")
        shift 1
        start "$@"
        ;;
    *)
        echo "Unrecognized command. Try 'lemp.sh help' to view all commands."
        ;;
esac
