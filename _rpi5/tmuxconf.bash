#!/usr/bin/env bash

# @description: Cp .tmux.conf with ALT management  to $HOME
# @supported_distros: ubuntu debian raspbian arch
# @function: install "Copy .tmux.conf files"

# not testing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install() {
    TMUX_CONF="$SCRIPT_DIR/.scripts/.tmux.conf"

    if [ ! -f "$HOME/.tmux.conf" || ! cmp .tmux.conf "$TMUX_CONF" &> /dev/null ]; then
        cp "$TMUX_CONF" "$HOME/"
        echo ".tmux.conf has been copied"
    else
        echo "\033[31m .tmux.conf not copied \033[0m"
    fi
}

case "$1" in

    install)
        install
        ;;
    *)
        echo "it's not available functions"
        ;;

esac
