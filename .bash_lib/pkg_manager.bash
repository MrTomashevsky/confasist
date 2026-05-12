#!/usr/bin/env bash

# @description: Unified package manager functions with manual spinner and real error output
# @supported_distros: ubuntu debian arch fedora raspbian
# @function: install_package "Install a package with spinner"
# @function: remove_package "Remove a package with spinner"
# @function: package_exists "Check if package is installed"
# @function: update_system "Update system packages with spinner"

set -euo pipefail

# Detect package manager
detect_pkg_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

PKG_MANAGER="$(detect_pkg_manager)"

# Check if package exists
package_exists() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        apt)
            dpkg -s "$pkg" >/dev/null 2>&1
            ;;
        pacman)
            pacman -Q "$pkg" >/dev/null 2>&1
            ;;
        dnf)
            rpm -q "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

install_package() {
    local pkg="$1"
    local cmd

    case "$PKG_MANAGER" in
        apt)
            cmd=("sudo" "apt" "install" "-y" "$pkg")
            ;;
        pacman)
            cmd=("sudo" "pacman" "-S" "--noconfirm" "$pkg")
            ;;
        dnf)
            cmd=("sudo" "dnf" "install" "-y" "$pkg")
            ;;
        *)
            printf "\033[31m[x] Unknown package manager, cannot install %s\033[0m\n" "$pkg"
            return 1
            ;;
    esac

    local tmpfile
    tmpfile=$(mktemp)
    "${cmd[@]}" >"$tmpfile" 2>&1 &
    local pid=$!

    local spin='-\|/'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r[%s] installing %s..." "${spin:i++%${#spin}:1}" "$pkg"
        sleep 0.1
    done

    wait "$pid"
    local status=$?

    if [[ $status -eq 0 ]]; then
        printf "\r[\033[32m!\033[0m] installation was successful %s\n" "$pkg"
    else
        printf "\r[\033[31mx\033[0m] error installing %s\n" "$pkg"
        cat "$tmpfile"
    fi
    rm -f "$tmpfile"
}

remove_package() {
    local pkg="$1"
    local cmd

    case "$PKG_MANAGER" in
        apt)
            cmd=("sudo" "apt" "remove" "-y" "$pkg")
            ;;
        pacman)
            cmd=("sudo" "pacman" "-R" "--noconfirm" "$pkg")
            ;;
        dnf)
            cmd=("sudo" "dnf" "remove" "-y" "$pkg")
            ;;
        *)
            printf "\033[31m[x] Unknown package manager, cannot remove %s\033[0m\n" "$pkg"
            return 1
            ;;
    esac

    local tmpfile
    tmpfile=$(mktemp)
    "${cmd[@]}" >"$tmpfile" 2>&1 &
    local pid=$!

    local spin='-\|/'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r[%s] removing %s..." "${spin:i++%${#spin}:1}" "$pkg"
        sleep 0.1
    done

    wait "$pid"
    local status=$?

    if [[ $status -eq 0 ]]; then
        printf "\r[\033[32m!\033[0m] removal successful %s\n" "$pkg"
    else
        printf "\r[\033[31mx\033[0m] error removing %s\n" "$pkg"
        cat "$tmpfile"
    fi
    rm -f "$tmpfile"
}

update_system() {
    case "$PKG_MANAGER" in
        apt)
            local tmpfile
            tmpfile=$(mktemp)
            # update
            sudo apt update -y >"$tmpfile" 2>&1 &
            local pid=$!
            local spin='-\|/'
            local i=0
            while kill -0 "$pid" 2>/dev/null; do
                printf "\r[%s] updating package list..." "${spin:i++%${#spin}:1}"
                sleep 0.1
            done
            wait "$pid"
            local status=$?
            if [[ $status -eq 0 ]]; then
                printf "\r[\033[32m!\033[0m] package list updated\n"
            else
                printf "\r[\033[31mx\033[0m] error updating package list\n"
                cat "$tmpfile"
            fi

            # upgrade
            sudo apt upgrade -y >"$tmpfile" 2>&1 &
            pid=$!
            i=0
            while kill -0 "$pid" 2>/dev/null; do
                printf "\r[%s] upgrading packages..." "${spin:i++%${#spin}:1}"
                sleep 0.1
            done
            wait "$pid"
            status=$?
            if [[ $status -eq 0 ]]; then
                printf "\r[\033[32m!\033[0m] packages upgraded\n"
            else
                printf "\r[\033[31mx\033[0m] error upgrading packages\n"
                cat "$tmpfile"
            fi
            rm -f "$tmpfile"
            ;;
        pacman)
            tmpfile=$(mktemp)
            sudo pacman -Syu --noconfirm >"$tmpfile" 2>&1 &
            pid=$!
            spin='-\|/'
            i=0
            while kill -0 "$pid" 2>/dev/null; do
                printf "\r[%s] updating system (pacman)..." "${spin:i++%${#spin}:1}"
                sleep 0.1
            done
            wait "$pid"
            status=$?
            if [[ $status -eq 0 ]]; then
                printf "\r[\033[32m!\033[0m] system updated\n"
            else
                printf "\r[\033[31mx\033[0m] error updating system\n"
                cat "$tmpfile"
            fi
            rm -f "$tmpfile"
            ;;
        dnf)
            tmpfile=$(mktemp)
            sudo dnf upgrade -y >"$tmpfile" 2>&1 &
            pid=$!
            spin='-\|/'
            i=0
            while kill -0 "$pid" 2>/dev/null; do
                printf "\r[%s] updating system (dnf)..." "${spin:i++%${#spin}:1}"
                sleep 0.1
            done
            wait "$pid"
            status=$?
            if [[ $status -eq 0 ]]; then
                printf "\r[\033[32m!\033[0m] system updated\n"
            else
                printf "\r[\033[31mx\033[0m] error updating system\n"
                cat "$tmpfile"
            fi
            rm -f "$tmpfile"
            ;;
        *)
            printf "\033[31m[x] Unknown package manager, cannot update system\033[0m\n"
            return 1
            ;;
    esac
}
