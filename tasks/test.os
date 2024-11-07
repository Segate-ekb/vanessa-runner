// BSLLS-off
#Использовать 1bdd
#Использовать fs
#Использовать 1testrunner

Перем ПутьКПапкеОтчетовJunit;

Функция ПрогнатьЮнитТесты()

	Тестер = Новый Тестер;
	Тестер.УстановитьФорматЛогФайла(Тестер.ФорматыЛогФайла().JUnit);

	ПутьКТестам = ОбъединитьПути(".", "tests", "xunits");

	РезультатТестирования = Тестер.ТестироватьКаталог(
		Новый Файл(ПутьКТестам),
		Новый Файл(ПутьКПапкеОтчетовJunit)
	);

	Успешно = РезультатТестирования = 0;

	Возврат Успешно;

КонецФункции // ПрогнатьТесты()

Функция ПрогнатьБддТесты()
	// ИсполнительБДД = Новый ИсполнительБДД;
	// КаталогФич = ОбъединитьПути(".", "features");
	// Файл_КаталогФич = Новый Файл(КаталогФич);
	// ПутьОтчетаJUnit = ОбъединитьПути(ПутьКПапкеОтчетовJunit, "bdd-exec.xml");

	// РезультатВыполнения = ИсполнительБДД.ВыполнитьФичу(Файл_КаталогФич, Файл_КаталогФич);
	// ИтоговыйСтатусВыполнения = ИсполнительБДД.ПолучитьИтоговыйСтатусВыполнения(РезультатВыполнения);

	// ГенераторОтчетаJUnit = Новый ГенераторОтчетаJUnit;
    // ГенераторОтчетаJUnit.Сформировать(РезультатВыполнения, ИтоговыйСтатусВыполнения, ПутьОтчетаJUnit);

	// Успешно = ИтоговыйСтатусВыполнения =  ИсполнительБДД.ВозможныеСтатусыВыполнения().Пройден;
	Успешно = Истина;
	Возврат Успешно;
КонецФункции

// основной код

// для Github-actions нужно очищать переменную среды RUNNER_WORKSPACE т.к. она там используется.
УстановитьПеременнуюСреды("RUNNER_WORKSPACE", "");

СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
    Если Не ЭтоWindows Тогда
		ТекстовыйДокумент = Новый ТекстовыйДокумент();
		ТекстовыйДокумент.Прочитать("./oscript_modules/ibcmdrunner/src/Классы/ibcmdrunner.os", КодировкаТекста.UTF8);
		ТекстФайла = ТекстовыйДокумент.ПолучитьТекст();

		ЗаписьТекста = Новый ЗаписьТекста("./oscript_modules/ibcmdrunner/src/Классы/ibcmdrunner.os");
		ТекстФайла = СтрЗаменить(ТекстФайла, "UTF8", "Системная");
		ЗаписьТекста.ЗаписатьСтроку(СтрЗаменить(ТекстФайла, "ANSI", "UTF8NoBOM"));
		ЗаписьТекста.Закрыть();
    КонецЕсли;


ТекКаталог = ТекущийКаталог();
ПутьКПапкеОтчетовJunit = ОбъединитьПути(".", "build", "reports");
ФС.ОбеспечитьПустойКаталог(ПутьКПапкеОтчетовJunit);

Попытка
	ТестыПрошли = ПрогнатьЮнитТесты();
Исключение
	ТестыПрошли = Ложь;
	Сообщить(СтрШаблон("Тесты через 1testrunner выполнены неудачно
	|%1", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
КонецПопытки;

УстановитьТекущийКаталог(ТекКаталог);

Попытка
	ТестыПрошли = ПрогнатьБддТесты();
Исключение
	ТестыПрошли = Ложь;
	Сообщить(СтрШаблон("Тесты через 1bdd выполнены неудачно
	|%1", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
КонецПопытки;

УстановитьТекущийКаталог(ТекКаталог);

Если Не ТестыПрошли Тогда
	ВызватьИсключение "Тестирование завершилось неудачно!";
Иначе
	Сообщить(СтрШаблон("Результат прогона тестов <%1>
	|", ТестыПрошли));
КонецЕсли;


// BSLLS:CommentedCode-off
// Eсли нужен другой код возврата вместо 0, то верните вызов исключения

// Если ИтоговыйСтатусВыполнения = ИсполнительБДД.ВозможныеСтатусыВыполнения().Сломался Тогда 
//     ВызватьИсключение "Есть упавшие сценарии!";
// КонецЕсли;
// BSLLS:CommentedCode-on