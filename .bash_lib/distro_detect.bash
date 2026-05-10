#!/usr/bin/env bash

get_distro() {

    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID"
        return
    fi

    echo "unknown"
}
