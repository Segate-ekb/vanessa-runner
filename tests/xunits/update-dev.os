#Использовать asserts
#Использовать tempfiles
#Использовать gitrunner
#Использовать "utils"
#Использовать "../.."

#Область ОписаниеПеременных

Перем НакопленныеВременныеФайлы; // фиксация накопленных времнных файлов для сброса

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

&Тест
Процедура ТестДолжен_ОбновитьФайловуюБазуИзИсходниковIbcmd() Экспорт

	// Дано
	Исполнитель = Новый Тест_ИсполнительКоманд("update-dev");
	Исполнитель.УстановитьКонтекстПустаяИБ();
	КаталогSrc = Исполнитель.ПутьТестовыхДанных("cf");
	Исполнитель.ДобавитьПараметр("--src", КаталогSrc);
	Исполнитель.ДобавитьПараметр("--ibcmd");

	// Когда
	Исполнитель.ВыполнитьКоманду();

	// Тогда
	Исполнитель.ОжидаемЧтоВыводСодержит("Используется ibcmd платформы");
	Исполнитель.ОжидаемЧтоВыводСодержит("Информационная база обновлена из исходников.");

КонецПроцедуры

&Тест
Процедура ТестДолжен_ОбновитьФайловуюБазуИзФайлаВыгрузкиIbcmd() Экспорт

	// Дано
	Исполнитель = Новый Тест_ИсполнительКоманд("update-dev");
	Исполнитель.УстановитьКонтекстПустаяИБ();
	ФайлDt = Исполнитель.ПутьТестовыхДанных("1Cv8.dt");
	Исполнитель.ДобавитьПараметр("--dt", ФайлDt);
	Исполнитель.ДобавитьПараметр("--ibcmd");

	// Когда
	Исполнитель.ВыполнитьКоманду();

	// Тогда
	Исполнитель.ОжидаемЧтоВыводСодержит("Используется ibcmd платформы");
	Исполнитель.ОжидаемЧтоВыводСодержит("Информационная база обновлена из файла выгрузки.");

КонецПроцедуры

&Тест
Процедура ТестДолжен_ОбновитьФайловуюБазуИнкрементальноIbcmd() Экспорт

	// Дано
	Исполнитель = Новый Тест_ИсполнительКоманд("update-dev");
	УстановитьКонтекстИнкрементальнойЗагрузки(Исполнитель);
	Исполнитель.ДобавитьПараметр("--src", "src/cf");
	Исполнитель.ДобавитьПараметр("--git-increment");
	Исполнитель.ДобавитьПараметр("--ibcmd");

	// Когда
	Исполнитель.ВыполнитьКоманду();

	//ФС.ОбеспечитьПустойКаталог(ОбъединитьПути(Исполнитель.КаталогКоманды(), ".git"));

	// Тогда
	Исполнитель.ОжидаемЧтоВыводСодержит("Используется ibcmd платформы");
	Исполнитель.ОжидаемЧтоВыводСодержит("Будет выполнена инкрементальная загрузка");
	Исполнитель.ОжидаемЧтоВыводСодержит("ManagedApplicationModule.bsl");

	Исполнитель.ОжидаемЧтоВыводСодержит("Информационная база обновлена из исходников");
	Исполнитель.ОжидаемЧтоВыводСодержит("Обновление конфигурации БД завершено.");

КонецПроцедуры

&Тест
Процедура ТестДолжен_ОбновитьФайловуюБазуИнкрементальноСИзменениямиВВоркспейсеIbcmd() Экспорт

	// Дано
	Исполнитель = Новый Тест_ИсполнительКоманд("update-dev");
	УстановитьКонтекстИнкрементальнойЗагрузки(Исполнитель, Истина);
	Исполнитель.ДобавитьПараметр("--src", "src/cf");
	Исполнитель.ДобавитьПараметр("--git-increment");
	Исполнитель.ДобавитьПараметр("--ibcmd");

	// Когда
	Исполнитель.ВыполнитьКоманду();

	// Тогда
	Исполнитель.ОжидаемЧтоВыводСодержит("Используется ibcmd платформы");
	Исполнитель.ОжидаемЧтоВыводСодержит("Будет выполнена инкрементальная загрузка");
	Исполнитель.ОжидаемЧтоВыводСодержит("ManagedApplicationModule.bsl");
	Исполнитель.ОжидаемЧтоВыводСодержит("ObjectModule.bsl");

	Исполнитель.ОжидаемЧтоВыводСодержит("Информационная база обновлена из исходников");
	Исполнитель.ОжидаемЧтоВыводСодержит("Обновление конфигурации БД завершено.");

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПередЗапускомТеста() Экспорт

	НакопленныеВременныеФайлы = ВременныеФайлы.Файлы();

КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт

	ВременныеФайлы.УдалитьНакопленныеВременныеФайлы(НакопленныеВременныеФайлы);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаписатьТекст(ИмяФайла, Текст)

	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла);
	ЗаписьТекста.ЗаписатьСтроку(Текст);
	ЗаписьТекста.Закрыть();

КонецПроцедуры

Процедура УстановитьКонтекстИнкрементальнойЗагрузки(Исполнитель, ИзмененияБезКоммита = Ложь)

	КаталогПроекта = Исполнитель.КаталогКоманды();
	КаталогИсходников = ОбъединитьПути(КаталогПроекта, "src", "cf");
	КаталогSrc = Исполнитель.ПутьТестовыхДанных("cf");

	ФС.КопироватьСодержимоеКаталога(КаталогSrc, КаталогИсходников);

	Репозиторий = Новый ГитРепозиторий();
	Репозиторий.УстановитьРабочийКаталог(КаталогПроекта);
	Репозиторий.Инициализировать();

	_gitignore = ОбъединитьПути(КаталогПроекта, ".gitignore");
	ЗаписатьТекст(_gitignore, "lastUploadedCommit.txt");

	Репозиторий.ДобавитьФайлВИндекс(".");
	Репозиторий.Закоммитить("first commit");

	ПараметрыКоманды = Новый Массив;
	ПараметрыКоманды.Добавить("rev-parse");
	ПараметрыКоманды.Добавить("--short");
	ПараметрыКоманды.Добавить("HEAD");
	Репозиторий.ВыполнитьКоманду(ПараметрыКоманды);
	ПоследнийКоммит = Репозиторий.ПолучитьВыводКоманды();

	lastUploadedCommit = ОбъединитьПути(КаталогИсходников, "lastUploadedCommit.txt");
	ЗаписатьТекст(lastUploadedCommit, ПоследнийКоммит);

	Исполнитель.УстановитьКонтекстИБИзФайловКонфигурации(КаталогИсходников);

	ManagedApplicationModule = ОбъединитьПути(КаталогИсходников, "Ext", "ManagedApplicationModule.bsl");
	ЗаписатьТекст(ManagedApplicationModule, "Процедура ПриНачалеРаботыСистемы() КонецПроцедуры");
	Репозиторий.ДобавитьФайлВИндекс(".");
	Репозиторий.Закоммитить("second commit");

	Если ИзмененияБезКоммита Тогда
		ОтносительныйПутьКСправочнику = ОбъединитьПути("Catalogs", "Справочник1", "Ext", "ObjectModule.bsl");
		ObjectModule = ОбъединитьПути(КаталогИсходников, ОтносительныйПутьКСправочнику);
		ЗаписатьТекст(ObjectModule, "Процедура ПередЗаписью() КонецПроцедуры");
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
