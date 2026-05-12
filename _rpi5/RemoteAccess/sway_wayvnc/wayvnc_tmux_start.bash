#!/usr/bin/env bash

# @description: Start sway and wayvnc in tmux
# @function: start "Start headless sway session"

start() {

    tmux new-session -d -s sway_headless '

        export WLR_BACKENDS=headless
        export WLR_LIBINPUT_NO_DEVICES=1
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
        export WAYLAND_DISPLAY=wayland-1
        export WLR_RENDERER_ALLOW_SOFTWARE=1

        sway
    '

    tmux split-window -h '

	sleep 0.5

        export XDG_RUNTIME_DIR=/run/user/$(id -u)
        export WAYLAND_DISPLAY=wayland-1

        wayvnc 0.0.0.0 5900
    '

    tmux attach -t sway_headless
}

case "$1" in

    start)
        start
        ;;

esac
