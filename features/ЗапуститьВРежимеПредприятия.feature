#language: ru

Функционал: Загрузка в режиме Предприятие
    Как разработчик
    Я хочу иметь возможность загрузить режим 1С:Предприятие
    Чтобы изменять данные или выполнять обработку обновления

Контекст:
    Дано я подготовил репозиторий и рабочий каталог проекта
    И я подготовил рабочую базу проекта "./build/ib" по умолчанию
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileepf $runnerRoot/epf/ЗакрытьПредприятие ЗакрытьПредприятие.epf --nocacheuse --language ru"
    И Я показываю вывод команды
    И Код возврата команды "oscript" равен 0

    Дано Я очищаю параметры команды "oscript" в контексте
    И Я установил рабочий каталог как текущий каталог
    И Я сохраняю значение "INFO" в переменную окружения "LOGOS_LEVEL"

Сценарий: Запуск "ЗакрытьПредприятие.epf"

    Когда Я добавляю параметр "<КаталогПроекта>/src/main.os run" для команды "oscript"

    И Я добавляю параметр "--execute ЗакрытьПредприятие.epf" для команды "oscript"
    И Я добавляю параметр " --ibconnection /Fbuild/ib" для команды "oscript"
    И Я добавляю параметр "--language ru" для команды "oscript"
    Когда Я выполняю команду "oscript"

    И Я показываю вывод команды

    Тогда Вывод команды "oscript" содержит
        | ИНФОРМАЦИЯ - Выполняю команду/действие в режиме 1С:Предприятие |
        | ИНФОРМАЦИЯ - Выполнение команды/действия в режиме 1С:Предприятие завершено |
    Тогда Вывод команды "oscript" не содержит
        | Пользователь ИБ не идентифицирован |
    И Код возврата команды "oscript" равен 0

Сценарий: Запуск с неверным именем пользователя ИБ

    Когда Я добавляю параметр "<КаталогПроекта>/src/main.os run" для команды "oscript"

    И Я добавляю параметр "--execute ЗакрытьПредприятие.epf" для команды "oscript"
    И Я добавляю параметр " --ibconnection /Fbuild/ib" для команды "oscript"
    И Я добавляю параметр "--db-user НеизвестныйПользователь" для команды "oscript"
    И Я добавляю параметр "--language ru" для команды "oscript"
    # И Я добавляю параметр "--online-file log.txt" для команды "oscript"
    Когда Я выполняю команду "oscript"

    И Я показываю вывод команды

    Тогда Вывод команды "oscript" содержит
        | Пользователь ИБ не идентифицирован |
    Тогда Вывод команды "oscript" не содержит
        | ИНФОРМАЦИЯ - Выполнение команды/действия в режиме 1С:Предприятие завершено |
    И Код возврата команды "oscript" равен 1

Сценарий: Запуск с открытием навигационной ссылки
    Когда Я добавляю параметр "<КаталогПроекта>/src/main.os run" для команды "oscript"
    И Я добавляю параметр "--url e1cib/navigationpoint/startpage" для команды "oscript"
    И Я добавляю параметр "--execute ЗакрытьПредприятие.epf" для команды "oscript"
    И Я добавляю параметр "--ibconnection /Fbuild/ib" для команды "oscript"

    Когда Я выполняю команду "oscript"
    И Я показываю вывод команды

    Тогда Код возврата команды "oscript" равен 0
    И Вывод команды "oscript" содержит
        | ИНФОРМАЦИЯ - Выполнение команды/действия в режиме 1С:Предприятие завершено |
