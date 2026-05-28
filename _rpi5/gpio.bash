#!/usr/bin/env bash

# @description: Install dependencies for using gpio
# @supported_distros: ubuntu debian raspbian
# @function: install "Install gpio dependencies and set user mode"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install() {
    update_system
    install_package gpiod python3-gpiozero
    install_package python3-lgpio

    sudo usermod -aG dialout $USER

    mkdir -p ~/tmp
    mkdir -p ~/tmp/buzzer_examples
    cp "$SCRIPT_DIR/.scripts/buzzer*" ~/tmp/buzzer_examples/

    echo "Please logout for the changes to take effect"

}

case "$1" in
    install)
        install
        ;;
    *)
        echo "Available functions: install"
        ;;
esac

