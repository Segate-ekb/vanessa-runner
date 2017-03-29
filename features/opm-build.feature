# language: ru

Функционал: Проверка сборки продукта
    Как Пользователь
    Я хочу автоматически проверять сборку моего продукта
    Чтобы гарантировать возможность установку моего продукта у пользователей

Контекст: Отключение отладки в логах
    # Допустим Я выключаю отладку лога с именем "oscript.lib.commands"
    Допустим Я очищаю параметры команды "opm" в контексте

Сценарий: Выполнение сборки продукта (opm build)
    Когда Я добавляю параметр "build ." для команды "opm"
    И Я выполняю команду "opm"
    Тогда Вывод команды "opm" содержит "Сборка пакета завершена"
    И Вывод команды "opm" не содержит "Внешнее исключение"
    И Код возврата команды "opm" равен 0

Сценарий: Сборка, установка и выполнение пакета
    Допустим Я создаю временный каталог и сохраняю его в контекст
    Допустим Я собираю пакет во временном каталоге
    И Я устанавливаю временный каталог как рабочий каталог
    Когда я устанавливаю пакет из файла собранного пакета
    Тогда файл "src\main.os" существует
    Тогда я выполняю команду получения версии установленного пакета "oscript src\main.os version"
    и версия установленного пакета равна версии пакета из контекста
    Тогда файл "src\main.os" существует
    Тогда я выполняю команду получения версии установленного пакета "oscript tools\runner.os version"
    и версия установленного пакета равна версии пакета из контекста
