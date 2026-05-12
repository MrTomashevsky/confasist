После подключения Raspberry Pi через USB-C:

Посмотреть интерфейсы:
    ip link

Назначить IP:
    sudo ip addr add 192.168.7.1/24 dev <interface>

Поднять интерфейс:
    sudo ip link set <interface> up


Подключение по SSH:

ssh user@192.168.7.2

 
