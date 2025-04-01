#!/bin/bash


cd $HOME

# Проверка, запущена ли сессия stubJava
if ! screen -list | grep -q "stubJava"; then
    # Запуск Java приложения в фоновом режиме
    screen -dmS stubJava bash -c "
        java -jar simple-spring-boot-app-1.0-SNAPSHOT.jar
    "
    sleep 5
else
    echo "Сессия stubJava уже запущена."
fi
# Запуск JMeter в фоновом режиме
screen -dmS runJM bash -c "
    /home/svbazuev/apache-jmeter-5.6.3/bin/jmeter -n -t ViewResultsTree.jmx -l log.jtl
"
echo "Сессия runJM запущена."

# Вывод информации о запущенных сессиях
screen -ls
