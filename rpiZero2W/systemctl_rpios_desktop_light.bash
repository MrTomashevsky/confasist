#!/usr/bin/env bash

# @description: Enable or disable default Raspberry Pi OS background services
# @supported_distros: raspberry pi os (debian bookworm)
# @function: minimal_mode "Disable unnecessary services, keep cron"
# @function: restore_full_mode "Restore previously disabled services"
# @function: status "Show current mode"

set -euo pipefail

STATE_FILE="/etc/minimal-mode.state"

# Список юнитов для отключения (DISABLE, не MASK)
# Для сокетов, таймеров, путей используем disable, т.к. mask может ломать загрузку
UNITS_TO_DISABLE=(
    user@1000.service
    plymouth-start.service
    plymouth-read-write.service
    plymouth-quit.service
    plymouth-quit-wait.service
    glamor-test.service
    rp1-test.service
    avahi-daemon.service
    avahi-daemon.socket
    bluetooth.service
    cups.service
    cups-browsed.service
    cups.socket
    cups.path
    ModemManager.service
    packagekit.service
    rpi-eeprom-update.service
    udisks2.service
    upower.service
    triggerhappy.service
    unattended-upgrades.service
    cloud-config.service
    cloud-final.service
    cloud-init-local.service
    cloud-init-network.service
    cloud-init-hotplugd.socket
    apt-daily-upgrade.timer
    apt-daily.timer
    dpkg-db-backup.timer
    e2scrub_all.timer
    fstrim.timer
    man-db.timer
    rpi-zram-writeback.timer
)

unit_exists() {
    systemctl cat "$1" &>/dev/null
}

minimal_mode() {
	for unit in "${UNITS_TO_DISABLE[@]}"; do
		printf "\033[32mDISABLING ${unit}\033[0m\n"
		sudo systemctl disable "$unit"
		sudo systemctl stop "$unit"
	done

}

restore_full_mode() {
	for unit in "${UNITS_TO_DISABLE[@]}"; do
		printf "\033[33mENABLING ${unit}\033[0m\n"

		sudo systemctl enable "$unit"
		sudo systemctl start "$unit"
	done

}

_minimal_mode() {
    if [[ -f "$STATE_FILE" ]]; then
        echo "Minimal mode already enabled. Run restore_full_mode first."
        return 1
    fi

    local current_target
    current_target="$(systemctl get-default)"
    echo "Current system target: $current_target"

    declare -a disabled_units=()

    for unit in "${UNITS_TO_DISABLE[@]}"; do
        if unit_exists "$unit"; then
            echo "Disabling: $unit"
            # disable --now останавливает и отключает автозапуск, но не маскирует
            sudo systemctl disable --now "$unit" 2>/dev/null || {
                echo "  Warning: failed to disable $unit"
                continue
            }
            # Проверяем, что юнит действительно отключён
            if ! systemctl is-enabled "$unit" 2>/dev/null | grep -q 'enabled'; then
                disabled_units+=("$unit")
            else
                echo "  Warning: $unit could not be disabled (still enabled)"
            fi
        else
            echo "Unit not found: $unit"
        fi
    done

    # Переключаемся на multi-user.target (текстовая консоль)
    if [[ "$current_target" != "multi-user.target" ]]; then
        echo "Switching default target to multi-user.target"
        sudo systemctl set-default multi-user.target
        current_target="multi-user.target"
    else
        echo "Already at multi-user.target"
    fi

    {
        echo "$current_target"
        for unit in "${disabled_units[@]}"; do
            echo "$unit"
        done
    } | sudo tee "$STATE_FILE" > /dev/null

    echo
    echo "========================================="
    echo "Minimal mode ENABLED (disabled ${#disabled_units[@]} units)"
    echo "Reboot recommended: sudo reboot"
    echo "========================================="
}

_restore_full_mode() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "Minimal mode is not enabled."
        return 1
    fi

    local original_target
    local -a disabled_units=()

    {
        read -r original_target
        while IFS= read -r unit; do
            if [[ -n "$unit" ]]; then
                disabled_units+=("$unit")
            fi
        done
    } < "$STATE_FILE"

    echo "Restoring original target: $original_target"

    for unit in "${disabled_units[@]}"; do
        echo "Restoring (enabling and starting): $unit"
        sudo systemctl enable --now "$unit" 2>/dev/null || {
            echo "  Warning: failed to restore $unit (may have been removed)"
        }
    done

    if [[ "$(systemctl get-default)" != "$original_target" ]]; then
        sudo systemctl set-default "$original_target"
    fi

    sudo rm -f "$STATE_FILE"

    echo
    echo "========================================="
    echo "Full mode RESTORED"
    echo "Reboot recommended: sudo reboot"
    echo "========================================="
}

status() {
    echo "===== SYSTEM MODE ====="
    if [[ -f "$STATE_FILE" ]]; then
        echo "Current mode: MINIMAL"
        echo "Default target: $(systemctl get-default)"
        echo
        echo "Disabled units (from state file):"
        tail -n +2 "$STATE_FILE" | sed 's/^/  /' || echo "  (none)"
    else
        echo "Current mode: FULL"
        echo "Default target: $(systemctl get-default)"
    fi
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
