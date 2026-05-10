#!/usr/bin/env bash

# @description: Install and configure Sway WM
# @supported_distros: ubuntu arch
# @function: install "Install Sway and Waybar"
# @function: remove "Remove Sway"
# @function: switch_color "Change theme color"
# @arg:switch_color color "Color name"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.config/sway/sway_light_switch_color.bash"

install() {
    echo "Installing sway"

    install_package sway
    install_package waybar
    install_package foot-themes

    cp -r "$SCRIPT_DIR/.config/." "$HOME/.config/"
    sway_light_switch_color red
    echo "Sway installed"
}

remove() {
    remove_package sway
    remove_package waybar
    remove_package foot-themes
    echo "Sway removed"
}

switch_color() {
    local color="$1"
    echo "Switching theme to: $color"
    sway_light_switch_color "$color"
}

case "$1" in
    install)
        install "${@:2}"
        ;;
    remove)
        remove "${@:2}"
        ;;
    switch_color)
        switch_color "${@:2}"
        ;;
    *)
        echo "Not available function"
        ;;
esac
