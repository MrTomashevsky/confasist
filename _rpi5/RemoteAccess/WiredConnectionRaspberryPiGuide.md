### 1. **Прямое проводное соединение через USB (USB-C или USB-A)**

Raspberry Pi 5 умеет работать в режиме **USB gadget/device mode** через USB-C порт (тот, что предназначен для питания и данных). Это значит, что Pi можно подключить к ноуту как **Ethernet-устройство через USB**:

**Шаги:**


1. Отредактируйте файлы (на Pi):
   ```bash
   sudo nano /boot/firmware/config.txt
   ```
   Добавьте в конец (или замените, если есть):
   ```
   dtoverlay=dwc2,dr_mode=peripheral
   ```
   (Если есть строка `dtoverlay=dwc2,dr_mode=host` — закомментируйте её.)

2. Отредактируйте cmdline:
   ```bash
   sudo nano /boot/firmware/cmdline.txt
   ```
   Добавьте **после root`** (всё в одну строку):
   ```
   modules-load=dwc2,g_ether
   ```

3. Перезагрузитесь:
   ```bash
   sudo reboot
   ```
5. После перезагрузки подключите USB-C кабель (data-кабель, желательно хороший/мощный) к ноутбуку. На Arch Linux должен появиться новый Ethernet-интерфейс (`ip link` или в NetworkManager).

**На Arch (ноутбук):**
- Интерфейс обычно `enp...` или `usb0`.
- Настройте Link-Local (автоматически) или статический IP, например:
  ```bash
  sudo ip addr add 192.168.7.2/24 dev <interface>
  sudo ip link set <interface> up
  ```
  
  Например:
  
  ```bash
  sudo ip addr add 192.168.7.2/24 dev enp3s0f3u2i1
  sudo ip link set enp3s0f3u2i1 up
  ```


  
### 2. **Подключение по SSH и настройка статического IP (чтобы всегда был 192.168.7.2)**
  
Установка ssh:

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl enable --now ssh
```

Создайте файл netplan (Ubuntu):

```bash
sudo nano /etc/netplan/50-usb-gadget.yaml
```

Содержимое:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    usb0:
      dhcp4: no
      addresses: [192.168.7.2/24]
```

Исправьте права на файл:

```bash
sudo chmod 600 /etc/netplan/50-usb-gadget.yaml
```

Проверьте:

```bash
ls -l /etc/netplan/
```

Должно быть `-rw-------` (только root).

Далее включите и запустите systemd-networkd:

```bash
sudo apt install --no-install-recommends systemd-resolved  # если ещё не стоит

sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved

sudo systemctl status systemd-networkd
```

Потом примените конфигурацию заново:

```bash
sudo netplan generate
sudo netplan apply
```

На Arch ноутбуке:

```bash 
sudo ip addr add 192.168.7.1/24 dev enp3s0f3u2
sudo ip link set enp3s0f3u2 up
ssh user@192.168.7.2
```

Каждый раз после выключения Raspberry придется заново запускать последние строчки.

### 3. VNC

Для работы нужен raspi-config:
```bash
sudo apt install raspi-config
sudo raspi-config
```

Там выбираем `Interface Options`, где жмем `VNC`. Далее получаем ip:
```bash
hostname -I
```

Используем приложение TigerVNC или любое другое для подключения, все будет работать, если вы на Ubuntu 24 или младше или на Raspberry Pi OS.
Можно еще использовать Remina, но тогда чуть-чуть другие настройки для конфига wayvnc.

# 4. **wayvnc для работы со sway**

Sway - тайлинговый менеджер для Linux. В Ubuntu Linux по умолчанию в качестве графического окружения используется gnome, но мне сие неудобно, и я юзаю sway, потому что там легко настроить массу горячих клавишей.

Установка wayvnc:
```bash
sudo apt install wayvnc
```

Если пишет, что не может установить, соберем wayvnc из исходников:

```bash
mkdir -p ~/tmp
cd ~/tmp/
git clone https://github.com/any1/aml.git
git clone https://github.com/any1/neatvnc.git
git clone https://github.com/any1/wayvnc.git

cd ~/tmp/aml
meson build --prefix=/usr --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..

cd ~/tmp/neatvnc
meson build --prefix=/usr --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..

cd ~/tmp/wayvnc
meson build --prefix=/usr --buildtype=release
ninja -C build
sudo ninja -C build install

mkdir -p ~/.config/wayvnc
nano ~/.config/wayvnc/config
```

В файл записать следующее:

```ini
address=0.0.0.0
port=5900
enable_auth=true
username=user
password=твой_пароль
```

Если юзаем Remmina:

```ini
address=127.0.0.1
port=5900
enable_auth=false
username=user
password=твой_пароль
```

Если ругается на randerD128, то выдадим себе нужные права:

```bash
sudo usermod -aG render $USER
sudo usermod -aG video $USER
```

Перезайдите по ssh:

```bash
logout # или exit
```

Если опять та же ошибка:

```bash
sudo chmod 666 /dev/dri/renderD128
```

Далее следует открыть tmux (`sudo apt install tmux`) - приложение для запускат нескольких терминалов в одном - и запустить в нем:

```bash
export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-1
export WLR_RENDERER_ALLOW_SOFTWARE=1   # <- это важно!

sway
```

Потом Ctrl+B+" - поделит терминал по горизонтали - и там:

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-1

wayvnc 0.0.0.0 5900
```

Теперь можно спокойно подключаться! Осталось настроить конфиг sway должным образом.
