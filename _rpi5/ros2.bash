#!/usr/bin/env bash

# @description: Install ROS2 Jazzy for Ubuntu Linux
# @supported_distros: ubuntu
# @function: install "install ROS2 Jazzy, ros repo, rosdep"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.scripts/ros2repo.bash"

install() {
    echo 'Install ROS2 config'

    source "$SCRIPT_DIR/.scripts/ros2repo.bash"

    ros2jazzy_install
    rosdep_install

    echo "To test the functionality of ROS2, run it in two different terminals:

    ros2 run demo_nodes_cpp talker
    ros2 run demo_nodes_py listener
    "
}

case "$1" in
    install)
        install "${@:2}"
        ;;
    *)
        echo "Not available function"
        ;;
esac
