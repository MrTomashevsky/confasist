#!/usr/bin/env bash

udev_manager() {
    # Функция генерации безопасного пути к файлу правила udev
    get_rule_path() {
        local dev="$1"
        # Очистка имени от спецсимволов и перевод в нижний регистр (например, ttyAMA* -> ttyama)
        local safe_name
        safe_name=$(echo "$dev" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
        echo "/etc/udev/rules.d/99-${safe_name}-permissions.rules"
    }

    # Функция применения правил udev
    reload_udev() {
        echo "Применение изменений в udev..."
        sudo udevadm control --reload-rules && sudo udevadm trigger
    }

    # ФУНКЦИЯ 1: Создание и применение правила
    set_udev() {
        local device="$1"
        local mode="$2"

        if [ -z "$device" ] || [ -z "$mode" ]; then
            echo "Ошибка [set_udev]: Не указано устройство или права."
            return 1
        fi

        if [[ ! "$mode" =~ ^[0-7]{3,4}$ ]]; then
            echo "Ошибка [set_udev]: Права должны быть в формате 644 или 0644."
            return 1
        fi

        local rule_file
        rule_file=$(get_rule_path "$device")
        local rule_content="KERNEL==\"${device}\", MODE=\"${mode}\""

        echo "Создание правила для '$device' с правами '$mode'..."
        echo "$rule_content" | sudo tee "$rule_file" > /dev/null

        if [ $? -eq 0 ]; then
            echo "Успешно: Правило записано в $rule_file"
            reload_udev
        else
            echo "Ошибка: Не удалось записать файл."
            return 1
        fi
    }

    # ФУНКЦИЯ 2: Удаление правила
    remove_udev() {
        local device="$1"

        if [ -z "$device" ]; then
            echo "Ошибка [remove_udev]: Не указано устройство для удаления."
            return 1
        fi

        local rule_file
        rule_file=$(get_rule_path "$device")

        if [ -f "$rule_file" ]; then
            echo "Удаление файла правила: $rule_file"
            sudo rm "$rule_file"
            reload_udev
            echo "Правило для устройства '$device' успешно удалено."
        else
            echo "Предупреждение: Файл правила $rule_file не найден. Удалять нечего."
        fi
    }

    # --- Блок обработки аргументов командной строки ---
    print_usage() {
        echo "Использование:"
        echo "  $0 set <устройство> <права>   - Создать/обновить правило"
        echo "  $0 remove <устройство>         - Удалить правило"
        echo ""
        echo "Примеры:"
        echo "  $0 set \"ttyAMA*\" 644"
        echo "  $0 remove \"ttyAMA*\""
    }

    COMMAND="$1"

    case "$COMMAND" in
        set)
            set_udev "$2" "$3"
            ;;
        remove)
            remove_udev "$2"
            ;;
        *)
            print_usage
		echo Args \'$1\' \'$2\' \'$3\'
            exit 1
            ;;
    esac
}
