#!/usr/bin/env bash

# @description: Install common packages
# @supported_distros: ubuntu debian raspbian
# @function: install "Install default packages"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"

install() {
    packages=(
        sl pciutils tree tmux kate tig mpv shellcheck openssh-server htop
        base-devel git nano less bat nnn lf python3-pip python3 lm-sensors python-is-python3
        build-essential "linux-headers-$(uname -r)"
    )

    for pkg in "${packages[@]}"; do
	install_package "$pkg" || true
    done
}

case "$1" in
    install)
        install
        ;;
    *)
        echo "Available functions: install"
        ;;
esac
