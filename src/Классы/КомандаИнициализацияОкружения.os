///////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

Перем Лог; // Экземпляр логгера
Перем КорневойПутьПроекта;

// Параметры команды
Перем ДанныеПодключения;
Перем ПараметрыХранилища;
Перем РежимыРеструктуризации;
Перем РежимРазработчика;
Перем ПутьКФайлуКонфигурации;
Перем ПутьКИсходникам;
Перем ПутьКФайлуВыгрузки;

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания =
		"     Инициализация базы данных для выполнения необходимых тестов.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, ТекстОписания);

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--src", "Путь к папке исходников
	|
	|Схема работы:
	|		Указываем путь к исходникам с конфигурацией,
	|		указываем версию платформы, которую хотим использовать,
	|		и получаем по пути build\ib готовую базу для тестирования.");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--dt", "Путь к файлу с dt выгрузкой");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--cf", "Путь к cf-файлу конфигурации
	|       В пути файла можно указать шаблонную переменную $version для подстановки в нее версии конфигурации
	|       Пример: 1Cv8_$version.cf выгрузит файл вида 1Cv8_1.2.3.4.cf");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--dev",
		"Признак dev режима, создаем и загружаем автоматом структуру конфигурации");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--storage", "Признак обновления из хранилища");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-name", "Строка подключения к хранилищу");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-user", "Пользователь хранилища");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-pwd", "Пароль");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-ver",
		"Номер версии, по умолчанию берем последнюю");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--v1",
		"Поддержка режима реструктуризации -v1 на сервере");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--v2",
		"Поддержка режима реструктуризации -v2 на сервере");
	ОбщиеМетоды.ДобавитьБлокIbcmd(Парсер, ОписаниеКоманды);

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

// Выполняет логику команды
//
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Соответствие - дополнительные параметры (необязательно)
//
//  Возвращаемое значение:
//   Число - Код возврата команды.
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ОбщиеМетоды.ЛогКоманды(ДополнительныеПараметры);
	КорневойПутьПроекта = ПараметрыСистемы.КорневойПутьПроекта;

	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];

	ПараметрыХранилища = Новый Структура;
	ПараметрыХранилища.Вставить("СтрокаПодключения", ПараметрыКоманды["--storage-name"]);
	ПараметрыХранилища.Вставить("Пользователь", ПараметрыКоманды["--storage-user"]);
	ПараметрыХранилища.Вставить("Пароль", ПараметрыКоманды["--storage-pwd"]);
	ПараметрыХранилища.Вставить("Версия", ПараметрыКоманды["--storage-ver"]);
	ПараметрыХранилища.Вставить("РежимОбновления", ПараметрыКоманды["--storage"]);

	РежимыРеструктуризации = Новый Структура;
	РежимыРеструктуризации.Вставить("Первый", ПараметрыКоманды["--v1"]);
	РежимыРеструктуризации.Вставить("Второй", ПараметрыКоманды["--v2"]);

	ПутьКИсходникам = ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--src"]);
	ПутьКФайлуВыгрузки = ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--dt"]);
	ПутьКФайлуКонфигурации = ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--cf"]);
	РежимРазработчика = ПараметрыКоманды["--dev"];

	ИнициализироватьБазуДанных(ПараметрыКоманды["--v8version"], ПараметрыКоманды["--nocacheuse"],
					ПараметрыКоманды);

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ИнициализироватьБазуДанных(Знач ВерсияПлатформы,
			Знач НеДобавлятьВСписокБаз,
			Знач ПараметрыКоманды)

	Перем БазуСоздавали;
	БазуСоздавали = Ложь;

	Пользователь = ДанныеПодключения.Пользователь;
	Пароль = ДанныеПодключения.Пароль;
	Если ПустаяСтрока(ДанныеПодключения.ПутьБазы) Тогда
		ДанныеПодключения = СоздатьДанныеПодключения(ДанныеПодключения);
	КонецЕсли;
	СтрокаПодключения = ДанныеПодключения.ПутьБазы;

	МенеджерСборки = НовыйМенеджерСборки(ПараметрыКоманды);
	МенеджерСборки.Конструктор(ДанныеПодключения, ПараметрыКоманды);

	Лог.Отладка("ИнициализироватьБазуДанных СтрокаПодключения:" + СтрокаПодключения);

	Если ОбщиеМетоды.ЭтоФайловаяИБ(СтрокаПодключения) Тогда

		ОбеспечитьФайловуюБазу(МенеджерСборки, СтрокаПодключения);
		БазуСоздавали = Истина;
		Лог.Информация("Создали базу данных для " + СтрокаПодключения);

	КонецЕсли;

	// Базу создали, пользователей еще нет.
	Если БазуСоздавали И ПустаяСтрока(ПутьКФайлуВыгрузки) Тогда
		МенеджерСборки.УстановитьКонтекст(СтрокаПодключения, "", "");
		Пользователь = "";
		Пароль = "";
	Иначе
		МенеджерСборки.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
	КонецЕсли;

	Если ЗначениеЗаполнено(ПутьКИсходникам) Тогда
		ЗагрузкаИзИсходников(МенеджерСборки);

	ИначеЕсли ЗначениеЗаполнено(ПутьКФайлуВыгрузки) Тогда
		ЗагрузкаИзФайлаВыгрузки(МенеджерСборки);

	ИначеЕсли ЗначениеЗаполнено(ПутьКФайлуКонфигурации) Тогда
		ЗагрузкаИзФайлаКонфигурации(МенеджерСборки);

	ИначеЕсли ПараметрыХранилища.РежимОбновления Тогда
		ЗагрузкаИзХранилища(МенеджерСборки, ПараметрыХранилища);

	Иначе
		Лог.Информация("Создана пустая база данных.");

	КонецЕсли;

	ОбновитьКонфигурациюБД(МенеджерСборки);

	МенеджерСборки.Деструктор();

	ДобавитьБазуВСписокБаз(НеДобавлятьВСписокБаз, ВерсияПлатформы, СтрокаПодключения);

	Лог.Информация("Инициализация завершена");

КонецПроцедуры

Процедура ОбеспечитьФайловуюБазу(МенеджерСборки, СтрокаПодключения)

	МенеджерСборки.УстановитьКонтекст(СтрокаПодключения, "", "");
	КаталогБазы = ОбщиеМетоды.КаталогФайловойИБ(СтрокаПодключения);

	Лог.Отладка("Нашли каталог базы для удаления <%1> ", КаталогБазы);
	Попытка
		МенеджерСборки.СоздатьФайловуюБазу(КаталогБазы);
	Исключение
		МенеджерСборки.Деструктор();
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

Процедура ЗагрузкаИзФайлаКонфигурации(МенеджерСборки)

	Лог.Информация("Запускаем загрузку конфигурации из cf-файла...");
	МенеджерВерсий = Новый МенеджерВерсийФайлов1С();
	ПутьКФайлуСВерсией = МенеджерВерсий.НайтиФайлСВерсией(ПутьКФайлуКонфигурации);

	Попытка
		МенеджерСборки.ЗагрузитьФайлКонфигурации(ПутьКФайлуСВерсией, Ложь);
		МенеджерСборки.ОбновитьКонфигурациюБазыДанных(Ложь);
	Исключение
		МенеджерСборки.Деструктор();
		ВызватьИсключение;
	КонецПопытки;
	Лог.Информация("Создана информационная база из файла конфигурации.");

КонецПроцедуры

Процедура ЗагрузкаИзИсходников(МенеджерСборки)

	Лог.Информация("Запускаем загрузку конфигурации из исходников...");
	Попытка
		СписокФайлов = "";
		МенеджерСборки.СобратьИзИсходниковТекущуюКонфигурацию(ПутьКИсходникам, СписокФайлов, Ложь);
	Исключение
		МенеджерСборки.Деструктор();
		ВызватьИсключение;
	КонецПопытки;
	Лог.Информация("Создана информационная база из исходников.");

КонецПроцедуры

Процедура ЗагрузкаИзФайлаВыгрузки(МенеджерСборки)

	Лог.Информация("Запускаем загрузку конфигурации из dt-файла...");
	Попытка
		МенеджерСборки.ЗагрузитьИнфобазуИзФайла(ПутьКФайлуВыгрузки);
	Исключение
		МенеджерСборки.Деструктор();
		ВызватьИсключение;
	КонецПопытки;
	Лог.Информация("Создана информационная база из файла выгрузки.");

КонецПроцедуры

Процедура ЗагрузкаИзХранилища(МенеджерКонфигуратора, ПараметрыХранилища)

	Лог.Информация("Обновляем из хранилища");
	Попытка
		МенеджерКонфигуратора.ЗапуститьОбновлениеИзХранилища(
			ПараметрыХранилища.СтрокаПодключения,  ПараметрыХранилища.Пользователь, ПараметрыХранилища.Пароль,
			ПараметрыХранилища.Версия);
	Исключение
		МенеджерКонфигуратора.Деструктор();
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

Процедура ОбновитьКонфигурациюБД(МенеджерСборки)

	Попытка
		Если РежимРазработчика = Ложь Или РежимыРеструктуризации.Первый Или РежимыРеструктуризации.Второй Тогда
			ОбщиеМетоды.ОбновитьКонфигурациюБД(МенеджерСборки,
				РежимыРеструктуризации.Первый, РежимыРеструктуризации.Второй);
		КонецЕсли;
	Исключение
		МенеджерСборки.Деструктор();
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

Процедура ДобавитьБазуВСписокБаз(НеДобавлятьВСписокБаз, ВерсияПлатформы, СтрокаПодключения)

	Если НеДобавлятьВСписокБаз Тогда
		Возврат;
	КонецЕсли;

	ДопДанныеСпискаБаз = Новый Структура;
	ДопДанныеСпискаБаз.Вставить("RootPath", КорневойПутьПроекта);
	Попытка
		Если ЗначениеЗаполнено(ВерсияПлатформы) Тогда
			ДопДанныеСпискаБаз.Вставить("Version", ВерсияПлатформы);
		КонецЕсли;
		МенеджерСпискаБаз.ДобавитьБазуВСписокБаз(СтрокаПодключения,
			Новый Файл(КорневойПутьПроекта).Имя,
				ДопДанныеСпискаБаз);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Лог.Предупреждение("Добавление базы в список " + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;

КонецПроцедуры

Функция НовыйМенеджерСборки(ПараметрыКоманды)

	Если ПараметрыХранилища.РежимОбновления Тогда
		Возврат ОбщиеМетоды.НовыйМенеджерКонфигуратора();
	Иначе
		Возврат ОбщиеМетоды.ФабрикаМенеджераСборки(ПараметрыКоманды);
	КонецЕсли;

КонецФункции

Функция СоздатьДанныеПодключения(ДанныеПодключения)

	_ДанныеПодключения = Новый Структура(ДанныеПодключения);
	КаталогБазы = ОбъединитьПути(КорневойПутьПроекта, ?(РежимРазработчика = Истина, "./build/ibservice", "./build/ib"));
	Файл = Новый Файл(КаталогБазы);
	_ДанныеПодключения.ПутьБазы = "/F""" + Файл.ПолноеИмя + """";
	_ДанныеПодключения.СтрокаПодключения = "/F""" + Файл.ПолноеИмя + """";
	_ДанныеПодключения.Пользователь = "";
	_ДанныеПодключения.Пароль = "";

	Возврат _ДанныеПодключения;

КонецФункции

#КонецОбласти
