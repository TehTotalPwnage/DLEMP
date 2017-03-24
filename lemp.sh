#!/bin/bash

trap stop SIGTERM

help() {
    echo "lemp.sh <command> [arguments]"
    echo "COMMANDS:"
    echo "- help : Lists all possible commands in the LEMP script."
    echo "- start: Starts the LEMP stack, including MySQL, PHP, and NGINX."
}

start() {
    mysqld &
    PID[0]=$!
    if [ $1 = "dev" ];
    then
        echo "Starting container in development mode"
        nginx -c /etc/nginx/nginx.dev.conf &
    else
        nginx &
    fi
    PID[1]=$!
    php5-fpm &
    PID[2]=$!

    for process in ${PID}
    do
        wait $process
    done
}

stop() {
    for process in ${PID}
    do
        kill $process
    done
}

case $1 in
    "start")
        shift 1
        start "$@"
        ;;
    *)
        echo "Unrecognized command. Try 'lemp.sh help' to view all commands."
        ;;
esac
