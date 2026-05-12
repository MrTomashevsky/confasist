#!/usr/bin/env bash

# @description: Configure UART on Raspberry Pi GPIO pins
# @supported_distros: ubuntu debian raspbian
# @function: enable "Enable UART on GPIO14/GPIO15"
# @function: disable_console "Disable serial console and free ttyAMA0"
# @function: allow_user_access "Allow non-root access to ttyAMA0"
# @function: status "Show UART status"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

enable() {

    if ! grep -q "^enable_uart=1" /boot/firmware/config.txt; then
        echo "enable_uart=1" | sudo tee -a /boot/firmware/config.txt
    fi

    if ! grep -q "^dtoverlay=uart0" /boot/firmware/config.txt; then
        echo "dtoverlay=uart0" | sudo tee -a /boot/firmware/config.txt
    fi

    echo
    echo "UART enabled."
    echo "Reboot required."
}

disable_console() {

    sudo sed -i \
        's/console=serial0,[0-9]*//g' \
        /boot/firmware/cmdline.txt

    echo
    echo "Serial console disabled."
    echo "ttyAMA0 should become available after reboot."
}

allow_user_access() {

    if [[ -e /dev/ttyAMA0 ]]; then
        sudo chmod 666 /dev/ttyAMA0
        echo "Permissions updated for /dev/ttyAMA0"
    else
        echo "/dev/ttyAMA0 not found."
        echo "Reboot may be required."
    fi
}

status() {

    echo "===== UART STATUS ====="
    echo

    grep -E "enable_uart|dtoverlay=uart0" \
        /boot/firmware/config.txt || true

    echo

    ls -l /dev/ttyAMA* 2>/dev/null || true

    echo

    systemctl status serial-getty@ttyAMA0.service --no-pager || true
}

case "$1" in

    enable)
        enable
        ;;

    disable_console)
        disable_console
        ;;

    allow_user_access)
        allow_user_access
        ;;

    status)
        status
        ;;

    *)
        echo "Available functions:"
        echo "  enable"
        echo "  disable_console"
        echo "  allow_user_access"
        echo "  status"
        ;;

esac
