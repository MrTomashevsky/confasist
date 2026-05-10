#!/usr/bin/env bash
# sway_light_switch_color.bash - переключает цветовую тему Sway/Waybar/PS1

sway_light_switch_color() {

    set -euo pipefail

    # Проверка аргумента
    if [ $# -ne 1 ]; then
        echo "Использование: $0 {red|green|amber|blue|purple|slate}"
        exit 1
    fi

    COLOR="$1"
    VALID_COLORS="red green amber blue purple slate"

    if [[ ! " $VALID_COLORS " =~ " $COLOR " ]]; then
        echo "Ошибка: цвет '$COLOR' недопустим. Допустимые: $VALID_COLORS"
        exit 1
    fi

    # Пути (предполагается, что скрипт запускается из домашней директории или ~/.config/sway)
    SWAY_DIR="$HOME/.config/sway"
    WAYBAR_DIR="$HOME/.config/waybar"

    # Источники
    IMAGE_SRC="$SWAY_DIR/images/${COLOR}_image.png"
    FRAME_SRC="$SWAY_DIR/settings_frame_color/$COLOR"
    WAYBAR_STYLE_SRC="$WAYBAR_DIR/settings_style/${COLOR}.css"
    PS1_SRC="$SWAY_DIR/bashrc_PS1_colors/.${COLOR}_bashrc_PS1_color"

    # Назначения
    IMAGE_DST="$SWAY_DIR/image.png"
    FRAME_DST="$SWAY_DIR/frame_color"
    WAYBAR_STYLE_DST="$WAYBAR_DIR/style.css"
    PS1_DST="$HOME/.bashrc_PS1_color"

    # Копирование
    cp "$IMAGE_SRC" "$IMAGE_DST"
    cp "$FRAME_SRC" "$FRAME_DST"
    cp "$WAYBAR_STYLE_SRC" "$WAYBAR_STYLE_DST"
    cp "$PS1_SRC" "$PS1_DST"

    # # Перезагрузка Sway (чтобы применить новые обои и рамки)
    # swaymsg reload
    #
    # # Перезагрузка Waybar (если запущен)
    # killall -SIGUSR1 waybar 2>/dev/null || true

    echo "Тема '$COLOR' успешно применена. PS1 будет обновлён при следующем запуске bash."

}

