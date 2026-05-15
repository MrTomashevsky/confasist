#!/usr/bin/env bash

# @description: Raspberry Pi OV5647 camera setup for Ubuntu 24.04 + libcamera + rpicam-apps
# @supported_distros: ubuntu
# @function: configure_boot "Configure config.txt for OV5647 camera"
# @function: install_dependencies "Install build dependencies"
# @function: build_libcamera "Build libcamera from source"
# @arg:build_libcamera USE_LAST "true = latest commits, false = use tested tag v0.7.1"
# @function: build_rpicam "Build rpicam-apps from source"
# @arg:build_rpicam USE_LAST "true = latest commits, false = use tested tag v1.12.0"
# @function: setup_ld_library_path "Add LD_LIBRARY_PATH to bashrc"
# @function: test_camera "Run rpicam-hello"
# @function: install_camera_ros "Install ROS2 camera_ros package"

set -euo pipefail

[ -n "${CONFASIST_LIB:-}" ] && source "$CONFASIST_LIB/pkg_manager.bash"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

########################################
# Configure boot
########################################

configure_boot() {

    sudo cp /boot/firmware/config.txt /boot/firmware/config.txt.bak

    sudo bash -c 'cat >> /boot/firmware/config.txt <<EOF

# ===== OV5647 CAMERA =====
camera_auto_detect=0
dtoverlay=ov5647,cam0
dtparam=i2c_csi_dsi0=on
gpio=5=op,dh
# =========================

EOF'

    echo "[!] config.txt updated"
    echo "[!] reboot required"
}

########################################
# Install dependencies
########################################

install_dependencies() {

    update_system

    packages=(
        git
        cmake
        meson
        ninja-build
        pkg-config
        python3-pip
        python3-yaml
        python3-jinja2
        python3-ply
        libboost-dev
        libboost-program-options-dev
        libboost-system-dev
        libdrm-dev
        libexif-dev
        libepoxy-dev
        libpng-dev
        libpng-tools
        libavcodec-dev
        libavdevice-dev
        libavformat-dev
        libswresample-dev
        libjpeg-dev
        libtiff5-dev
        libssl-dev
        libyaml-dev
        libudev-dev
        libatomic1
        libgtest-dev
        openssl
        ffmpeg
        qt5-qmake
        qtmultimedia5-dev
        gstreamer1.0-tools
        libgstreamer1.0-dev
        libgstreamer-plugins-base1.0-dev
        i2c-tools
        libcap-dev
    )

    for pkg in "${packages[@]}"; do
        install_package "$pkg"
    done
}

########################################
# Build libcamera
########################################

build_libcamera() {

    local USE_LAST="${1:-false}"

    cd ~

    if [[ ! -d libcamera ]]; then
        git clone https://github.com/raspberrypi/libcamera.git
    fi

    cd ~/libcamera

    git fetch --tags

    if [[ "$USE_LAST" == "false" ]]; then
        git checkout v0.7.1
    else
        git checkout main || git checkout master
        git pull
    fi

    rm -rf build

    meson setup build --reconfigure \
        -Dpipelines=rpi/vc4,rpi/pisp \
        -Dipas=rpi/vc4,rpi/pisp \
        -Dv4l2=enabled \
        -Dcam=enabled \
        -Dqcam=disabled

    ninja -C build

    sudo ninja -C build install

    sudo ldconfig

    echo "[!] libcamera build complete"
}

########################################
# Build rpicam-apps
########################################

build_rpicam() {

    local USE_LAST="${1:-false}"

    cd ~

    if [[ ! -d rpicam-apps ]]; then
        git clone https://github.com/raspberrypi/rpicam-apps.git
    fi

    cd ~/rpicam-apps

    git fetch --tags

    if [[ "$USE_LAST" == "false" ]]; then
        git checkout v1.12.0
    else
        git checkout main || git checkout master
        git pull
    fi

    rm -rf build

    meson setup build --reconfigure \
        -Denable_libav=disabled \
        -Denable_drm=enabled \
        -Denable_egl=enabled \
        -Denable_qt=enabled \
        -Denable_opencv=disabled \
        -Denable_tflite=disabled

    ninja -C build

    sudo ninja -C build install

    echo "[!] rpicam-apps build complete"
}

########################################
# Setup LD_LIBRARY_PATH
########################################

setup_ld_library_path() {

    local LINE='export LD_LIBRARY_PATH="/usr/local/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH"'

    if ! grep -Fq "$LINE" ~/.bashrc; then
        echo "$LINE" >> ~/.bashrc
    fi

    export LD_LIBRARY_PATH="/usr/local/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH"

    echo "[!] LD_LIBRARY_PATH configured"
}

########################################
# Test camera
########################################

test_camera() {

    rpicam-hello --list-cameras

    echo
    echo "[!] starting preview..."
    echo

    rpicam-hello
}

########################################
# Install ROS2 camera_ros
########################################

install_camera_ros() {

    install_package ros-jazzy-cv-bridge
    install_package ros-jazzy-image-transport

    mkdir -p ~/camera_ws/src

    source /opt/ros/jazzy/setup.bash

    cd ~/camera_ws/src

    if [[ ! -d camera_ros ]]; then
        git clone https://github.com/christianrauch/camera_ros.git
    fi

    cd ~/camera_ws

    rosdep install \
        --from-paths src \
        --ignore-src \
        --skip-keys=libcamera \
        -y

    colcon build --packages-select camera_ros

    echo
    echo "[!] build complete"
    echo
    echo "run:"
    echo "source ~/camera_ws/install/setup.bash"
    echo "ros2 run camera_ros camera_node --ros-args -p camera:=0"
}

########################################
# Entrypoint
########################################

case "${1:-}" in

    configure_boot)
        configure_boot
        ;;

    install_dependencies)
        install_dependencies
        ;;

    build_libcamera)
        build_libcamera "${2:-false}"
        ;;

    build_rpicam)
        build_rpicam "${2:-false}"
        ;;

    setup_ld_library_path)
        setup_ld_library_path
        ;;

    test_camera)
        test_camera
        ;;

    install_camera_ros)
        install_camera_ros
        ;;

    *)
        echo "Available functions:"
        echo "  configure_boot"
        echo "  install_dependencies"
        echo "  build_libcamera [USE_LAST]"
        echo "  build_rpicam [USE_LAST]"
        echo "  setup_ld_library_path"
        echo "  test_camera"
        echo "  install_camera_ros"
        ;;
esac
