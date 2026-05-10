#!/usr/bin/env bash

# @description: Configure Raspberry Pi USB Ethernet Gadget
# @supported_distros: ubuntu debian
# @function: install "Enable USB gadget Ethernet mode"
# @function: remove "Disable USB gadget Ethernet mode"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/use_root.bash"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install() {

    sudo sed -i \
        's/dtoverlay=dwc2,dr_mode=host/#dtoverlay=dwc2,dr_mode=host/g' \
        /boot/firmware/config.txt

    if ! grep -q "dtoverlay=dwc2,dr_mode=peripheral" /boot/firmware/config.txt; then
        echo "dtoverlay=dwc2,dr_mode=peripheral" | sudo tee -a /boot/firmware/config.txt
    fi

    if ! grep -q "modules-load=dwc2,g_ether" /boot/firmware/cmdline.txt; then
        sudo sed -i \
            's/rootwait/rootwait modules-load=dwc2,g_ether/g' \
            /boot/firmware/cmdline.txt
    fi

    echo
    echo "USB gadget mode configured."
    echo "Reboot required."
}

remove() {

    sudo sed -i \
        's/^dtoverlay=dwc2,dr_mode=peripheral/#dtoverlay=dwc2,dr_mode=peripheral/g' \
        /boot/firmware/config.txt

    sudo sed -i \
        's/modules-load=dwc2,g_ether//g' \
        /boot/firmware/cmdline.txt

    echo "USB gadget mode removed."
}

case "$1" in

    install)
        install
        ;;

    remove)
        remove
        ;;

esac
