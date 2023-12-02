Задача 1.
Реализовать BASH скрипт, который развернет на Linux дистрибутиве (выбор за кандидатом) следующий стек:
- Apache2;
- Mysql (mariadb, postgresql);
- php;
- Wordpress;
- Nginx (как "проксирующий" запросы сервер на сервис Apache).
Конфигурационные файлы веб-серверов должны браться в виде готовых шаблонов.
По завершении скрипт должен отсылать уведомление с итогом выполнения на почту или иную среду принятия сообщений на усмотрение исполнителя.
Скрипт должен быть реализован так, чтобы в случае прерывания соединения или перезапуске выполнения, скрипт продолжил (или начал заново) и закончил выполнение задачи.
Будет плюсом использование GIT репозитория для конфигурационных файлов веб-серверов.
Задача 2
Перенести выполнение скрипта из задачи 1 в реализацию через IaC Ansible. Каждый шаг работы IaC должен выводить статус в консоль выполнения.
Ansible должен развернуть на операционной системе стек из Задачи 1. Минимизировать использование модулей Command, Shell, CMD.
Задача 3
Реализовать данный стек (из задачи 1), используя контейнеризацию (docker, podman). Каждый сервис должен находиться в отдельном контейнере. Данные базы данных должны сохраняться в случае остановки или удаления контейнера.
Будет плюсом реализация задачи с использованием Ansible.К каждой задаче добавьте комментарий:
- Какой иной инструмент вы бы использовали для выполнения задачи и почему?
- Как можно упростить выполнение задач или оптимизировать их, используя другие инструменты?
