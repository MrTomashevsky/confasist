#!/usr/bin/env bash

# @description: Enable or disable default Raspberry Pi OS background services
# @supported_distros: raspberry pi os (debian bookworm)
# @function: minimal_mode "Disable unnecessary services, keep cron"
# @function: restore_full_mode "Restore previously disabled services"
# @function: status "Show current mode"

set -euo pipefail

STATE_FILE="/etc/minimal-mode.state"

UNITS_TO_DISABLE=(
    # Graphic / display manager
    lightdm.service
    plymouth-quit-wait.service
    plymouth-read-write.service
    plymouth-start.service
    glamor-test.service
    rp1-test.service

    # Network discovery / printing / bluetooth / modems
    avahi-daemon.service
    avahi-daemon.socket
    bluetooth.service
    cups.service
    cups-browsed.service
    cups.socket
    cups.path
    ModemManager.service

    # System services not needed in terminal mode
    alsa-restore.service
    packagekit.service
    rpi-eeprom-update.service
    udisks2.service
    upower.service
    triggerhappy.service
    unattended-upgrades.service
    systemd-timesyncd.service   # optional, safe to keep; disable if you don't need NTP

    # Cloud init (not used on bare metal)
    cloud-config.service
    cloud-final.service
    cloud-init-local.service
    cloud-init-network.service
    cloud-init-hotplugd.socket

    # Timers (maintenance tasks, logs, temp files)
    apt-daily-upgrade.timer
    apt-daily.timer
    dpkg-db-backup.timer
    e2scrub_all.timer
    fstrim.timer
    logrotate.timer
    man-db.timer
    systemd-tmpfiles-clean.timer
    rpi-zram-writeback.timer
)

minimal_mode() {

    if [[ -f "$STATE_FILE" ]]; then
        echo "Minimal mode already enabled."
        return
    fi

    local current_target
    current_target="$(systemctl get-default)"

    echo "Current target: $current_target"

    local disabled_units=()

    for unit in "${UNITS_TO_DISABLE[@]}"; do

        if systemctl list-unit-files | grep -q "^$unit"; then

            echo "Disabling: $unit"

            sudo systemctl disable --now "$unit" 2>/dev/null || true

            disabled_units+=("$unit")

        else

            echo "Not found: $unit"

        fi
    done

    sudo systemctl set-default multi-user.target

    {
        echo "$current_target"
        printf '%s\n' "${disabled_units[@]}"
    } | sudo tee "$STATE_FILE" > /dev/null

    echo
    echo "===================================="
    echo "Minimal mode enabled."
    echo "Reboot recommended."
    echo "===================================="
}

restore_full_mode() {

    if [[ ! -f "$STATE_FILE" ]]; then
        echo "Minimal mode is not enabled."
        return
    fi

    local original_target
    local disabled_units=()

    {
        read -r original_target

        while IFS= read -r line; do
            disabled_units+=("$line")
        done

    } < "$STATE_FILE"

    echo "Restoring target: $original_target"

    for unit in "${disabled_units[@]}"; do

        echo "Restoring: $unit"

        sudo systemctl enable --now "$unit" 2>/dev/null || true
    done

    sudo systemctl set-default "$original_target"

    sudo rm -f "$STATE_FILE"

    echo
    echo "===================================="
    echo "Full mode restored."
    echo "Reboot recommended."
    echo "===================================="
}

status() {

    echo "===== SYSTEM MODE ====="
    echo

    if [[ -f "$STATE_FILE" ]]; then
        echo "Current mode: MINIMAL"
    else
        echo "Current mode: FULL"
    fi

    echo
    echo "Default target:"
    systemctl get-default
}

case "$1" in

    minimal_mode)
        minimal_mode
        ;;

    restore_full_mode)
        restore_full_mode
        ;;

    status)
        status
        ;;

    *)
        echo "Available functions:"
        echo "  minimal_mode"
        echo "  restore_full_mode"
        echo "  status"
        ;;

esac
