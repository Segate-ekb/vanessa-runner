# language: ru

Функционал: Разборка расширений конфигурации
    Как разработчик
    Я хочу иметь возможность разобрать расширения конфигурации на исходники
    Чтобы выполнять коллективную разработку проекта 1С

Контекст:
    И Я очищаю параметры команды "oscript" в контексте

Сценарий: Первый - подготовка базы
    Допустим я подготовил репозиторий и рабочий каталог проекта
    И я подготовил рабочую базу проекта "./build/ib" по умолчанию

Сценарий: Разборка одного расширения из базы
    Допустим Я копирую каталог "cfe" из каталога "tests/fixtures" проекта в рабочий каталог
    И Я копирую файл "test.cfe" из каталога "tests/fixtures" проекта в рабочий каталог
    И Я очищаю параметры команды "oscript" в контексте
    И Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileext cfe testNew --ibconnection /F./build/ib --language ru"
    И каталог "cfe-out" не существует
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os decompileext testNew cfe-out --ibconnection /F./build/ib --language ru"
    Тогда Код возврата равен 0
    И Файл "cfe-out/Configuration.xml" содержит
    """
		        <Name>test</Name>
		        <Synonym>
		        	<v8:item>
		        		<v8:lang>ru</v8:lang>
		        		<v8:content>test</v8:content>
		        	</v8:item>
		        </Synonym>
		        <Comment/>
    """
    И Файл "cfe-out/Configuration.xml" содержит "<NamePrefix>Ext1_</NamePrefix>"
    И Файл "cfe-out/Configuration.xml" содержит "<ConfigurationExtensionPurpose>Customization</ConfigurationExtensionPurpose>"
    И Файл "cfe-out/Configuration.xml" содержит "<ObjectBelonging>Adopted</ObjectBelonging>"
    И Файл "cfe-out/Ext/ManagedApplicationModule.bsl" содержит 'Сообщить("Внутри Ext1_ПриНачалеРаботыСистемы");'

    # TODO почему-то проверкак текст файла ManagedApplicationModule.bsl ниже не проходит
    # И Файл "cfe-out/Ext/ManagedApplicationModule.bsl" содержит
    # """
    #     &Перед("ПриНачалеРаботыСистемы")
    #     Процедура Ext1_ПриНачалеРаботыСистемы()
    #             Сообщить("Внутри Ext1_ПриНачалеРаботыСистемы");
    #     КонецПроцедуры
    # """

# TODO Сценарий: Разборка нескольких расширений с явно заданной базой
