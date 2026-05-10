Настройка **Waybar** зависит от ваших потребностей: стиль, модули, расположение, цвета и т. д.  
Приведу **базовую настройку** (под Hyprland) с популярными модулями: **рабочие области, часы, батарея, сеть, звук, заглушка микрофона, системные ресурсы (CPU, RAM), пользовательское меню**.

---

### 1. **Стандартная конфигурация Waybar**
Файлы конфигурации обычно лежат в:
- `~/.config/waybar/config` – основной конфиг  
- `~/.config/waybar/style.css` – стили (цвета, шрифты, анимации)  

#### **`~/.config/waybar/config`** (основные модули)
```json
{
  "layer": "top",
  "position": "top",
  "height": 30,
  "spacing": 4,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": [
    "pulseaudio",
    "pulseaudio#microphone",
    "network",
    "cpu",
    "memory",
    "battery",
    "tray",
    "custom/power"
  ],

  // Модуль рабочих пространств Hyprland
  "hyprland/workspaces": {
    "format": "{icon}",
    "on-click": "activate",
    "active-only": false,
    "format-icons": {
      "1": "",
      "2": "",
      "3": "",
      "4": "",
      "5": "",
      "urgent": "",
      "default": ""
    }
  },

  // Модуль активного окна
  "hyprland/window": {
    "max-length": 50,
    "separator": false,
    "rewrite": { "": "No active window" }
  },

  // Часы
  "clock": {
    "format": "{:%H:%M | %d.%m.%Y}",
    "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
  },

  // Звук
  "pulseaudio": {
    "format": "{icon} {volume}%",
    "format-muted": " 0%",
    "format-icons": {
      "default": ["", "", ""]
    },
    "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle",
    "on-click-right": "pavucontrol"
  },

  // Микрофон
  "pulseaudio#microphone": {
    "format": "{format_source}",
    "format-source": " {volume}%",
    "format-source-muted": " 0%",
    "on-click": "pactl set-source-mute @DEFAULT_SOURCE@ toggle"
  },

  // Сеть
  "network": {
    "format-wifi": " {essid} ({signalStrength}%)",
    "format-ethernet": " Connected",
    "format-disconnected": " No internet",
    "on-click": "nm-connection-editor"
  },

  // CPU
  "cpu": {
    "format": " {usage}%",
    "interval": 2
  },

  // Оперативная память
  "memory": {
    "format": " {used:0.1f}G/{total:0.1f}G",
    "interval": 5
  },

  // Батарея
  "battery": {
    "states": {
      "good": 95,
      "warning": 30,
      "critical": 15
    },
    "format": "{icon} {capacity}%",
    "format-charging": " {capacity}%",
    "format-plugged": " {capacity}%",
    "format-alt": "{time} {icon}",
    "format-icons": ["", "", "", "", ""]
  },

  // Кнопка выключения
  "custom/power": {
    "format": "",
    "on-click": "wlogout",
    "tooltip": false
  },

  // Системный трей (иконки приложений)
  "tray": {
    "spacing": 8,
    "icon-size": 16
  }
}
```

---

### 2. **Стилизация (`~/.config/waybar/style.css`)**
```css
* {
  font-family: "JetBrains Mono", "Fira Code", monospace;
  font-size: 12px;
}

window#waybar {
  background-color: rgba(26, 27, 38, 0.8);
  color: #e0e0e0;
  border-bottom: 1px solid #1a1b26;
}

#workspaces button {
  color: #7aa2f7;
  padding: 0 5px;
  margin: 2px;
  border-radius: 4px;
  background: transparent;
}

#workspaces button.active {
  color: #bb9af7;
  background: rgba(120, 120, 150, 0.2);
}

#workspaces button.urgent {
  color: #f7768e;
}

#clock, #battery, #cpu, #memory, #pulseaudio, #network, #tray {
  padding: 0 8px;
  margin: 0 2px;
  border-radius: 4px;
  background: rgba(40, 42, 54, 0.6);
}

#custom-power {
  padding: 0 12px;
  margin-right: 4px;
  background: rgba(40, 42, 54, 0.6);
  color: #f7768e;
}
```

---

### 3. **Автозапуск Waybar (в `~/.config/hypr/hyprland.conf`)**
```ini
exec-once = waybar
```

---

### 4. **Дополнительные настройки**
- **Шрифты**: Убедитесь, что у вас установлены `JetBrains Mono Nerd Font` или `Fira Code` (или замените в `style.css`).  
- **Иконки**: Нужны **Nerd Fonts** (установите через пакетный менеджер).  
- **wlogout**: Если хотите кнопку выключения (`sudo pacman -S wlogout` в Arch).  
- **pavucontrol**: Для управления звуком (`pavucontrol`).  

---

### 5. **Перезапуск Waybar**
```bash
killall waybar && waybar & disown
```

---

### Итог:
- **Сверху** – рабочие области, активное окно.  
- **По центру** – часы.  
- **Справа** – звук, сеть, CPU, RAM, батарея, кнопка выключения.  
- **Стиль** – тёмный полупрозрачный с акцентами.  

Можно кастомизировать модули, цвета и расположение под себя.













# Полный конфиг Waybar с подробными комментариями

## Основной конфигурационный файл (~/.config/waybar/config)

```json
{
  // Базовые настройки панели
  "layer": "top",          // Расположение слоя (top/bottom)
  "position": "top",       // Позиция на экране (top/bottom/left/right)
  "height": 30,            // Высота панели в пикселях
  "margin-top": 0,         // Отступ сверху
  "margin-bottom": 0,      // Отступ снизу
  "margin-left": 0,        // Отступ слева
  "margin-right": 0,       // Отступ справа
  "spacing": 4,            // Расстояние между модулями
  
  // Распределение модулей по зонам панели
  "modules-left": [
    "hyprland/workspaces", // Рабочие пространства Hyprland
    "hyprland/window"      // Окно активного приложения
  ],
  "modules-center": [
    "clock"               // Часы по центру
  ],
  "modules-right": [
    "pulseaudio",         // Управление звуком
    "pulseaudio#microphone", // Управление микрофоном
    "network",            // Состояние сети
    "cpu",                // Загрузка процессора
    "memory",             // Использование памяти
    "battery",            // Состояние батареи
    "tray",               // Системный трей
    "custom/power"        // Кнопка выключения
  ],

  // Настройка модуля рабочих пространств
  "hyprland/workspaces": {
    "format": "{icon}",                   // Формат отображения (только иконки)
    "on-click": "activate",               // Действие по клику - переключение
    "on-scroll-up": "hyprctl dispatch workspace e+1",  // Прокрутка вверх - след. workspace
    "on-scroll-down": "hyprctl dispatch workspace e-1", // Прокрутка вниз - пред. workspace
    "active-only": false,                 // Показывать только активные пространства
    "format-icons": {                     // Кастомные иконки для workspace
      "1": "",  // Иконка для workspace 1
      "2": "",  // Иконка для workspace 2
      "3": "",  // Иконка для workspace 3
      "4": "",  // Иконка для workspace 4
      "5": "",  // Иконка для workspace 5
      "urgent": "",  // Иконка для срочных уведомлений
      "default": ""  // Иконка по умолчанию
    },
    "persistent_workspaces": {  // Фиксированные рабочие пространства
      "1": {}, "2": {}, "3": {}, "4": {}, "5": {}
    }
  },

  // Настройка модуля активного окна
  "hyprland/window": {
    "max-length": 50,      // Максимальная длина текста
    "separator": false,    // Отключение разделителя
    "rewrite": {           // Переопределение текста
      "": "No active window"  // Текст при отсутствии активного окна
    },
    "format": "{}",        // Формат вывода
    "tooltip": false       // Отключение подсказки
  },

  // Настройка модуля часов
  "clock": {
    "format": "{:%H:%M | %d.%m.%Y}",  // Формат времени
    "timezone": "Europe/Moscow",      // Часовой пояс
    "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",  // Формат подсказки
    "interval": 60,                   // Интервал обновления (секунды)
    "format-alt": "{:%Y-%m-%d}"       // Альтернативный формат
  },

  // Настройка модуля звука
  "pulseaudio": {
    "format": "{icon} {volume}%",     // Формат: иконка + уровень громкости
    "format-muted": " 0%",          // Формат при отключенном звуке
    "format-icons": {                // Иконки для разных уровней громкости
      "default": ["", "", ""]
    },
    "scroll-step": 5,                // Шаг изменения громкости при прокрутке
    "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle",  // Действие по клику
    "on-click-right": "pavucontrol",  // Действие по правому клику
    "tooltip": false                 // Отключение подсказки
  },

  // Настройка модуля микрофона
  "pulseaudio#microphone": {
    "format": "{format_source}",      // Формат вывода
    "format-source": " {volume}%",  // Формат при активном микрофоне
    "format-source-muted": " 0%",   // Формат при отключенном микрофоне
    "on-click": "pactl set-source-mute @DEFAULT_SOURCE@ toggle",  // Действие по клику
    "tooltip": false                 // Отключение подсказки
  },

  // Настройка модуля сети
  "network": {
    "format-wifi": " {essid} ({signalStrength}%)",  // Формат для WiFi
    "format-ethernet": " {ipaddr}",               // Формат для Ethernet
    "format-disconnected": " No internet",        // Формат при отключении
    "tooltip-format": "{ifname}: {ipaddr}/{cidr}", // Формат подсказки
    "on-click": "nm-connection-editor",           // Действие по клику
    "interval": 5                                 // Интервал обновления
  },

  // Настройка модуля процессора
  "cpu": {
    "format": " {usage}%",         // Формат вывода
    "interval": 2,                 // Интервал обновления
    "states": {                    // Состояния для цветового выделения
      "warning": 70,               // Предупреждение при 70% загрузке
      "critical": 90               // Критическое при 90% загрузке
    },
    "tooltip": false              // Отключение подсказки
  },

  // Настройка модуля памяти
  "memory": {
    "format": " {used:0.1f}G/{total:0.1f}G",  // Формат вывода
    "interval": 5,                             // Интервал обновления
    "states": {                                // Состояния для цветового выделения
      "warning": 70,                           // Предупреждение при 70% использовании
      "critical": 90                           // Критическое при 90% использовании
    }
  },

  // Настройка модуля батареи
  "battery": {
    "states": {                      // Состояния батареи
      "good": 95,                    // Хороший уровень
      "warning": 30,                 // Уровень предупреждения
      "critical": 15                 // Критический уровень
    },
    "format": "{icon} {capacity}%",  // Формат вывода
    "format-charging": " {capacity}%",  // Формат при зарядке
    "format-plugged": " {capacity}%",   // Формат при подключении
    "format-alt": "{time} {icon}",    // Альтернативный формат
    "format-icons": ["", "", "", "", ""],  // Иконки для разных уровней
    "interval": 10                   // Интервал обновления
  },

  // Настройка кнопки выключения
  "custom/power": {
    "format": "",                  // Иконка выключения
    "on-click": "wlogout --protocol layer-shell",  // Действие по клику
    "tooltip": false                // Отключение подсказки
  },

  // Настройка системного трея
  "tray": {
    "spacing": 8,                   // Расстояние между иконками
    "icon-size": 16,                // Размер иконок
    "reverse-direction": false      // Обратное направление
  },

  // Настройки для всех модулей
  "modules": {
    "enable": true,                // Включение всех модулей
    "update-interval": 1           // Базовый интервал обновления
  }
}
```

## Файл стилей (~/.config/waybar/style.css)

```css
/* Базовые настройки для всех элементов */
* {
  font-family: "JetBrains Mono Nerd Font", monospace;  /* Шрифт с иконками */
  font-size: 12px;                                   /* Размер шрифта */
  min-height: 0;                                     /* Минимальная высота */
}

/* Основной контейнер Waybar */
window#waybar {
  background-color: rgba(26, 27, 38, 0.8);  /* Цвет фона с прозрачностью */
  color: #e0e0e0;                          /* Цвет текста */
  border-bottom: 1px solid #1a1b26;        /* Граница снизу */
  transition-property: background-color;   /* Анимация изменения цвета */
  transition-duration: 0.3s;               /* Длительность анимации */
}

/* Рабочие пространства */
#workspaces button {
  color: #7aa2f7;                         /* Цвет иконок */
  padding: 0 5px;                         /* Внутренние отступы */
  margin: 2px;                            /* Внешние отступы */
  border-radius: 4px;                     /* Скругление углов */
  background: transparent;                /* Прозрачный фон */
  border: 1px solid transparent;          /* Прозрачная граница */
  transition: all 0.3s ease;              /* Анимация изменений */
}

/* Активное рабочее пространство */
#workspaces button.active {
  color: #bb9af7;                         /* Цвет активной иконки */
  background: rgba(120, 120, 150, 0.2);   /* Полупрозрачный фон */
  border-color: #bb9af7;                  /* Цвет границы */
}

/* Срочное уведомление */
#workspaces button.urgent {
  color: #f7768e;                         /* Цвет срочного уведомления */
  animation: blink 2s infinite;           /* Анимация мигания */
}

/* Общие стили для модулей */
#clock, #battery, #cpu, #memory, #pulseaudio, #network, #tray {
  padding: 0 8px;                         /* Внутренние отступы */
  margin: 0 2px;                          /* Внешние отступы */
  border-radius: 4px;                     /* Скругление углов */
  background: rgba(40, 42, 54, 0.6);      /* Полупрозрачный фон */
}

/* Специфичные стили для кнопки выключения */
#custom-power {
  padding: 0 12px;                        /* Большие отступы */
  margin-right: 4px;                      /* Отступ справа */
  background: rgba(40, 42, 54, 0.6);     /* Полупрозрачный фон */
  color: #f7768e;                        /* Красный цвет иконки */
}

/* Стили для батареи в разных состояниях */
#battery.warning {
  color: #e0af68;                        /* Цвет предупреждения */
}

#battery.critical {
  color: #f7768e;                        /* Цвет критического уровня */
  animation: blink 1s infinite;          /* Анимация мигания */
}

/* Анимация мигания */
@keyframes blink {
  to {
    background-color: rgba(247, 118, 142, 0.3);  /* Цвет мигания */
  }
}

/* Стили для модуля звука */
#pulseaudio.muted {
  color: #a9b1d6;                        /* Цвет при отключенном звуке */
}

/* Стили для модуля сети */
#network.disconnected {
  color: #a9b1d6;                        /* Цвет при отключении */
}
```

## Дополнительные примечания

1. **Зависимости**:
   - Убедитесь, что установлены `pulseaudio`, `networkmanager`, `wireless-tools`
   - Для кнопки выключения нужен `wlogout`
   - Для управления звуком - `pavucontrol`

2. **Шрифты**:
   ```bash
   sudo pacman -S ttf-jetbrains-mono-nerd  # Для Arch Linux
   ```

3. **Автозапуск**:
   Добавьте в `~/.config/hypr/hyprland.conf`:
   ```ini
   exec-once = waybar
   ```

4. **Перезагрузка Waybar**:
   ```bash
   killall waybar && waybar
   ```

Этот конфиг обеспечивает:
- Полностью настраиваемую панель с рабочими пространствами
- Информацию о системе в реальном времени
- Красивый дизайн с анимациями
- Поддержку жестов и кликов
- Адаптивные цвета для разных состояний системы


