#!/usr/bin/env bash

# @description: Install and configure SSH server
# @supported_distros: ubuntu debian
# @function: install "Install OpenSSH server"
# @function: enable "Enable SSH service"
# @function: setup_usb_static_ip "Configure static IP for usb0"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"

setup_usb_static_ip() {

    sudo mkdir -p /etc/netplan

    sudo tee /etc/netplan/50-usb-gadget.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    usb0:
      dhcp4: no
      addresses: [192.168.7.2/24]
EOF

    sudo chmod 600 /etc/netplan/50-usb-gadget.yaml

    install_package systemd-resolved
    sudo systemctl enable --now systemd-networkd
    sudo systemctl enable --now systemd-resolved

    sudo netplan generate
    sudo netplan apply

    echo "Static IP configured."
}

install() {

    install_package openssh-server

    echo "SSH installed."
}

enable() {

    sudo systemctl enable --now ssh

    echo "SSH enabled."
}

case "$1" in

    install)
        install
        ;;

    enable)
        enable
        ;;

    setup_usb_static_ip)
        setup_usb_static_ip
        ;;

esac
