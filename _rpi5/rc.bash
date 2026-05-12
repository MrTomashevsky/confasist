#!/usr/bin/env bash

# @description: Cp .rc files to $HOME
# @supported_distros: ubuntu debian raspbian
# @function: install "Copy .rc files"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install() {
    cp "$SCRIPT_DIR/.scripts/.bashrc" "$HOME/"
    echo ".bashrc has been copied"
    cp "$SCRIPT_DIR/.scripts/.nanorc" "$HOME/"
    echo ".nanorc has been copied"
}

case "$1" in

    install)
        install
        ;;
    *)
        echo "it's not available functions"
        ;;

esac
