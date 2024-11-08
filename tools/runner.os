﻿// This Source Code Form is subject to the terms of the Mozilla
// Public License, v. 2.0. If a copy of the MPL was not distributed
// with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
#Использовать cmdline
#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать v8runner
#Использовать strings
#Использовать json
#Использовать 1commands
#Использовать fs

#Использовать "../src"

Перем Лог;
Перем КодВозврата;
Перем мВозможныеКоманды;
Перем КаталогЛогов;
Перем КорневойПутьПроекта;
Перем ЭтоЗапускВКоманднойСтроке;
Перем УпаковщикВнешнихОбработок;

Функция Версия() Экспорт
	Возврат ПараметрыСистемы.ВерсияПродукта();
КонецФункции // Версия()

Функция ВозможныеКоманды()

	Если мВозможныеКоманды = Неопределено Тогда
		// Работаем в 8.3.8, внешние обработки как исходники и только исходники.
		мВозможныеКоманды = Новый Структура;

		мВозможныеКоманды.Вставить("Следить", "watch");

		мВозможныеКоманды.Вставить("ПоказатьВерсию", "version");
		мВозможныеКоманды.Вставить("Помощь", "--help");
	КонецЕсли;

	Возврат мВозможныеКоманды;

КонецФункции

Процедура ВывестиСправку()
	ПоказатьВерсию();

	Сообщить("Утилита запуска различных тестов и задач");
	Сообщить(" ");
	Сообщить("Параметры командной строки:");

	Сообщить("  watch    - следить за изменением файлов и автоматически компилировать/декомпилировать внешние обработки");

	Сообщить(" общие для всех параметры");
	Сообщить("       --v8version Маска версии платформы (8.3, 8.3.5, 8.3.6.2299 и т.п.)");
	Сообщить("       --ibname  [env RUNNER_IBNAME] строка подключения к базе данных");
	Сообщить("       --db-user [env RUNNER_DBUSER] имя пользователя для подключения к базе");
	Сообщить("       --db-pwd  [env RUNNER_DBPWD] пароль пользователя");

	Сообщить("  version");
	Сообщить("    Показ только версии продукта");

	Сообщить("  --help");
	Сообщить("    Показ этого экрана");

КонецПроцедуры

Функция ЗапуститьПроцесс(Знач СтрокаВыполнения)
	Перем ПаузаОжиданияЧтенияБуфера;

	ПаузаОжиданияЧтенияБуфера = 10;

	Лог.Отладка(СтрокаВыполнения);
	Процесс = СоздатьПроцесс(СтрокаВыполнения, , Истина);
	Процесс.Запустить();

	ТекстБазовый = "";
	Счетчик = 0;
	МаксСчетчикЦикла = 100000;

	Пока Истина Цикл
		Текст = Процесс.ПотокВывода.Прочитать();
		Лог.Отладка("Цикл ПотокаВывода " + Текст);
		Если Текст = Неопределено ИЛИ ПустаяСтрока(СокрЛП(Текст))  Тогда
			Прервать;
		КонецЕсли;
		Счетчик = Счетчик + 1;
		Если Счетчик > МаксСчетчикЦикла Тогда
			Прервать;
		КонецЕсли;
		ТекстБазовый = ТекстБазовый + Текст;

		sleep(ПаузаОжиданияЧтенияБуфера); // Подождем, надеюсь буфер не переполнится.

	КонецЦикла;

	Процесс.ОжидатьЗавершения();

	Если Процесс.КодВозврата = 0 Тогда
		Текст = Процесс.ПотокВывода.Прочитать();
		ТекстБазовый = ТекстБазовый + Текст;
		Лог.Отладка(ТекстБазовый);
		Возврат ТекстБазовый;
	Иначе
		ВызватьИсключение "Сообщение от процесса
		|" + Процесс.ПотокОшибок.Прочитать();
	КонецЕсли;

КонецФункции // ЗапуститьПроцесс

Функция СобратьФайлВнешнейОбработки(Знач ПутьКИсходникам, Знач КаталогВыгрузки,
		Знач СтрокаПодключения, Знач Пользователь, Знач Пароль, Знач ВерсияПлатформы)

	Лог.Отладка("Собираю исходники <" +ПутьКИсходникам + ">");

	ПапкаИсходников = Новый Файл(ПутьКИсходникам);
	ИмяПапки = ПапкаИсходников.Имя;
	ИмяФайлаОбъекта = ОбъединитьПути(ТекущийКаталог(), КаталогВыгрузки, ИмяПапки + ".epf");
	НайденныйФайл = НайтиФайлы(ПутьКИсходникам, "*.xml");
	Ожидаем.Что(НайденныйФайл.Количество(), "Базовый файл xml <" + ПутьКИсходникам +  ">*.xml должен существовать")
		.Больше(0);

	СобратьФайлВнешнейОбработкиИзИсходников(НайденныйФайл[0], ИмяФайлаОбъекта,
		СтрокаПодключения, Пользователь, Пароль, ВерсияПлатформы);

	Лог.Отладка("Успешно собран файл " + ИмяФайлаОбъекта);

	Возврат ИмяФайлаОбъекта;

КонецФункции

Процедура СобратьФайлВнешнейОбработкиИзИсходников(Знач ПапкаИсходников, Знач ИмяФайлаОбъекта,
		Знач СтрокаПодключения, Знач Пользователь, Знач Пароль, Знач ВерсияПлатформы)

	Лог.Отладка("Собираю файл из исходников <%1> в файл %2", ПапкаИсходников.ПолноеИмя, ИмяФайлаОбъекта);
	Лог.Отладка("");

	Конфигуратор = Новый УправлениеКонфигуратором();
	КаталогВременнойИБ = ВременныеФайлы.СоздатьКаталог();
	Конфигуратор.КаталогСборки(КаталогВременнойИБ);

	Если НЕ ПустаяСтрока(СтрокаПодключения) Тогда
		Конфигуратор.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
	КонецЕсли;

	Если НЕ ПустаяСтрока(ВерсияПлатформы) Тогда
		Лог.Отладка(ВерсияПлатформы);
		Конфигуратор.ИспользоватьВерсиюПлатформы(ВерсияПлатформы); // TODO указать разрядность платформы
	КонецЕсли;

	ЛогКонфигуратора = Логирование.ПолучитьЛог("oscript.lib.v8runner");
	ЛогКонфигуратора.УстановитьУровень(Лог.Уровень());

	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();

	Параметры.Добавить("/LoadExternalDataProcessorOrReportFromFiles");
	Параметры.Добавить(ОбщиеМетоды.ОбернутьПутьВКавычки(ПапкаИсходников.ПолноеИмя));
	Параметры.Добавить(ОбщиеМетоды.ОбернутьПутьВКавычки(ИмяФайлаОбъекта));

	Конфигуратор.ВыполнитьКоманду(Параметры);
	Лог.Отладка("Вывод 1С:Предприятия - " + Конфигуратор.ВыводКоманды());
	Лог.Отладка("Очищаем каталог временной ИБ");
	Лог.Отладка("");

КонецПроцедуры

Функция ЭтоПутьКИсходнымКодамОбработок(ПутьКПапке)

	МассивИмен = НайтиФайлы(ПутьКПапке, "*.xml", Ложь);
	Для Каждого Элемент Из МассивИмен Цикл
		ЧтениеТекста = Новый ЧтениеТекста(Элемент.ПолноеИмя);
		СодержаниеВрег = Врег(ЧтениеТекста.Прочитать());
		ЧтениеТекста.Закрыть();
		Если Найти(СодержаниеВрег, "<EXTERNALDATAPROCESSOR UUID=") > 0 ИЛИ Найти(СодержаниеВрег, "<EXTERNALREPORT UUID=") > 0 Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;

КонецФункции

Процедура ОбновитьЗависимыйКэш(АвтоОбновление, КэшПутей, КэшОбновляемый)

	Если КэшОбновляемый.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	МассивКешейДляАвтообновления = Новый Массив;
	Если АвтоОбновление <> Неопределено Тогда
		Если ТипЗнч(АвтоОбновление) = Тип("Строка") И ЗначениеЗаполнено(АвтоОбновление) Тогда
			СоответствиеПутей = Новый Соответствие;
			СоответствиеПутей.Вставить("autoupdate", АвтоОбновление);
			МассивКешейДляАвтообновления.Добавить(СоответствиеПутей);
		ИначеЕсли ТипЗнч(АвтоОбновление) = Тип("Массив") Тогда
			МассивКешейДляАвтообновления = АвтоОбновление;
		КонецЕсли;

	КонецЕсли;

	Для каждого ЭлементМассива Из МассивКешейДляАвтообновления Цикл

		Попытка
			Кэш = КэшПутей.Получить(ЭлементМассива.Получить("autoupdate"));
			Для каждого Элемент Из КэшОбновляемый Цикл
				Кэш.Вставить(Элемент.Ключ, Элемент.Значение);
			КонецЦикла;
		Исключение
			Лог.Ошибка("Ошибка обновления других кэшей " + Элемент + ":" + ОписаниеОшибки());
		КонецПопытки;
	КонецЦикла;

КонецПроцедуры

Процедура СледитьЗаИзменениямиФайловВРабочемКаталоге(Значение, КэшПутей, Фильтр = "")
	Ключ = Строка(Значение.Получить("inDir")) + "" + Строка(Значение.Получить("outDir"));
	КаталогВходящий = ПолныйПуть(Значение.Получить("inDir"));
	КаталогИсходящий = ПолныйПуть(Значение.Получить("outDir"));
	СтрокаПодключения = ОбщиеМетоды.ПереопределитьПолныйПутьВСтрокеПодключения(Значение.Получить("connectionstring"));
	Пользователь = Значение.Получить("user");
	Пароль = Значение.Получить("password");
	ВерсияПлатформы = Значение.Получить("version");
	ИмяПравила = Значение.Получить("name");
	АвтоОбновление = Значение.Получить("autoupdate");
	Если ИмяПравила <> Неопределено И Не ПустаяСтрока(ИмяПравила) Тогда
		Ключ = ИмяПравила;
	КонецЕсли;

	Если Не ПустаяСтрока(Фильтр) И Фильтр <> Ключ Тогда
		Возврат;
	КонецЕсли;

	ФайлВходящий = Новый Файл(КаталогВходящий);
	Если НЕ ФайлВходящий.Существует() Тогда
		Возврат;
	КонецЕсли;

	Если ФайлВходящий.ЭтоКаталог() Тогда
		СписокФайлов = НайтиФайлы(КаталогВходящий, ПолучитьМаскуВсеФайлы(), Истина);
	Иначе
		СписокФайлов = Новый Массив;
		СписокФайлов.Добавить(ФайлВходящий);
	КонецЕсли;

	Кэш = КэшПутей.Получить(Ключ);
	Если Кэш = Неопределено Тогда
		Лог.Информация("Начало epf to src " + Ключ);
		Кэш = Новый Соответствие;

		Для каждого Файл Из СписокФайлов Цикл
			Кэш.Вставить(Файл.ПолноеИмя, Файл.ПолучитьВремяИзменения());
		КонецЦикла;
		КэшПутей.Вставить(Ключ, Кэш);
	КонецЕсли;

	Лог.Отладка("Проверяем изменения epf " + Строка(КаталогВходящий) + "->" +Строка(КаталогИсходящий));

	КэшОбновляемый = Новый Соответствие();

	СписокОбработанных = Новый Соответствие();
	Для каждого Файл Из СписокФайлов Цикл
		Лог.Отладка("Проверяю на изменение файл <%1>", Файл.ПолноеИмя);
		Если Файл.ЭтоКаталог() Тогда
		Продолжить;  КонецЕсли;

		Изменен = Ложь;
		Время = Кэш.Получить(Файл.ПолноеИмя);
		ВремяТекущее = Файл.ПолучитьВремяИзменения();
		Если Время = Неопределено ИЛИ Время <> ВремяТекущее Тогда
			Изменен = Истина;
			Лог.Отладка("Изменен:" + Файл.ПолноеИмя + " время старое:" + Строка(Время) + " новое:" + ВремяТекущее);
		КонецЕсли;

		КаталогВходящийДляРазбора = ?(ФайлВходящий.ЭтоКаталог(), КаталогВходящий, ФайлВходящий.Путь);
		КаталогВходящийДляРазбора = ПолныйПуть(КаталогВходящийДляРазбора);

		ЭтоБинарныйОбъект1С = ОбщиеМетоды.ТипФайлаПоддерживается(Файл);
		ИмяФайлаНазначения = ?(ЭтоБинарныйОбъект1С, Файл.ИмяБезРасширения, Файл.Имя);
		ИмяФайлаНазначения = ОбъединитьПути(Файл.Путь, ИмяФайлаНазначения);

		ОтносительныйПутьФайла = ФС.ОтносительныйПуть(КаталогВходящийДляРазбора, ИмяФайлаНазначения);
		ПутьФайлаНазначения = ОбъединитьПути(КаталогИсходящий, ОтносительныйПутьФайла);

		Если ЭтоБинарныйОбъект1С Тогда
			Лог.Отладка("Анализируем внешнюю обработку/отчет %1", Файл.ПолноеИмя);
		Иначе
			Лог.Отладка("Анализ копирования простого файла %1", Файл.ПолноеИмя);
		КонецЕсли;
		Лог.Отладка("   относительный путь :%1", ОтносительныйПутьФайла);
		Лог.Отладка("   источник           :%1", КаталогВходящийДляРазбора);
		Лог.Отладка("   назначение         :%1", КаталогИсходящий);
		Лог.Отладка("   новый путь         :%1", ПутьФайлаНазначения);

		Если ЭтоБинарныйОбъект1С Тогда

			НовыйПутьВыгрузки = ПутьФайлаНазначения;
			ФайлНовойВыгрузки = Новый Файл(НовыйПутьВыгрузки);
			Если Не ФайлНовойВыгрузки.Существует() Тогда
				Изменен = Истина;
			КонецЕсли;

			Если Изменен Тогда
				Лог.Отладка("Разбираем внешнюю обработку/отчет %1", Файл.ПолноеИмя);

				СоздатьКаталог(НовыйПутьВыгрузки);
				КаталогРазобранный = УпаковщикВнешнихОбработок().РазобратьФайлВнешняяОбработка(
					Файл, КаталогИсходящий, КаталогВходящийДляРазбора, Ложь,
					СтрокаПодключения, Пользователь, Пароль, ВерсияПлатформы);

				СписокФайловНовый = НайтиФайлы(Новый Файл(КаталогРазобранный).ПолноеИмя, ПолучитьМаскуВсеФайлы(), Истина);
				Для каждого ФайлНовыйКэша Из СписокФайловНовый Цикл
					Если ФайлНовыйКэша.ЭтоКаталог() = Ложь Тогда
						Кэш.Вставить(ФайлНовыйКэша.ПолноеИмя, ФайлНовыйКэша.ПолучитьВремяИзменения());
						КэшОбновляемый.Вставить(ФайлНовыйКэша.ПолноеИмя, ФайлНовыйКэша.ПолучитьВремяИзменения());
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;

		Иначе

			ФайлНовый = Новый Файл(ПутьФайлаНазначения);
			Если Не ФайлНовый.Существует() Тогда
				Изменен = Истина;
			КонецЕсли;

			Если Изменен Тогда
				ФайлНовый = Новый Файл(ПутьФайлаНазначения);

				Лог.Отладка("Копирую файл <%1> в <%2>", Файл.ПолноеИмя, ФайлНовый.ПолноеИмя);

				КаталогНовый = Новый Файл(ФайлНовый.Путь);
				Если НЕ КаталогНовый.Существует() Тогда
					СоздатьКаталог(КаталогНовый.ПолноеИмя);
				КонецЕсли;

				Если ФайлНовый.Существует() = Истина Тогда

					Лог.Отладка(СтрШаблон("Удаляем файл %1", ПутьФайлаНазначения));
					Попытка
						УдалитьФайлы(ФайлНовый.Путь, ФайлНовый.Имя);
					Исключение
						Лог.Ошибка("Ошибка удаления файла " + ПутьФайлаНазначения + ":" + ОписаниеОшибки());
					КонецПопытки;

				КонецЕсли;

				КопироватьФайл(Файл.ПолноеИмя, ФайлНовый.ПолноеИмя);
				Кэш.Вставить(ФайлНовый.ПолноеИмя, ФайлНовый.ПолучитьВремяИзменения());
				КэшОбновляемый.Вставить(ФайлНовый.ПолноеИмя, ФайлНовый.ПолучитьВремяИзменения());
				Лог.Отладка(СтрШаблон("Завершено копирование файла %1 в каталог %2", Файл.Имя, ФайлНовый.ПолноеИмя));
			КонецЕсли;
		КонецЕсли;

		Кэш.Вставить(Файл.ПолноеИмя, Файл.ПолучитьВремяИзменения());
		СписокОбработанных.Вставить(Файл.ПолноеИмя, Истина);
	КонецЦикла;

	Для каждого Элемент Из СписокОбработанных Цикл
		Файл = Новый Файл(Элемент.Ключ);
		Кэш.Вставить(Файл.ПолноеИмя, Файл.ПолучитьВремяИзменения());
	КонецЦикла;

	КэшПутей.Вставить(Ключ, Кэш);
	Кэш = Неопределено;
	Если СписокОбработанных.Количество() > 0 Тогда
		Лог.Информация("Изменено " + Строка(СписокОбработанных.Количество()));
		КолМаксИзмененийВывода = 5;
		Для каждого Элемент Из СписокОбработанных Цикл
			Если КолМаксИзмененийВывода < 0 Тогда
				Лог.Информация("Обработано ...");
				Прервать;
			КонецЕсли;
			Лог.Информация("Обработан " + Элемент.Ключ);
			КолМаксИзмененийВывода = КолМаксИзмененийВывода - 1;
		КонецЦикла;
	КонецЕсли;

	ОбновитьЗависимыйКэш(АвтоОбновление, КэшПутей, КэшОбновляемый);

КонецПроцедуры

Процедура СледитьЗаИзменениямиФайловВРепозиторииИсходников(Значение, КэшПутей, Фильтр = "")
	Ключ = Строка(Значение.Получить("inDir")) + "" + Строка(Значение.Получить("outDir"));
	КаталогВходящий = ПолныйПуть(Значение.Получить("inDir"));
	КаталогИсходящий = ПолныйПуть(Значение.Получить("outDir"));
	СтрокаПодключения = ОбщиеМетоды.ПереопределитьПолныйПутьВСтрокеПодключения(Значение.Получить("connectionstring"));
	Пользователь = Значение.Получить("user");
	Пароль = Значение.Получить("password");
	ВерсияПлатформы = Значение.Получить("version");
	ИмяПравила = Значение.Получить("name");
	АвтоОбновление = Значение.Получить("autoupdate");
	Если ИмяПравила <> Неопределено И Не ПустаяСтрока(ИмяПравила) Тогда
		Ключ = ИмяПравила;
	КонецЕсли;

	Если Не ПустаяСтрока(Фильтр) И Фильтр <> Ключ Тогда
		Возврат;
	КонецЕсли;

	Кэш = КэшПутей.Получить(Ключ);
	Если Кэш = Неопределено Тогда
		Лог.Информация("Начало src to epf:" + Ключ);
		Кэш = Новый Соответствие;
		СписокФайлов = НайтиФайлы(КаталогВходящий, ПолучитьМаскуВсеФайлы(), Истина);
		Для каждого Файл Из СписокФайлов Цикл
			Кэш.Вставить(Файл.ПолноеИмя, Файл.ПолучитьВремяИзменения());
		КонецЦикла;
		КэшПутей.Вставить(Ключ, Кэш);
	КонецЕсли;

	Лог.Отладка("Проверяем изменения src " + Строка(КаталогВходящий) + "->" +Строка(КаталогИсходящий));

	СписокФайлов = НайтиФайлы(КаталогВходящий, ПолучитьМаскуВсеФайлы(), Истина);
	СписокОбработанных = Новый Соответствие();
	КэшОбновляемый = Новый Соответствие();
	Для каждого Файл Из СписокФайлов Цикл
		Если Файл.ЭтоКаталог() Тогда
		Продолжить; КонецЕсли;

		Время = Кэш.Получить(Файл.ПолноеИмя);
		Изменен = Ложь;
		ВремяТекущее = Файл.ПолучитьВремяИзменения();
		Если Время = Неопределено ИЛИ Время <> ВремяТекущее Тогда
			Изменен = Истина;
			Лог.Отладка("Изменен:" + Файл.ПолноеИмя + " время старое:" + Строка(Время) + " новое:" + Файл.ПолучитьВремяИзменения());
		КонецЕсли;

		Если Изменен = Истина Тогда
			ОбработкуНашли = Ложь;
			ПапкаИсходников = "";
			ПутьКИсходникамОбработки = Файл.ПолноеИмя;
			// Нам передали путь к измененному файлу, необходимо определить корневую папку.
			МаксСчетчикЦикла = 5;
			Если Файл.Расширение = ".png" Тогда
				МаксСчетчикЦикла = 7;  // \vanessa\Forms\УправляемаяФорма\Ext\Form\Items\ИмяКартинки\Picture.png
			КонецЕсли;

			Для Счетчик = 0 По МаксСчетчикЦикла Цикл
				ФайлПутьКИсходникамОбработки = Новый Файл(ПутьКИсходникамОбработки);
				Если ФайлПутьКИсходникамОбработки.ЭтоКаталог() Тогда
					ФайлПутьКИсходникамОбработки = Новый Файл(ФайлПутьКИсходникамОбработки.ПолноеИмя + "../");
				КонецЕсли;

				ПутьКИсходникамОбработки = ФайлПутьКИсходникамОбработки.Путь;
				Если ЭтоПутьКИсходнымКодамОбработок(ПутьКИсходникамОбработки) Тогда
					Лог.Отладка("Это путь к исходникам " + ПутьКИсходникамОбработки);
					ПапкаИсходников = Новый Файл(ПутьКИсходникамОбработки).ПолноеИмя;
					ОбработкуНашли = Истина;
					Прервать;
				КонецЕсли;
				ПутьКИсходникамОбработки = Новый Файл(ПутьКИсходникамОбработки).ПолноеИмя;
			КонецЦикла;


			Если ОбработкуНашли = Истина И СписокОбработанных.Получить(ПапкаИсходников) <> Неопределено Тогда
				Кэш.Вставить(Файл.ПолноеИмя, Файл.ПолучитьВремяИзменения());
				СписокОбработанных.Вставить(Файл.ПолноеИмя, Истина);
			ИначеЕсли ОбработкуНашли = Истина Тогда
				ПутьОтносительно = ?(ПолныйПуть(КаталогВходящий) = ПапкаИсходников, "./", "../");
				КаталогВыгрузкиОбработки = Новый Файл(ОбъединитьПути(КаталогИсходящий, ФС.ОтносительныйПуть(ПолныйПуть(КаталогВходящий), ПапкаИсходников), ПутьОтносительно)).ПолноеИмя;
				ИмяФайлаОбъекта = СобратьФайлВнешнейОбработки(ПапкаИсходников, КаталогВыгрузкиОбработки, СтрокаПодключения, Пользователь, Пароль, ВерсияПлатформы);

				КаталогФайл = Новый Файл(ИмяФайлаОбъекта);
				СписокСобранныхОбработок = НайтиФайлы(КаталогВыгрузкиОбработки, "" + КаталогФайл.Имя + "*");

				Для каждого ЭлементОбработки Из СписокСобранныхОбработок Цикл
					Кэш.Вставить(ЭлементОбработки.ПолноеИмя, ЭлементОбработки.ПолучитьВремяИзменения());
					КэшОбновляемый.Вставить(ЭлементОбработки.ПолноеИмя, ЭлементОбработки.ПолучитьВремяИзменения());
				КонецЦикла;
				СписокОбработанных.Вставить(ПапкаИсходников, Истина);
			Иначе
				НовыйПутьВыгрузки = ОбъединитьПути(КаталогИсходящий, ФС.ОтносительныйПуть(ПолныйПуть(КаталогВходящий), Файл.ПолноеИмя));
				Лог.Отладка("Копируем " + Файл.ПолноеИмя + "->" +НовыйПутьВыгрузки);
				НовыйКаталог = Новый Файл(Новый Файл(НовыйПутьВыгрузки).Путь);
				Если НовыйКаталог.Существует() = Ложь Тогда
					СоздатьКаталог(НовыйКаталог.ПолноеИмя);
				КонецЕсли;
				КопироватьФайл(Файл.ПолноеИмя, НовыйПутьВыгрузки);

				ФайлСобранный = Новый Файл(НовыйПутьВыгрузки);
				Кэш.Вставить(ФайлСобранный.ПолноеИмя, ФайлСобранный.ПолучитьВремяИзменения());
				КэшОбновляемый.Вставить(ФайлСобранный.ПолноеИмя, ФайлСобранный.ПолучитьВремяИзменения());
			КонецЕсли;
			Кэш.Вставить(Файл.ПолноеИмя, Файл.ПолучитьВремяИзменения());
			СписокОбработанных.Вставить(Файл.ПолноеИмя, Истина);
		КонецЕсли;
	КонецЦикла;

	Для каждого Элемент Из СписокОбработанных Цикл
		Файл = Новый Файл(Элемент.Ключ);
		Кэш.Вставить(Файл.ПолноеИмя, Файл.ПолучитьВремяИзменения());
	КонецЦикла;

	КэшПутей.Вставить(Ключ, Кэш);
	Кэш = Неопределено;
	Если СписокОбработанных.Количество() > 0 Тогда
		Лог.Информация("Изменено " + Строка(СписокОбработанных.Количество()));
		КолМаксИзмененийВывода = 5;
		Для каждого Элемент Из СписокОбработанных Цикл
			Если КолМаксИзмененийВывода < 0 Тогда
				Лог.Информация("Обработано ...");
				Прервать;
			КонецЕсли;
			Лог.Информация("Обработан " + Элемент.Ключ);
			КолМаксИзмененийВывода = КолМаксИзмененийВывода - 1;
		КонецЦикла;
	КонецЕсли;

	ОбновитьЗависимыйКэш(АвтоОбновление, КэшПутей, КэшОбновляемый);

КонецПроцедуры

Процедура СледитьЗаИзменениямиИсходниковCF(Значение, КэшПутей, Фильтр = "")
	Если Значение <> Неопределено Тогда
		Ключ = Строка(Значение.Получить("inDir"));
		КаталогВходящий = ПолныйПуть(Значение.Получить("inDir"));
		СтрокаПодключения = ОбщиеМетоды.ПереопределитьПолныйПутьВСтрокеПодключения(Значение.Получить("connectionstring"));
		Пользователь = Значение.Получить("user");
		Пароль = Значение.Получить("password");
		ВерсияПлатформы = Значение.Получить("version");
		АвтоОбновление = Значение.Получить("autoupdate");
		ИмяПравила = Значение.Получить("name");
		Если ИмяПравила <> Неопределено И Не ПустаяСтрока(ИмяПравила) Тогда
			Ключ = ИмяПравила;
		КонецЕсли;

		МенеджерКонфигуратора = Новый МенеджерКонфигуратора;
		МенеджерКонфигуратора.Инициализация(Неопределено, СтрокаПодключения, Пользователь, Пароль, ВерсияПлатформы);

		Если Не ПустаяСтрока(Фильтр) И Фильтр <> Ключ Тогда
			Возврат;
		КонецЕсли;

		Если АвтоОбновление = Истина Или АвтоОбновление = "true" Тогда
			АвтоОбновление = Истина;
		КонецЕсли;

		Кэш = КэшПутей.Получить(Ключ);
		Если Кэш = Неопределено Тогда
			Лог.Информация("Начало src to cf " + Ключ);
			Кэш = Новый Соответствие;
			СписокФайлов = НайтиФайлы(КаталогВходящий, ПолучитьМаскуВсеФайлы(), Истина);
			Для каждого Файл Из СписокФайлов Цикл
				Кэш.Вставить(Файл.ПолноеИмя, Файл.ПолучитьВремяИзменения());
			КонецЦикла;
			КэшПутей.Вставить(Ключ, Кэш);
		КонецЕсли;

		Лог.Отладка("Проверяем изменения cf " + Строка(КаталогВходящий));

		СписокФайлов = НайтиФайлы(КаталогВходящий, ПолучитьМаскуВсеФайлы(), Истина);
		СписокОбработанных = Новый Соответствие();

		Для каждого Файл Из СписокФайлов Цикл
			Если Файл.ЭтоКаталог() Тогда
				Продолжить;
			КонецЕсли;

			Изменен = Ложь;
			Время = Кэш.Получить(Файл.ПолноеИмя);
			ВремяТекущее = Файл.ПолучитьВремяИзменения();
			Если Время = Неопределено ИЛИ Время <> ВремяТекущее Тогда
				Изменен = Истина;
				Лог.Отладка("Изменен:" + Файл.ПолноеИмя + " время старое:" + Строка(Время) + " новое:" + Файл.ПолучитьВремяИзменения());
			КонецЕсли;

			Если Изменен = Истина Тогда
				СписокОбработанных.Вставить(Файл.ПолноеИмя, Файл);
			КонецЕсли;
		КонецЦикла;

		Если СписокОбработанных.Количество() > 0 Тогда
			СписокДляЗагрузки = "";
			ПервыйРаз = Истина;
			Для каждого ИмяФайла Из СписокОбработанных Цикл
				Если ПервыйРаз Тогда
					СписокДляЗагрузки = "" + ИмяФайла.Ключ;
					ПервыйРаз = Ложь;
				КонецЕсли;
				СписокДляЗагрузки = СписокДляЗагрузки + Символы.ПС + ИмяФайла.Ключ;
			КонецЦикла;
			КонфигурацияЗагружена = Ложь;
			Попытка
				МенеджерКонфигуратора.СобратьИзИсходниковТекущуюКонфигурацию(КаталогВходящий, СписокДляЗагрузки);
				Для каждого ИмяФайла Из СписокОбработанных Цикл
					Кэш.Вставить(ИмяФайла.Значение.ПолноеИмя, ИмяФайла.Значение.ПолучитьВремяИзменения());
				КонецЦикла;
				КонфигурацияЗагружена = Истина;
			Исключение
				Лог.Ошибка("Ошибка загрузки файлов конфигурации:" + ОписаниеОшибки());
			КонецПопытки;

			Если КонфигурацияЗагружена = Истина И АвтоОбновление = Истина Тогда
				Попытка
					МенеджерКонфигуратора.ОбновитьКонфигурациюБазыДанных();
				Исключение
					Лог.Ошибка("Ошибка обновления конфигурации:" + ОписаниеОшибки());
				КонецПопытки;

			КонецЕсли;

			Лог.Информация("Загрузка изменений завершена:" + КаталогВходящий);
		КонецЕсли;

	КонецЕсли;
КонецПроцедуры

Процедура Следить(Знач ФайлНастроек = "", Знач Фильтр = "")
	Перем КэшПутей;
	КэшПутей = Новый Соответствие;
	ФайлНастроек = ПолныйПуть(ФайлНастроек);
	Настройки = ОбщиеМетоды.ПрочитатьФайлJSON(ФайлНастроек);
	Пока Истина Цикл
		Для каждого Элемент Из Настройки Цикл
			Значение = Элемент.Получить("check-source-repo");
			Если Значение = Неопределено Тогда
				Значение = Элемент.Получить("srctoepf");
			КонецЕсли;
			Если Значение <> Неопределено Тогда
				СледитьЗаИзменениямиФайловВРепозиторииИсходников(Значение, КэшПутей, Фильтр);
			КонецЕсли;

			Значение = Элемент.Получить("check-work-copy");
			Если Значение = Неопределено Тогда
				Значение = Элемент.Получить("epftosrc");
			КонецЕсли;
			Если Значение <> Неопределено Тогда
				СледитьЗаИзменениямиФайловВРабочемКаталоге(Значение, КэшПутей, Фильтр);
			КонецЕсли;

			Значение = Элемент.Получить("check-config-sources");
			Если Значение = Неопределено Тогда
				Значение = Элемент.Получить("srccftoib");
			КонецЕсли;
			СледитьЗаИзменениямиИсходниковCF(Значение, КэшПутей);
		КонецЦикла;
		sleep(8000);
	КонецЦикла;

КонецПроцедуры

Процедура УстановитьКаталогТекущегоПроекта(Знач Путь = "")
	КорневойПутьПроекта = "";
	Если ПустаяСтрока(Путь) Тогда
		Попытка
			КорневойПутьПроекта = СокрЛП(ЗапуститьПроцесс("git rev-parse --show-toplevel"));
		Исключение
			Лог.Отладка(ОписаниеОшибки());
		КонецПопытки;
	Иначе
		КорневойПутьПроекта = Путь;
	КонецЕсли;

	ПараметрыСистемы.КорневойПутьПроекта = КорневойПутьПроекта;

	Лог.Отладка("Текущий корень проекта:" + КорневойПутьПроекта);

КонецПроцедуры // УстановитьКаталогТекущегоПроекта()

Функция ЭтоЗапускВКоманднойСтроке()
	Возврат ТекущийСценарий().Источник = СтартовыйСценарий().Источник;
КонецФункции

Процедура ПодготовитьЛоги()
	Лог_cmdline = Логирование.ПолучитьЛог("oscript.lib.cmdline");
	Лог_v8runner = Логирование.ПолучитьЛог("oscript.lib.v8runner");

	ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
	Лог_cmdline.ДобавитьСпособВывода(ВыводПоУмолчанию);
	Лог_v8runner.ДобавитьСпособВывода(ВыводПоУмолчанию);

	УровеньЛога = Лог.Уровень(); // учитываю возможность внешней настройки лога

	Если УровеньЛога = УровниЛога.Отладка Тогда

		Аппендер = Новый ВыводЛогаВФайл();

		ИмяВременногоФайла = ОбщиеМетоды.ПолучитьИмяВременногоФайлаВКаталоге(КаталогЛогов, СтрШаблон("%1.cmdline.log", ИмяСкрипта()));
		Аппендер.ОткрытьФайл(ИмяВременногоФайла);
		Лог_cmdline.ДобавитьСпособВывода(Аппендер);
	КонецЕсли;

	Если УровеньЛога > УровниЛога.Отладка Тогда
		УровеньЛога = УровниЛога.Ошибка;
	КонецЕсли;
	Лог_cmdline.УстановитьУровень(УровеньЛога);
	Лог_v8runner.УстановитьУровень(УровеньЛога);

	Лог_v8runner.УстановитьРаскладку(ЭтотОбъект);
	Лог_cmdline.УстановитьРаскладку(ЭтотОбъект);
КонецПроцедуры

Процедура ОсновнаяРабота()

	ПодготовитьЛоги();

	КодВозврата = 0;

	Попытка

		Парсер = Новый ПарсерАргументовКоманднойСтроки();

		Парсер.ДобавитьИменованныйПараметр("--ibname", "Строка подключения к БД", Истина);
		Парсер.ДобавитьИменованныйПараметр("--db-user", "Пользователь БД", Истина);
		Парсер.ДобавитьИменованныйПараметр("--db-pwd", "Пароль БД", Истина);
		Парсер.ДобавитьИменованныйПараметр("--v8version", "Версия платформы", Истина);
		Парсер.ДобавитьИменованныйПараметр("--root", "Полный путь к проекту", Истина);
		Парсер.ДобавитьИменованныйПараметр("--ordinaryapp", "Запуск толстого клиента (1 = толстый, 0 = тонкий клиент)", Истина);
		Парсер.ДобавитьИменованныйПараметр("--settings", "Путь к файлу настроек, в формате json", Истина);

		ДобавитьОписаниеКомандыПомощь(Парсер);
		ДобавитьОписаниеКомандыПоказатьВерсию(Парсер);

		ДобавитьОписаниеКомандыСледить(Парсер);

		Аргументы = Парсер.РазобратьКоманду(АргументыКоманднойСтроки);
		Лог.Отладка("ТипЗнч(Аргументы)= " +ТипЗнч(Аргументы));
		Если Аргументы = Неопределено Тогда
			ВывестиСправку();
			Возврат;
		КонецЕсли;

		Команда = Аргументы.Команда;

		Если Команда = ВозможныеКоманды().Помощь Тогда
			ВывестиСправку();
			Возврат;
		ИначеЕсли Команда = ВозможныеКоманды().ПоказатьВерсию Тогда
			ПоказатьВерсиюКратко();
			Возврат;
		КонецЕсли;

		ПоказатьВерсию();

		Лог.Отладка("Передана команда: " + Команда);

		СоответствиеПеременных = Новый Соответствие();
		СоответствиеПеременных.Вставить("RUNNER_IBNAME", "--ibname");
		СоответствиеПеременных.Вставить("RUNNER_DBUSER", "--db-user");
		СоответствиеПеременных.Вставить("RUNNER_DBPWD", "--db-pwd");
		СоответствиеПеременных.Вставить("RUNNER_v8version", "--v8version");
		СоответствиеПеременных.Вставить("RUNNER_uccode", "--uccode");
		СоответствиеПеременных.Вставить("RUNNER_command", "--command");
		СоответствиеПеременных.Вставить("RUNNER_execute", "--execute");
		СоответствиеПеременных.Вставить("RUNNER_storage-user", "--storage-user");
		СоответствиеПеременных.Вставить("RUNNER_storage-pwd", "--storage-pwd");
		СоответствиеПеременных.Вставить("RUNNER_storage-ver", "--storage-ver");
		СоответствиеПеременных.Вставить("RUNNER_storage-name", "--storage-name");
		СоответствиеПеременных.Вставить("RUNNER_ROOT", "--root");
		СоответствиеПеременных.Вставить("RUNNER_WORKSPACE", "--workspace");
		СоответствиеПеременных.Вставить("RUNNER_NOCACHEUSE", "--nocacheuse");

		УстановитьКаталогТекущегоПроекта(Аргументы.ЗначенияПараметров["--root"]);

		ПутьКФайлуНастроекПоУмолчанию = ОбъединитьПути(КорневойПутьПроекта, ОбщиеМетоды.ИмяФайлаНастроек());

		НастройкиИзФайла = ОбщиеМетоды.ПрочитатьНастройкиФайлJSON(КорневойПутьПроекта,
			Аргументы.ЗначенияПараметров["--settings"], ПутьКФайлуНастроекПоУмолчанию);

		ЗначенияПараметровНизкийПриоритет = Новый Соответствие;

		Если НастройкиИзФайла.Количество() > 0 Тогда
			ОбщиеМетоды.ДополнитьАргументыИзФайлаНастроек(Команда, ЗначенияПараметровНизкийПриоритет, НастройкиИзФайла);
		КонецЕсли;

		ОбщиеМетоды.ЗаполнитьЗначенияИзПеременныхОкружения(ЗначенияПараметровНизкийПриоритет, СоответствиеПеременных);
		ОбщиеМетоды.ДополнитьСоответствиеСУчетомПриоритета(Аргументы.ЗначенияПараметров, ЗначенияПараметровНизкийПриоритет);

		УстановитьКаталогТекущегоПроекта(Аргументы.ЗначенияПараметров["--root"]); // на случай переопределения этой настройки повторная установка

		Если ЗначениеЗаполнено(Аргументы.ЗначенияПараметров["--ibname"]) Тогда // TODO перенести в main.os
			Аргументы.ЗначенияПараметров.Вставить("--ibname", ОбщиеМетоды.ПереопределитьПолныйПутьВСтрокеПодключения(Аргументы.ЗначенияПараметров["--ibname"]));
		КонецЕсли;

		Если Команда = ВозможныеКоманды().Следить Тогда
			Следить(Аргументы.ЗначенияПараметров["inputPath"], Аргументы.ЗначенияПараметров["--filter"]);
		КонецЕсли;

	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		КодВозврата = 1;
	КонецПопытки;

	ВременныеФайлы.Удалить();

КонецПроцедуры

Процедура ДобавитьОписаниеКомандыПомощь(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Помощь);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыПоказатьВерсию(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().ПоказатьВерсию);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыСледить(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Следить);
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "inputPath");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--filter", "Фильтр настроек для слежения");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры // ДобавитьОписаниеКомандыСледить

Процедура Инициализация()

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ПараметрыСистемы.ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;

	Лог = Логирование.ПолучитьЛог("oscript.app.vanessa-runner");
	Попытка
		КаталогЛогов = СокрЛП(ЗапуститьПроцесс("git rev-parse --show-toplevel"));
	Исключение
		КаталогЛогов = ВременныеФайлы.НовоеИмяФайла(ИмяСкрипта());
		СоздатьКаталог(КаталогЛогов);
	КонецПопытки;

	Если ЭтоЗапускВКоманднойСтроке Тогда
		Лог.Закрыть(); // для исключения двойного вывода сообщений, например, в случае повторного вызова команд

		УровеньЛога = Лог.Уровень(); // учитываю возможность внешней настройки лога

		РежимРаботы = ПолучитьПеременнуюСреды("RUNNER_ENV");
		Если ЗначениеЗаполнено(РежимРаботы) И Нрег(РежимРаботы) = "debug" Тогда
			УровеньЛога = УровниЛога.Отладка;
			Лог.УстановитьУровень(УровеньЛога);
		КонецЕсли;

		Если ЭтоЗапускВКоманднойСтроке И УровеньЛога = УровниЛога.Отладка Тогда
			Аппендер = Новый ВыводЛогаВФайл();

			ИмяВременногоФайла = ОбщиеМетоды.ПолучитьИмяВременногоФайлаВКаталоге(КаталогЛогов, СтрШаблон("%1.log", ИмяСкрипта()));
			Аппендер.ОткрытьФайл(ИмяВременногоФайла);
			Лог.ДобавитьСпособВывода(Аппендер);
		КонецЕсли;

		Лог.УстановитьРаскладку(ЭтотОбъект);

		Если ЭтоЗапускВКоманднойСтроке Тогда
			ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
			Лог.ДобавитьСпособВывода(ВыводПоУмолчанию);
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////
// РЕАЛИЗАЦИЯ КОМАНД

Функция ПолныйПуть(Знач Путь, Знач КаталогПроекта = "")
	Возврат ОбщиеМетоды.ПолныйПуть(Путь, КаталогПроекта);
КонецФункции

Процедура ПоказатьВерсию()
	Сообщить("vanessa-runner v" + Версия());
	Сообщить("");
КонецПроцедуры

Процедура ПоказатьВерсиюКратко()
	Сообщить(Версия());
КонецПроцедуры

Функция ИмяСкрипта()
	ФайлИсточника = Новый Файл(ТекущийСценарий().Источник);
	Возврат ФайлИсточника.ИмяБезРасширения;
КонецФункции

Функция УпаковщикВнешнихОбработок()
	Если УпаковщикВнешнихОбработок = Неопределено Тогда
		УпаковщикВнешнихОбработок = Новый УпаковщикВнешнихОбработок;
		УпаковщикВнешнихОбработок.УстановитьЛог(Лог);
	КонецЕсли;
	Возврат УпаковщикВнешнихОбработок;
КонецФункции

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

	Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

ЭтоЗапускВКоманднойСтроке = ЭтоЗапускВКоманднойСтроке();

Инициализация();

Если ЭтоЗапускВКоманднойСтроке Тогда
	ОсновнаяРабота();
	ЗавершитьРаботу(КодВозврата);
КонецЕсли;
