from gpiozero import PWMOutputDevice
from time import sleep

# Задаем пин и начальную частоту 2000 Гц (типичный писк пищалки)
# active_high=False переворачивает логику для модуля
buzzer = PWMOutputDevice(17, active_high=False, frequency=2000)

print("Пищим...")
# value=0.5 задает меандр (прямоугольную волну), дающий самый чистый звук
buzzer.value = 0.5 
sleep(1)

print("Молчим...")
buzzer.value = 0.0
sleep(1)
