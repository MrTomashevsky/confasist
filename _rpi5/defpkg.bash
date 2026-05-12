#!/usr/bin/env bash

# @description: install packages
# @supported_distros: ubuntu debian raspbian
# @function: install "Install packages"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install() {
    pkg=("sl" "pciutils" "tree" "tmux" "kate" "tig" "mpv" "shellcheck" "openssh-server" "htop" "base-devel" "git" "nano" "less" "bat" "nnn" "lf" "python3-pip" "python3" "build-essential" "linux-headers-$(uname -r)")
    for i in ${pkg[*]}; do
        if sudo apt install "$i" -y > /dev/null 2>&1; then
            echo "has been installing $i"
        else
            printf "\033[31merror $i\033[0m\n"
        fi
    done
}

case "$1" in

    install)
        install
        ;;
    *)
        echo "it's not available functions"
        ;;

esac
