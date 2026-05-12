#!/usr/bin/env bash

# @description: Install ROS2 Jazzy for Ubuntu Linux
# @supported_distros: ubuntu
# @function: install "install ROS2 Jazzy, ros repo, rosdep"

[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source "$SCRIPT_DIR/.scripts/ros2repo.bash"

install() {
    echo 'Install ROS2 config'

    source "$SCRIPT_DIR/.scripts/ros2repo.bash"

    #ros2jazzy_install
    # Включение репозитория Universe
    install_package software-properties-common
    sudo add-apt-repository universe -y

    update_system
    install_package curl -y
    export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
    sudo dpkg -i /tmp/ros2-apt-source.deb

    update_system
    install_package ros-jazzy-desktop

    if ! grep -qxF 'source /opt/ros/jazzy/setup.bash' ~/.bashrc; then
        echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc
    fi

    source ~/.bashrc


    #rosdep_install
    # Установка python3-rosdep и других инструментов
    update_system python3-rosdep
    update_system python3-colcon-common-extensions
    update_system ros-dev-tools
    # Инициализация (только один раз)
    sudo rosdep init

    # Обновление базы зависимостей
    rosdep update

    if ! grep -qxF "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" ~/.bashrc; then
        echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
    fi


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
