
#!/usr/bin/env bash

source "$CONFASIST_LIB/distro_detect.bash"

get_package_manager() {

    local distro
    distro="$(get_distro)"

    case "$distro" in
        ubuntu|debian)
            echo "apt"
            ;;

        arch)
            echo "pacman"
            ;;

        fedora)
            echo "dnf"
            ;;

        *)
            echo "unknown"
            ;;
    esac
}

install_package() {

    local pkg="$1"

    case "$(get_package_manager)" in

        apt)
            sudo apt update
            sudo apt install -y "$pkg"
            ;;

        pacman)
            sudo pacman -Sy --noconfirm "$pkg"
            ;;

        dnf)
            sudo dnf install -y "$pkg"
            ;;

        *)
            echo "Unsupported package manager"
            return 1
            ;;

    esac
}

remove_package() {

    local pkg="$1"

    case "$(get_package_manager)" in

        apt)
            sudo apt remove -y "$pkg"
            ;;

        pacman)
            sudo pacman -R --noconfirm "$pkg"
            ;;

        dnf)
            sudo dnf remove -y "$pkg"
            ;;

    esac
}

purge_package() {

    local pkg="$1"

    case "$(get_package_manager)" in

        apt)
            sudo apt purge --auto-remove -y "$pkg"
            ;;

        pacman)
            sudo pacman -Rns --noconfirm "$pkg"
            ;;

        dnf)
            sudo dnf autoremove -y "$pkg"
            ;;

    esac
}

package_exists() {

    local pkg="$1"

    case "$(get_package_manager)" in

        apt)
            dpkg -s "$pkg" >/dev/null 2>&1
            ;;

        pacman)
            pacman -Qi "$pkg" >/dev/null 2>&1
            ;;

        dnf)
            rpm -q "$pkg" >/dev/null 2>&1
            ;;

    esac
}
