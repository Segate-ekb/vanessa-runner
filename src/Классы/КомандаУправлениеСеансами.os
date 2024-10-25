
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Настройки;
Перем Лог;
Перем ЭтоУправлениеСеансами, ЭтоУправлениеРегламентнымиЗаданиями, ЭтоПолучениеИнформацииИБ;
Перем МенеджерФильтраПриложений;
Перем МенеджерRAC;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписанияКоманды = Неопределено;
	ОпределитьНазначениеКоманды(ИмяКоманды, ТекстОписанияКоманды);

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, ТекстОписанияКоманды);

	Если ЭтоУправлениеРегламентнымиЗаданиями Или ЭтоУправлениеСеансами Тогда
		Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "Действие",
			?(ЭтоУправлениеСеансами, "lock|unlock|kill|closed
			|Действие kill по умолчанию также устанавливает блокировку начала сеансов пользователей. Для подавления этого эффекта используется ключ -with-nolock.
			|Действие closed предназначено для проверки отсутствия сеансов. Например, может применяться для проверки того, что после блокировки, все регламенты завершили свою работу.
			|Если сеансы оказались найдены, то происходит завершение работы скрипта с ошибкой.",
			"lock|unlock")
		);
	КонецЕсли;
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--ras", "Сетевой адрес RAS, по умолчанию localhost:1545");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--rac", "Команда запуска RAC, по умолчанию находим в каталоге установки 1с");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--db", "Имя информационной базы");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
		"--cluster-admin",
		"[env RUNNER_CLUSTERADMIN_USER] Администратор кластера");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
		"--cluster-pwd",
		"[env RUNNER_CLUSTERADMIN_PWD] Пароль администратора кластера");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
		"--cluster",
		"Идентификатор кластера");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
		"--cluster-name",
		"Имя кластера");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
		"--try",
		"Число попыток обращения по протоколу rac/ras");

	Если ЭтоУправлениеСеансами Тогда

		Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
			"--uccode",
			"Ключ разрешения запуска");

		Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
			"--lockmessage",
			"Сообщение блокировки");

		Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
			"--lockstart",
			"Время старта блокировки пользователей, время указываем как '2040-12-31T23:59:59'");

		Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
			"--lockend",
			"Время окончания блокировки пользователей, время указываем как '2040-12-31T23:59:59'");

		Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
			"--lockstartat",
			"Время старта блокировки через n сек");
		
		Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды,
			"--with-nolock",
			"Не блокировать сеансы (y/n). Может применяться для действия kill, т.к. по умолчанию, при его выполнении автоматически блокируется начало сеансов.
			|Пример: ... kill --with-nolock ...");

		Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды,
			"--lockendclear",
			"Очищать дату окончания блокировки (y/n). Может применяться для действия lock.
			|Пример: ... lock --with-nolock ...");

		Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
			"--filter",
			"Фильтр поиска сеансов. Предполагает возможность указания множественных вариантов фильтрации. Задается в формате '[filter1]|[filter2]|...|[filterN]'.
			|Составляющая фильтра задается в формате [[appid=приложение1[;приложение2]][[name=username1[;username2]]'.
			|Пока предусмотрено только два фильтра - по имени приложения (appid) и по имени пользователя 1С (name).
			|Для фильтра по приложению доступны следующие имена: 1CV8 1CV8C WebClient Designer COMConnection WSConnection BackgroundJob WebServerExtension.
			|Использование wildchar/regex пока не предусмотрено. Регистронезависимо. Параметры должны разделяться через |.
			|Действует для команд kill и closed.
			|Пример: ... kill -filter appid=Designer|name=регламент;администратор ...");

		Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
			"--mode",
			"Настройка для управления режимом фильтра поиска сеансов '--filter'. Возможные варианты:
			|* ONLY - Только указанные фильтры считаются включенными. Используется по умолчанию.
			|OFF - Все фильтры считаются выключенными, вне зависимости от их заполнения.
			|EXCEPT - Все фильтры, кроме указанных, считаются включенными. Режим пропуска сеансов по фильтру.
			|DEFAULT - Все фильтры, включенные по умолчанию (встроенные настройки vanessa-runner, в текущем релизе их нет, фильтрации просто не будет! ) считаются включенными, остальные - игнорируются.
			|ALL - Все фильтры (и пользовательские, и встроенные) считаются включенными.
			|Если режим не указан, применяется режим ONLY. Если не задана строка фильтра, то фильтр не применяется!
			|Пример: ... kill -filter appid=Designer --mode EXCEPT...");

	КонецЕсли;

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

Процедура ОпределитьНазначениеКоманды(Знач ИмяКоманды, ТекстОписанияКоманды)

	ЭтоУправлениеСеансами = НРег(ИмяКоманды) = ПараметрыСистемы.ВозможныеКоманды().УправлениеСеансами;
	ЭтоУправлениеРегламентнымиЗаданиями = НРег(ИмяКоманды) = ПараметрыСистемы.ВозможныеКоманды().УправлениеРегламентнымиЗаданиями;
	ЭтоПолучениеИнформацииИБ = НРег(ИмяКоманды) = ПараметрыСистемы.ВозможныеКоманды().ЗапроситьПараметрыБД;

	Если Не ЭтоПолучениеИнформацииИБ И Не ЭтоУправлениеРегламентнымиЗаданиями И Не ЭтоУправлениеСеансами Тогда
		ВызватьИсключение("Непредусмотренное имя команды: " + ИмяКоманды);
	КонецЕсли;

	Если ЭтоПолучениеИнформацииИБ Тогда
		ТекстОписанияКоманды =
		"     Получение информации о базе данных (выводится в консоль выполнения скрипта).
		|		Может применяться для проверки работы RAS/RAC.";
	ИначеЕсли ЭтоУправлениеРегламентнымиЗаданиями Тогда
		ТекстОписанияКоманды =
		"     Управление возможностью работы регламентных заданий.";
	ИначеЕсли ЭтоУправлениеСеансами Тогда
		ТекстОписанияКоманды =
		"     Управление сеансами информационной базы.";
	КонецЕсли;

КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Попытка
		Лог = ДополнительныеПараметры.Лог;
	Исключение
		Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	КонецПопытки;

	Настройки = ПрочитатьПараметры(ПараметрыКоманды);

	Если Не ПараметрыВведеныКорректно() Тогда
		Возврат МенеджерКомандПриложения.РезультатыКоманд().НеверныеПараметры;
	КонецЕсли;

	Если ЭтоУправлениеСеансами И Настройки.Действие = "lock" Тогда
		УстановитьСтатусБлокировкиСеансов(Истина);
	ИначеЕсли ЭтоУправлениеСеансами И Настройки.Действие = "unlock" Тогда
		УстановитьСтатусБлокировкиСеансов(Ложь);
	ИначеЕсли ЭтоУправлениеСеансами И Настройки.Действие = "kill" Тогда
		УдалитьВсеСеансыИСоединенияБазы();
	ИначеЕсли ЭтоУправлениеСеансами И Настройки.Действие = "closed" Тогда
		Возврат ?(ПолучитьСписокСеансов().Количество() = 0,
			МенеджерКомандПриложения.РезультатыКоманд().Успех,
			МенеджерКомандПриложения.РезультатыКоманд().ОшибкаВремениВыполнения
		);

	ИначеЕсли ЭтоУправлениеРегламентнымиЗаданиями И Настройки.Действие = "lock" Тогда
		УстановитьСтатусБлокировкиРЗ(Истина);
	ИначеЕсли ЭтоУправлениеРегламентнымиЗаданиями И Настройки.Действие = "unlock" Тогда
		УстановитьСтатусБлокировкиРЗ(Ложь);

	ИначеЕсли ЭтоПолучениеИнформацииИБ Тогда
		// сообщить информацию
		Информация = ПолучитьИнформациюОБазеДанных();
		Сообщить(Информация);

	Иначе
		Лог.Ошибка("Неизвестное действие: " + Настройки.Действие);
		Возврат МенеджерКомандПриложения.РезультатыКоманд().НеверныеПараметры;
	КонецЕсли;

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции

Функция ПрочитатьПараметры(Знач ПараметрыКоманды)

	Результат = Новый Структура;

	ОбщиеМетоды.ПоказатьПараметрыВРежимеОтладки(ПараметрыКоманды);
	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];

	Результат.Вставить("АдресСервераАдминистрирования", ОбщиеМетоды.Параметр(ПараметрыКоманды, "--ras", "localhost:1545"));
	Результат.Вставить("ПутьКлиентаАдминистрирования", ПараметрыКоманды["--rac"]);
	Результат.Вставить("ИмяИБ", ПараметрыКоманды["--db"]);
	Результат.Вставить("АдминистраторИБ", ДанныеПодключения.Пользователь);
	Результат.Вставить("ПарольАдминистратораИБ", ДанныеПодключения.Пароль);
	Результат.Вставить("АдминистраторКластера", ПараметрыКоманды["--cluster-admin"]);
	Результат.Вставить("ПарольАдминистратораКластера", ПараметрыКоманды["--cluster-pwd"]);
	Результат.Вставить("ИдентификаторКластера", ПараметрыКоманды["--cluster"]);
	Результат.Вставить("ИмяКластера", ПараметрыКоманды["--cluster-name"]);
	Результат.Вставить("ИспользуемаяВерсияПлатформы", ПараметрыКоманды["--v8version"]);
	Результат.Вставить("КлючРазрешенияЗапуска", ПараметрыКоманды["--uccode"]);
	Результат.Вставить("СообщениеОблокировке", ПараметрыКоманды["--lockmessage"]);
	Результат.Вставить("ВремяСтартаБлокировки", ПараметрыКоманды["--lockstart"]);
	Результат.Вставить("ВремяОкончанияБлокировки", ПараметрыКоманды["--lockend"]);
	Результат.Вставить("ВремяСтартаБлокировкиЧерез", ПараметрыКоманды["--lockstartat"]);
	Результат.Вставить("ЧислоПопыток", ПараметрыКоманды["--try"]);
	Результат.Вставить("ОчищатьВремяОкончанияБлокировки", ПараметрыКоманды["--lockendclear"]);
	Результат.Вставить("НеБлокироватьСеансы", ПараметрыКоманды["--with-nolock"]);

	МенеджерФильтраПриложений = Новый МенеджерФильтраПриложений(ПараметрыКоманды["--filter"], ПараметрыКоманды["--mode"]);
	МенеджерФильтраПриложений.УстановитьЛог(Лог);

	Результат.Вставить("Действие", ПараметрыКоманды["Действие"]);

	МенеджерRac = Новый МенеджерRAC(Результат, ПараметрыКоманды, Лог);

	// Получим путь к платформе, если вдруг не установленна
	Результат.Вставить("ПутьКлиентаАдминистрирования", МенеджерRac.ПолучитьПутьRAC());

	Возврат Результат;
КонецФункции

Функция ПараметрыВведеныКорректно()

	Успех = Истина;

	Если Не ЗначениеЗаполнено(Настройки.АдресСервераАдминистрирования) Тогда
		Лог.Ошибка("Не указан сервер администрирования");
		Успех = Ложь;
	КонецЕсли;

	Если Не ЗначениеЗаполнено(Настройки.ПутьКлиентаАдминистрирования) Тогда
		Лог.Ошибка("Не указан клиент администрирования");
		Успех = Ложь;
	КонецЕсли;

	Если Не ЗначениеЗаполнено(Настройки.ИмяИБ) Тогда
		Лог.Ошибка("Не указано имя базы данных");
		Успех = Ложь;
	КонецЕсли;

	Если (ЭтоУправлениеРегламентнымиЗаданиями Или ЭтоУправлениеСеансами) И Не ЗначениеЗаполнено(Настройки.Действие) Тогда
		Лог.Ошибка("Не указано действие lock/unlock");
		Успех = Ложь;
	КонецЕсли;

	Если Настройки.ЧислоПопыток <> Неопределено Тогда
		Попытка
			ПопыткиЧислом = Число(Настройки.ЧислоПопыток);
		Исключение
			Лог.Ошибка("Параметр --try не является числовым.");
			Успех = Ложь;
		КонецПопытки;

		Если Успех И ПопыткиЧислом <= 0 Тогда
			ПопыткиЧислом = 1;
			Лог.Предупреждение("Параметр --try не представляет собой число попыток. Он будет проигнорирован");
		КонецЕсли;

		Если Успех Тогда
			Настройки.ЧислоПопыток = ПопыткиЧислом;
		Иначе
			Настройки.ЧислоПопыток = 1;
		КонецЕсли;
	Иначе
		Настройки.ЧислоПопыток = 1;
	КонецЕсли;

	Возврат Успех;

КонецФункции

/////////////////////////////////////////////////////////////////////////////////
// Взаимодействие с кластером

Процедура УдалитьВсеСеансыИСоединенияБазы()

	Если Настройки.НеБлокироватьСеансы = Неопределено Или Настройки.НеБлокироватьСеансы = Ложь Тогда
		УстановитьСтатусБлокировкиСеансов(Истина);
	КонецЕсли;

	Пауза_ПолСекунды = 500;
	Пауза_ДесятьСек = 10000;
	УспешноеУдалениеСеансов = Ложь;
	ОшибкаУдаленияСеансов = "";

	Для Сч = 1 По Настройки.ЧислоПопыток Цикл
		Попытка

			ОтключитьСуществующиеСеансы();
			Приостановить(Пауза_ПолСекунды);
			Сеансы = ПолучитьСписокСеансов();

			// соединения будет отключать всегда, так как могут быть зависшие
			Лог.Информация("Пауза перед отключением соединений");
			Приостановить(Пауза_ДесятьСек);
			ОтключитьСоединенияСРабочимиПроцессами();
			
			Сеансы = ПолучитьСписокСеансов();
			Если Сеансы.Количество() = 0 Тогда
				УспешноеУдалениеСеансов = Истина;
				Прервать;
			КонецЕсли;

		Исключение
			УспешноеУдалениеСеансов = Ложь;
			ОшибкаУдаленияСеансов = ИнформацияОбОшибке().Описание;
			Лог.Информация("Попытка удаления сеансов №" + Сч + " неудачна. Текст ошибки:
			|" + ОшибкаУдаленияСеансов);						
		КонецПопытки;
	КонецЦикла;
	Если Не УспешноеУдалениеСеансов Тогда
		ВызватьИсключение СтрШаблон("Попытка удаления сеансов не удалась. Текст ошибки:
			|%1", ОшибкаУдаленияСеансов);
	КонецЕсли;

КонецПроцедуры

Процедура УстановитьСтатусБлокировкиСеансов(Знач Блокировать)

	КлючиАвторизацииВБазе = МенеджерRAC.КлючиАвторизацииВБазе();

	ОписаниеКластера = МенеджерRac.ОписаниеКластера();
	ИдентификаторКластера = МенеджерRac.ИдентификаторКластера(ОписаниеКластера);
	ИдентификаторБазы = МенеджерRAC.ИдентификаторБазы();

	Если Блокировать Тогда
		КлючРазрешенияЗапускаПоУмолчанию = ИдентификаторБазы;
	Иначе
		КлючРазрешенияЗапускаПоУмолчанию = "";
	КонецЕсли;
	КлючРазрешенияЗапуска = ?(ПустаяСтрока(Настройки.КлючРазрешенияЗапуска), КлючРазрешенияЗапускаПоУмолчанию, Настройки.КлючРазрешенияЗапуска);

	Если Блокировать Тогда
		ВремяБлокировки = Настройки.ВремяСтартаБлокировки;
		Если ПустаяСтрока(ВремяБлокировки) И Не ПустаяСтрока(Настройки.ВремяСтартаБлокировкиЧерез) Тогда
			Секунды = 0;
			Попытка
				Секунды = Число(Настройки.ВремяСтартаБлокировкиЧерез);
			Исключение
				Лог.Предупреждение("Не удалось получить количество секунд ожидания перед блокировкой. Текст ошибки:
				|%1", ИнформацияОбОшибке().Описание);
			КонецПопытки;
	
			ВремяБлокировки = Формат(ТекущаяДата() + Секунды, "ДФ='yyyy-MM-ddTHH:mm:ss'");
		КонецЕсли;
	Иначе
		ВремяБлокировки = "";
	КонецЕсли;

	СтрокаОкончанияБлокировки = "";
	Если Настройки.ОчищатьВремяОкончанияБлокировки Или Не Блокировать Тогда
		СтрокаОкончанияБлокировки = " --denied-to=""""";
	Иначе
		Если Не ПустаяСтрока(Настройки.ВремяОкончанияБлокировки) Тогда
			СтрокаОкончанияБлокировки = " --denied-to=" + Настройки.ВремяОкончанияБлокировки;
		КонецЕсли;
	КонецЕсли;

	КомандаВыполнения = МенеджерRac.СтрокаЗапускаКлиента() + СтрШаблон("infobase update --infobase=""%3""%4 --cluster=""%1""%2 --sessions-deny=%5 --denied-message=""%6"" --denied-from=""%8""%9 --permission-code=""%7""",
		ИдентификаторКластера,
		МенеджерRac.КлючиАвторизацииВКластере(),
		ИдентификаторБазы,
		КлючиАвторизацииВБазе,
		?(Блокировать, "on", "off"),
		Настройки.СообщениеОблокировке,
		КлючРазрешенияЗапуска,
		ВремяБлокировки,
		СтрокаОкончанияБлокировки) + " " + Настройки.АдресСервераАдминистрирования;

	УспешныйЗапускRac = Ложь;
	ОшибкаЗапускаRac = "";
	Для Сч = 1 По Настройки.ЧислоПопыток Цикл
		Попытка
			ЗапуститьПроцесс(КомандаВыполнения);
			УспешныйЗапускRac = Истина;
			Прервать;
		Исключение
			УспешныйЗапускRac = Ложь;
			ОшибкаЗапускаRac = ИнформацияОбОшибке().Описание;
			Лог.Информация("Попытка запуска rac №" + Сч + " неудачна. Текст ошибки:
			|" + ОшибкаЗапускаRac);			
		КонецПопытки;
	КонецЦикла;
	Если Не УспешныйЗапускRac Тогда
		ВызватьИсключение СтрШаблон("Попытка запуска rac не удалась. Текст ошибки:
			|%1", ОшибкаЗапускаRac);
	КонецЕсли;

	Лог.Информация("Сеансы " + ?(Блокировать, "запрещены", "разрешены"));

КонецПроцедуры

Процедура УстановитьСтатусБлокировкиРЗ(Знач Блокировать)

	КлючиАвторизацииВБазе = МенеджерRAC.КлючиАвторизацииВБазе();

	ОписаниеКластера = МенеджерRac.ОписаниеКластера();
	ИдентификаторКластера = МенеджерRac.ИдентификаторКластера(ОписаниеКластера);
	ИдентификаторБазы = МенеджерRAC.ИдентификаторБазы();

	КомандаВыполнения = МенеджерRac.СтрокаЗапускаКлиента() +
		СтрШаблон("infobase update --infobase=""%3""%4 --cluster=""%1""%2 --scheduled-jobs-deny=%5",
			ИдентификаторКластера,
			МенеджерRac.КлючиАвторизацииВКластере(),
			ИдентификаторБазы,
			КлючиАвторизацииВБазе,
			?(Блокировать, "on", "off")
		) + " " + Настройки.АдресСервераАдминистрирования;

	ЗапуститьПроцесс(КомандаВыполнения);

	Лог.Информация("Регламентные задания " + ?(Блокировать, "запрещены", "разрешены"));

КонецПроцедуры

Функция ПолучитьИнформациюОБазеДанных()

	КлючиАвторизацииВБазе = МенеджерRAC.КлючиАвторизацииВБазе();

	ОписаниеКластера = МенеджерRac.ОписаниеКластера();
	ИдентификаторКластера = МенеджерRac.ИдентификаторКластера(ОписаниеКластера);
	ИдентификаторБазы = МенеджерRAC.ИдентификаторБазы();

	КомандаВыполнения = МенеджерRac.СтрокаЗапускаКлиента() +
		СтрШаблон("infobase info --infobase=""%3""%4 --cluster=""%1""%2",
			ИдентификаторКластера,
			МенеджерRac.КлючиАвторизацииВКластере(),
			ИдентификаторБазы,
			КлючиАвторизацииВБазе
		) + " " + Настройки.АдресСервераАдминистрирования;

	Результат = ЗапуститьПроцесс(КомандаВыполнения);

	Возврат Результат;

КонецФункции

Функция ЗапуститьПроцесс(Знач СтрокаВыполнения)

	Возврат ОбщиеМетоды.ЗапуститьПроцесс(СтрокаВыполнения);

КонецФункции

Процедура ОтключитьСуществующиеСеансы()

	Лог.Информация("Отключаю существующие сеансы");

	СеансыБазы = ПолучитьСписокСеансов();
	Для Каждого Сеанс Из СеансыБазы Цикл
		// Попытка
			ОтключитьСеанс(Сеанс);
		// Исключение
		// 	Лог.Ошибка(ОписаниеОшибки());
		// КонецПопытки;
	КонецЦикла;

КонецПроцедуры

Функция ПолучитьСписокСеансов()

	ТаблицаСеансов = Новый ТаблицаЗначений;
	ТаблицаСеансов.Колонки.Добавить("Идентификатор");
	ТаблицаСеансов.Колонки.Добавить("Приложение");
	ТаблицаСеансов.Колонки.Добавить("Пользователь");
	ТаблицаСеансов.Колонки.Добавить("НомерСеанса");

	ОписаниеКластера = МенеджерRac.ОписаниеКластера();
	КомандаЗапуска = МенеджерRac.СтрокаЗапускаКлиента() + СтрШаблон("session list --cluster=""%1""%2 --infobase=""%3""",
		МенеджерRac.ИдентификаторКластера(ОписаниеКластера),
		МенеджерRac.КлючиАвторизацииВКластере(),
		МенеджерRAC.ИдентификаторБазы()) + " " + Настройки.АдресСервераАдминистрирования;

	Соединения = МенеджерRAC.РазобратьПоток(ЗапуститьПроцесс(КомандаЗапуска));

	Для Каждого ТекПроцесс Из Соединения Цикл

		Если Не МенеджерФильтраПриложений.СеансПодходит(ТекПроцесс["app-id"], ТекПроцесс["user-name"]) Тогда
			Продолжить;
		КонецЕсли;

		ТекСтрока = ТаблицаСеансов.Добавить();
		ТекСтрока.Идентификатор = ТекПроцесс["session"];
		ТекСтрока.Пользователь  = ТекПроцесс["user-name"];
		ТекСтрока.Приложение    = ТекПроцесс["app-id"];
		ТекСтрока.НомерСеанса   = ТекПроцесс["session-id"];

	КонецЦикла;

	Возврат ТаблицаСеансов;

КонецФункции

Процедура ОтключитьСеанс(Знач Сеанс)

	ОписаниеКластера = МенеджерRac.ОписаниеКластера();
	СтрокаВыполнения = МенеджерRac.СтрокаЗапускаКлиента() + СтрШаблон("session terminate --cluster=""%1""%2 --session=""%3""",
		МенеджерRac.ИдентификаторКластера(ОписаниеКластера),
		МенеджерRac.КлючиАвторизацииВКластере(),
		Сеанс.Идентификатор) + " " + Настройки.АдресСервераАдминистрирования;

	Лог.Информация("Отключаю сеанс: %1 [%2] (%3)", Сеанс.НомерСеанса, Сеанс.Пользователь, Сеанс.Приложение);

	Попытка
		ЗапуститьПроцесс(СтрокаВыполнения);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		ТекстОшибкиВРег = ВРег(ТекстОшибки);
		Если СтрНайти(ТекстОшибкиВРег, "СЕАНС ОТСУТСТВУЕТ ИЛИ УДАЛЕН") = 0
		   И СтрНайти(ТекстОшибкиВРег, "СЕАНС С УКАЗАННЫМ ИДЕНТИФИКАТОРОМ НЕ НАЙДЕН") = 0 Тогда
			ВызватьИсключение;
		КонецЕсли;
		Лог.Отладка("Пропускаю ошибку: " + ТекстОшибки);
	КонецПопытки;

КонецПроцедуры

Процедура ОтключитьСоединенияСРабочимиПроцессами()

	Процессы = ПолучитьСписокРабочихПроцессов();

	Для Каждого РабочийПроцесс Из Процессы Цикл
		Если РабочийПроцесс["running"] = "yes" Тогда

			СписокСоединений = ПолучитьСоединенияРабочегоПроцесса(РабочийПроцесс);
			Для Каждого Соединение Из СписокСоединений Цикл

				// Попытка
					РазорватьСоединениеСПроцессом(РабочийПроцесс, Соединение);
				// Исключение
				// 	Лог.Ошибка(ОписаниеОшибки());
				// КонецПопытки;

			КонецЦикла;

		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Функция ПолучитьСписокРабочихПроцессов()

	ОписаниеКластера = МенеджерRac.ОписаниеКластера();
	КомандаЗапускаПроцессы = МенеджерRac.СтрокаЗапускаКлиента() + СтрШаблон("process list --cluster=""%1""%2",
		МенеджерRac.ИдентификаторКластера(ОписаниеКластера),
		МенеджерRac.КлючиАвторизацииВКластере()) + " " + Настройки.АдресСервераАдминистрирования;

	Лог.Информация("Получаю список рабочих процессов...");
	СписокПроцессов = ЗапуститьПроцесс(КомандаЗапускаПроцессы);

	Результат = МенеджерRAC.РазобратьПоток(СписокПроцессов);

	Возврат Результат;

КонецФункции

Функция ПолучитьСоединенияРабочегоПроцесса(Знач РабочийПроцесс)

	ОписаниеКластера = МенеджерRac.ОписаниеКластера();
	КомандаЗапускаСоединения = МенеджерRac.СтрокаЗапускаКлиента() + СтрШаблон("connection list --cluster=""%1""%2 --infobase=%3%4 --process=%5",
				МенеджерRac.ИдентификаторКластера(ОписаниеКластера),
				МенеджерRac.КлючиАвторизацииВКластере(),
				МенеджерRAC.ИдентификаторБазы(),
				МенеджерRAC.КлючиАвторизацииВБазе(),
				РабочийПроцесс["process"]) + " " + Настройки.АдресСервераАдминистрирования;

	Результат = Новый Массив;
	Лог.Информация("Получаю список соединений рабочего процесса...");

	Попытка
		Соединения = МенеджерRAC.РазобратьПоток(ЗапуститьПроцесс(КомандаЗапускаСоединения));
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		Если СтрНайти(ВРег(ТекстОшибки), "РАБОЧИЙ ПРОЦЕСС С УКАЗАННЫМ ИДЕНТИФИКАТОРОМ НЕ НАЙДЕН") = 0 Тогда
			ВызватьИсключение;
		КонецЕсли;
		Лог.Отладка("Пропускаю ошибку: " + ТекстОшибки);

		Соединения = Новый Массив;
	КонецПопытки;

	Для Каждого ТекПроцесс Из Соединения Цикл
		Если ВРег(ТекПроцесс["app-id"]) = "RAS"
			Или Не МенеджерФильтраПриложений.СеансПодходит(ТекПроцесс["app-id"], ТекПроцесс["user-name"]) Тогда
			Продолжить;
		КонецЕсли;

		Результат.Добавить(ТекПроцесс);

	КонецЦикла;

	Возврат Результат;

КонецФункции

Процедура РазорватьСоединениеСПроцессом(Знач РабочийПроцесс, Знач Соединение)

	ОписаниеКластера = МенеджерRac.ОписаниеКластера();
	КомандаРазрывСоединения = МенеджерRac.СтрокаЗапускаКлиента() + СтрШаблон("connection disconnect --cluster=""%1""%2 %3 --process=%4 --connection=%5",
		МенеджерRac.ИдентификаторКластера(ОписаниеКластера),
		МенеджерRac.КлючиАвторизацииВКластере(),
		МенеджерRAC.КлючиАвторизацииВБазе(),
		РабочийПроцесс["process"],
		Соединение["connection"]) + " " + Настройки.АдресСервераАдминистрирования;

	Сообщение = СтрШаблон("Отключаю соединение %1 [%2] (%3)",
		Соединение["conn-id"],
		Соединение["app-id"],
		Соединение["user-name"]
	);

	Лог.Информация(Сообщение);

	Попытка
		ЗапуститьПроцесс(КомандаРазрывСоединения);
	Исключение
		ТекстОшибки = ВРег(ОписаниеОшибки());
		Если СтрНайти(ТекстОшибки, "СОЕДИНЕНИЕ") = 0 И СтрНайти(ТекстОшибки, "НЕ НАЙДЕНО") = 0 Тогда
			ВызватьИсключение;
		КонецЕсли;
		Лог.Отладка("Пропускаю ошибку: " + ТекстОшибки);
	КонецПопытки;

КонецПроцедуры
