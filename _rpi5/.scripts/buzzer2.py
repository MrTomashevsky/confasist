from gpiozero import Buzzer
from time import sleep

# active_high=False говорит библиотеке, что зуммер включается НИЗКИМ уровнем (0)
# initial_value=False гарантирует, что при старте скрипта он будет молчать
buzzer = Buzzer(17, active_high=False, initial_value=False)

print("Включаем зуммер...")
buzzer.on()
sleep(1)

print("Выключаем зуммер...")
buzzer.off()
sleep(1)
