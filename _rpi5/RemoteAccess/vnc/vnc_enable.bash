#!/usr/bin/env bash

# @description: Enable VNC via raspi-config
# @supported_distros: ubuntu debian
# @function: install "Install raspi-config"
# @function: enable "Enable VNC"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"

install() {

    install_package raspi-config
}

enable() {

    sudo raspi-config nonint do_vnc 0

    echo "VNC enabled."
}

case "$1" in

    install)
        install
        ;;

    enable)
        enable
        ;;

esac

