ros2jazzy_install() {
    # Включение репозитория Universe
    sudo apt install -y software-properties-common
    sudo add-apt-repository universe -y

    sudo apt update && sudo apt install curl -y
    export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
    sudo dpkg -i /tmp/ros2-apt-source.deb

    sudo apt update
    sudo apt upgrade -y # Рекомендуется обновить систему перед установкой
    sudo apt install ros-jazzy-desktop -y

    if ! grep -qxF 'source /opt/ros/jazzy/setup.bash' ~/.bashrc; then
        echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc
    fi

    source ~/.bashrc

    # ros2 run demo_nodes_cpp talker
    # ros2 run demo_nodes_py listener

}

rosdep_install() {

    # Установка python3-rosdep и других инструментов
    sudo apt install python3-rosdep python3-colcon-common-extensions ros-dev-tools -y
    # Инициализация (только один раз)
    sudo rosdep init

    # Обновление базы зависимостей
    rosdep update

    if ! grep -qxF "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" ~/.bashrc; then
        echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
    fi

}

