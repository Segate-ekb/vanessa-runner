# language: ru

Функционал: Сборка расширений конфигурации
    Как разработчик
    Я хочу иметь возможность собрать расширения конфигурации из исходников и подключить к нужной конфигурации
    Чтобы выполнять коллективную разработку проекта 1С

Контекст:
    Дано Я очищаю параметры команды "oscript" в контексте

    И Я копирую каталог "cfe" из каталога "tests/fixtures" проекта в рабочий каталог
    И я удаляю файл "*.cfe"
    И я удаляю каталог "cfe-out"

Сценарий: Первый - подготовка базы
    Дано я подготовил репозиторий и рабочий каталог проекта
    Дано я подготовил рабочую базу проекта "./build/ib" по умолчанию

Сценарий: Сборка одного расширения с явно заданной базой

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileext cfe testNew --ibconnection /F./build/ib --language ru"

    Тогда Вывод команды "oscript" содержит
    """
        Список расширений конфигурации:
        testNew
    """
    Тогда Код возврата команды "oscript" равен 0

Сценарий: Сборка одного расширения и сохранение в файл с явно заданной базой

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileexttocfe -s cfe -o testNew.cfe --ibconnection /F./build/ib --language ru"

    Тогда Вывод команды "oscript" содержит
    """
        Список расширений конфигурации:
    """
    Тогда Код возврата команды "oscript" равен 0
    И файл "testNew.cfe" существует

Сценарий: Сборка одного расширения и сохранение в файл без базы

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileexttocfe -s cfe -o testNew.cfe --language ru"

    Тогда Вывод команды "oscript" содержит
    """
        Список расширений конфигурации:
    """
    Тогда Код возврата команды "oscript" равен 0
    И файл "testNew.cfe" существует

# TODO Сценарий: Сборка каталога расширений с явно заданной базой

Сценарий: Сборка расширения из исходников в cfe-файл с изменением номера сборки
	Дано Я добавляю параметр "<КаталогПроекта>/src/main.os compileexttocfe" для команды "oscript"
	И Я добавляю параметр "-s cfe -o testNew.cfe" для команды "oscript"
    И Я добавляю параметр "--build-number 1516" для команды "oscript"
    И Я добавляю параметр "--language ru" для команды "oscript"
	Когда Я выполняю команду "oscript"
	Тогда Вывод команды "oscript" содержит
    | Изменяю номер сборки в исходниках конфигурации 1С на 1516 |
    Тогда Вывод команды "oscript" содержит
    """
        Список расширений конфигурации:
    """
	И Код возврата команды "oscript" равен 0
    И файл "testNew.cfe" существует

    Тогда файл "cfe/Configuration.xml" содержит "<Version>1.1.0.1516</Version>"

    Дано каталог "cfe-out" не существует
    И Я очищаю параметры команды "oscript" в контексте

    И Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileext cfe testNew --ibconnection /F./build/ib --language ru"
    И Я очищаю параметры команды "oscript" в контексте
    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os decompileext testNew cfe-out --ibconnection /F./build/ib --language ru"
    Тогда Код возврата равен 0

    Тогда файл "cfe-out/Configuration.xml" содержит "<Version>1.1.0.1516</Version>"
