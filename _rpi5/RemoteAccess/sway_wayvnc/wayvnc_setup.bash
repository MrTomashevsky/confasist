#!/usr/bin/env bash

# @description: Install and configure wayvnc for sway
# @supported_distros: ubuntu debian
# @function: install "Install wayvnc"
# @function: build_from_source "Build wayvnc manually"
# @function: setup_config "Install default wayvnc config"
# @function: add_render_groups "Add user to render/video groups"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install() {

    if ! install_package wayvnc; then
	build_from_source
    fi
    setup_config
    add_render_groups
}

build_from_source() {

    install_package git
    install_package meson
    install_package ninja-build

    mkdir -p ~/tmp
    cd ~/tmp

    git clone https://github.com/any1/aml.git
    git clone https://github.com/any1/neatvnc.git
    git clone https://github.com/any1/wayvnc.git

    cd aml
    meson build --prefix=/usr --buildtype=release
    ninja -C build
    sudo ninja -C build install

    cd ../neatvnc
    meson build --prefix=/usr --buildtype=release
    ninja -C build
    sudo ninja -C build install

    cd ../wayvnc
    meson build --prefix=/usr --buildtype=release
    ninja -C build
    sudo ninja -C build install

    echo "wayvnc built successfully."
}

setup_config() {

    mkdir -p ~/.config/wayvnc

    cp \
        "$SCRIPT_DIR/.config/wayvnc/config" \
        ~/.config/wayvnc/config

    echo "Config installed."
}

add_render_groups() {

    sudo usermod -aG render "$USER"
    sudo usermod -aG video "$USER"

    echo "Re-login required."
}

case "$1" in

    install)
        install
        ;;

    build_from_source)
        build_from_source
        ;;

    setup_config)
        setup_config
        ;;

    add_render_groups)
        add_render_groups
        ;;

esac
