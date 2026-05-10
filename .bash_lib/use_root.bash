#!/usr/bin/env bash

require_root() {

    if [[ "$EUID" -eq 0 ]]; then
        return
    fi

    echo "Root permissions required"

    exec sudo "$0" "$@"
}
