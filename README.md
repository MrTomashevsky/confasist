# confasist

**Linux Configure Assistant**

TUI-утилита для конфигурирования Linux-систем через древовидное меню и bash-скрипты.

`confasist` автоматически строит меню на основе структуры каталогов и `.bash` файлов рядом с исполняемым файлом, а затем позволяет запускать функции из этих скриптов через удобный интерфейс в стиле `raspi-config`.

---

# Возможности

- Динамическое построение меню из файловой структуры
- Поддержка вложенных каталогов
- Автоматический парсинг metadata из bash-скриптов
- Выполнение bash-функций через TUI
- Передача аргументов через диалоги
- Поддержка совместимости дистрибутивов
- Подсветка неподдерживаемых скриптов
- Запуск без TUI через CLI
- Генерация новых скриптов
- Библиотека общих bash-функций
- Абсолютные пути и portable execution
- Интерфейс в стиле raspi-config/newt/whiptail

---

# Скриншот (идея)

```text
┌──────────────── Linux Configure Assistant ────────────────┐
│ Distro: ubuntu | Arch: aarch64                           │
├───────────────────────────────────────────────────────────┤
│                                                           │
│   GraphicalEnvironments                                   │
│   RemoteAccess                                            │
│   Hardware                                                │
│   System                                                  │
│                                                           │
├───────────────────────────────────────────────────────────┤
│         <Select>                     <Back>               │
└───────────────────────────────────────────────────────────┘
````

---

# Зависимости

## Ubuntu / Debian

```bash
sudo apt install whiptail
```

## Arch Linux

```bash
sudo pacman -S libnewt
```

## Fedora

```bash
sudo dnf install newt
```

---

# Установка

```bash
git clone <repo>
cd confasist

chmod +x confasist
chmod +x .bash_lib/*.bash

find . -name "*.bash" -exec chmod +x {} \;
```

---

# Быстрый старт

## Запуск TUI

```bash
./confasist
```

---

## Выполнение функции напрямую

```bash
./confasist -r sway_light install
```

---

## Передача аргументов

```bash
./confasist -r sway_light switch_color blue
```

---

## Создание нового скрипта

```bash
./confasist --new hyprland --desc "Install Hyprland" --distros arch
```

---

# Структура проекта

Пример:

```text
confasist/
├── confasist
├── .bash_lib/
│   ├── distro_detect.bash
│   ├── hardware_detect.bash
│   ├── pkg_manager.bash
│   └── use_root.bash
│
├── GraphicalEnvironments/
│   └── sway/
│       ├── sway_light.bash
│       └── .config/
│
├── RemoteAccess/
│   ├── usb_gadget/
│   ├── ssh/
│   └── sway_wayvnc/
│
├── Hardware/
│   └── uart/
│
└── System/
    └── services/
```

---

# Как работает меню

`confasist` рекурсивно обходит каталог проекта:

* каждая папка → подменю
* каждый `.bash` файл → пункт скрипта
* каждая `@function` → отдельный запускаемый пункт

---

# Формат bash-скриптов

Каждый скрипт содержит metadata-комментарии.

Пример:

```bash
#!/usr/bin/env bash

# @description: Install sway WM
# @supported_distros: ubuntu arch
# @function: install "Install sway"
# @function: remove "Remove sway"
# @function: switch_color "Switch color theme"
# @arg:switch_color color "Theme color"

install() {
    echo "Installing sway..."
}

remove() {
    echo "Removing sway..."
}

switch_color() {
    local color="$1"

    echo "Color: $color"
}

case "$1" in

    install)
        install "${@:2}"
        ;;

    remove)
        remove "${@:2}"
        ;;

    switch_color)
        switch_color "${@:2}"
        ;;

esac
```

---

# Metadata

## Описание скрипта

```bash
# @description: Install sway WM
```

Показывается в меню.

---

## Поддерживаемые дистрибутивы

```bash
# @supported_distros: ubuntu arch
```

Если текущий дистрибутив не поддерживается:

* скрипт помечается как unsupported
* пользователь получает предупреждение перед запуском

---

## Объявление функций

```bash
# @function: install "Install sway"
```

Функция появляется в TUI.

---

## Аргументы функции

```bash
# @arg:switch_color color "Theme color"
```

`confasist` автоматически создаст input dialog.

---

# Библиотека `.bash_lib`

`confasist` экспортирует:

```bash
CONFASIST_LIB
```

Внутри скриптов:

```bash
[ -n "$CONFASIST_LIB" ] && source "$CONFASIST_LIB/pkg_manager.bash"
```

---

# Встроенные библиотеки

## distro_detect.bash

Определение дистрибутива:

```bash
get_distro
```

Возвращает:

```text
ubuntu
arch
debian
fedora
```

---

## hardware_detect.bash

Определение архитектуры:

```bash
get_architecture
```

Пример:

```text
x86_64
aarch64
armv7l
```

---

## pkg_manager.bash

Универсальная работа с пакетными менеджерами.

### Установка пакета

```bash
install_package git
```

### Удаление

```bash
remove_package git
```

### Проверка

```bash
package_exists git
```

Поддерживаются:

* apt
* pacman
* dnf

---

## use_root.bash

Запрос root-прав:

```bash
require_root
```

---

# Работа с путями

Во всех скриптах рекомендуется:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

Это гарантирует корректную работу независимо от текущего `pwd`.

---

# Работа с конфигами

Пример:

```bash
cp -r "$SCRIPT_DIR/.config/." "$HOME/.config/"
```

---

# Выполнение функций

При выборе функции:

1. `confasist` собирает аргументы
2. вызывает:

```bash
/bin/bash <script> <function> [args]
```

3. отображает stdout/stderr
4. возвращает пользователя обратно в меню

---

# Навигация

| Клавиша | Действие     |
| ------- | ------------ |
| ↑ ↓     | Навигация    |
| Enter   | Выбор        |
| Esc     | Назад        |
| Tab     | Переключение |
| Q       | Выход        |

---

# Поддержка дистрибутивов

Скрипты могут ограничивать запуск:

```bash
# @supported_distros: ubuntu
```

Если система несовместима:

```text
[UNSUPPORTED: ubuntu]
```

---

# Пример меню функций

```text
sway_light
├── install
├── remove
└── switch_color
```

---

# Пример helper script

```bash
#!/usr/bin/env bash

# @description: Configure UART
# @supported_distros: ubuntu debian raspbian
# @function: enable "Enable UART"
# @function: status "Show UART status"

enable() {
    echo "UART enabled"
}

status() {
    ls -l /dev/ttyAMA*
}

case "$1" in

    enable)
        enable
        ;;

    status)
        status
        ;;

esac
```

---

# Рекомендации

## Используйте абсолютные пути

Плохо:

```bash
bash .config/script.bash
```

Хорошо:

```bash
bash "$SCRIPT_DIR/.config/script.bash"
```

---

## Используйте metadata

Не создавайте hidden functions без `@function`.

---

## Делайте скрипты идемпотентными

Плохо:

```bash
echo "option=true" >> config
```

Лучше:

```bash
grep -q "option=true" config || echo "option=true" >> config
```

---

# Возможности для будущего развития

* Цветные темы
* Lua plugin API
* YAML metadata
* JSON metadata
* Search menu
* Fuzzy finder
* Async execution
* Logs viewer
* systemd integration
* Auto-generated docs
* Remote repository support
* Package collections
* Built-in backups
* Transaction rollback
* Localization

---

# Пример реальных use-cases

## Raspberry Pi setup

* USB gadget Ethernet
* SSH
* VNC
* sway + wayvnc
* UART
* GPIO

---

## Desktop setup

* sway
* Hyprland
* KDE Plasma
* Waybar
* Kitty
* Zsh

---

## System optimization

* Minimal services mode
* Power tuning
* CPU governor
* Logging tweaks

---

# Безопасность

`confasist` выполняет bash-скрипты с системными правами.

Используйте только доверенные скрипты.

Всегда проверяйте:

* `sudo`
* `rm -rf`
* `chmod`
* `systemctl`
* `curl | bash`

---

# Лицензия

MIT License

---

# Автор

Linux Configure Assistant / confasist

```

