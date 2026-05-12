#!/usr/bin/env bash

is_root() {

    if [[ ! "$EUID" -eq 0 ]]; then
	echo "Not a root!"
        exit 1
    fi

}
