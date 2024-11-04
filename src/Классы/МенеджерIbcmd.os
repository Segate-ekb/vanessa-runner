
#Использовать ibcmdrunner
#Использовать v8find

#Область ОписаниеПеременных

Перем Лог; // Содердит объект ллога
Перем ВременныйКаталогДанныхСервера; // Временный каталог данных автономного сервера
Перем КаталогВременнойИБ;
Перем УправлениеИБ; // :УправлениеИБ
Перем Локаль; // Локаль приложения

#КонецОбласти

#Область ПрограммныйИнтерфейс

Процедура УстановитьКонтекст(Знач СтрокаСоединения, Знач Пользователь, Знач Пароль) Экспорт

	КаталогБазы = ОбщиеМетоды.КаталогФайловойИБ(СтрокаСоединения);
	Лог.Отладка("Использовать каталог ИБ %1", КаталогБазы);
	УправлениеИБ.УстановитьПараметрыФайловойИБ(КаталогБазы);
	УправлениеИБ.УстановитьПараметрыАвторизацииИБ(Пользователь, Пароль);

КонецПроцедуры

Процедура СоздатьФайловуюБазу(Знач КаталогБазы, Знач ПутьКШаблону = "", Знач ИмяБазыВСписке = "") Экспорт

	ОбщиеМетоды.ОбеспечитьПустойКаталог(Новый Файл(КаталогБазы));

	УправлениеИБ.УстановитьПараметрыФайловойИБ(КаталогБазы);
	УправлениеИБ.СоздатьИБИзФайлаВыгрузки(ПутьКШаблону, ЛокальДляЗапуска());

	СтрокаСоединения = СтрШаблон("File=""%1""", КаталогБазы);
	ДобавитьБазуВСписокБаз(ИмяБазыВСписке, СтрокаСоединения);

КонецПроцедуры

Процедура СобратьИзИсходниковТекущуюКонфигурацию(Знач ВходнойКаталог,
	Знач СписокФайловДляЗагрузки = "", СниматьСПоддержки = Ложь, ОбновитьФайлВерсий = Истина) Экспорт

	ИмяРасширения = "";

	Если ТипЗнч(СписокФайловДляЗагрузки) = Тип("Строка") Тогда
		Если СписокФайловДляЗагрузки <> "" Тогда
			СписокФайловДляЗагрузки = СтрРазделить(СписокФайловДляЗагрузки, ";");
		КонецЕсли;
	КонецЕсли;

	Если СниматьСПоддержки Тогда
		УправлениеИБ.СнятьСПоддержки();
	КонецЕсли;

	Если ЗначениеЗаполнено(СписокФайловДляЗагрузки) Тогда
		УправлениеИБ.ЗагрузитьВыбранныеФайлыКонфигурации(ВходнойКаталог, СписокФайловДляЗагрузки, ИмяРасширения);
	Иначе
		УправлениеИБ.ЗагрузитьКонфигурациюИзФайлов(ВходнойКаталог, ИмяРасширения);
	КонецЕсли;

	Если ОбновитьФайлВерсий Тогда
		УправлениеИБ.ВыгрузитьВФайлСостояниеКонфигурации(ВходнойКаталог, ИмяРасширения);
	КонецЕсли;

КонецПроцедуры

// Выгружает информационную базу в файл
//
// Параметры:
//  ПутьКВыгружаемомуФайлуСДанными - Строка - Путь к результату - выгружаемому файлу с данными (*.dt)
//
Процедура ВыгрузитьИнфобазуВФайл(Знач ПутьКВыгружаемомуФайлуСДанными) Экспорт
	УправлениеИБ.ВыгрузитьДанныеИБ(ПутьКВыгружаемомуФайлуСДанными);
КонецПроцедуры

// Загружает информационную базу из файла
//
// Параметры:
//  ПутьКЗагружаемомуФайлуСДанными - Строка - Путь к файлу с данными (*.dt)
//  КоличествоЗаданий - Число - Количество заданий (потоков) загрузки из файла с данными
//
Процедура ЗагрузитьИнфобазуИзФайла(Знач ПутьКЗагружаемомуФайлуСДанными, Знач КоличествоЗаданий = 0) Экспорт
	УправлениеИБ.ЗагрузитьДанныеИБ(ПутьКЗагружаемомуФайлуСДанными);
КонецПроцедуры

Процедура ЗагрузитьФайлКонфигурации(Знач ПутьКФайлу, Знач СниматьСПоддержки = Истина) Экспорт

	ИмяРасширения = "";

	Если СниматьСПоддержки Тогда
		УправлениеИБ.СнятьСПоддержки();
   	КонецЕсли;

	УправлениеИБ.ЗагрузитьКонфигурацию(ПутьКФайлу, ИмяРасширения);

КонецПроцедуры

Процедура ОбновитьКонфигурациюБазыДанных(ДинамическоеОбновление = Ложь) Экспорт

	Если ДинамическоеОбновление Тогда
		РежимДинамическогоОбновления = "disable";
	Иначе
		РежимДинамическогоОбновления = "auto";
	КонецЕсли;
	ЗавершатьСеансы = "force";

	ИмяРасширения = "";
	УправлениеИБ.ОбновитьКонфигурациюБазыДанных(ИмяРасширения, РежимДинамическогоОбновления, ЗавершатьСеансы);

	Лог.Информация("Обновление конфигурации БД завершено.");

КонецПроцедуры

// ОбновитьРасширение
//
// Параметры:
//   ИмяРасширения - Строка - <описание параметра>
//
Процедура ОбновитьРасширение(Знач ИмяРасширения) Экспорт

	РежимДинамическогоОбновления = "disable";
	ЗавершатьСеансы = "force";

	УправлениеИБ.ОбновитьКонфигурациюБазыДанных(ИмяРасширения, РежимДинамическогоОбновления, ЗавершатьСеансы);
КонецПроцедуры

Процедура ПоказатьСписокВсехРасширенийКонфигурации() Экспорт
	СписокРасширений = УправлениеИБ.СписокРасширений();
	Лог.Информация("Список расширений конфигурации:%2%1", СписокРасширений, Символы.ПС);
КонецПроцедуры

Процедура ВыгрузитьКонфигурациюВФайл(Знач ПутьКНужномуФайлуКонфигурации) Экспорт

	УправлениеИБ.ВыгрузитьКонфигурациюВФайл(ПутьКНужномуФайлуКонфигурации);

КонецПроцедуры

// Разбор текущей конфигураций на исходники штатной выгрузкой 1С
//
// Параметры:
//   КаталогВыгрузки - Строка - Путь к каталогу выгрузки
//   ФайлВерсии - Строка - Путь к файлу версии
//   ТолькоИзмененные - Булево - Выгружать только измененные файлы для ускорения выгрузки
//   ИспользоватьПереименования - Булево - Переименовывать файлы в удобные имена и раскладывать по папкам согласно иерархии метаданных
//
Процедура РазобратьНаИсходникиТекущуюКонфигурацию(КаталогВыгрузки, Знач ФайлВерсии = "",
	Знач ТолькоИзмененные = Истина,
	Знач ИспользоватьПереименования = Ложь) Экспорт

	НеВыгружатьНеСуществующиеОбъекты = Истина;
	ИмяРасширения = "";
	ВАрхив = Ложь;
	НаСервере = Ложь;
	КоличествоПотоков = 0;

	ФС.ОбеспечитьКаталог(КаталогВыгрузки);
	Синхронизировать = ТолькоИзмененные И ФС.ФайлСуществует(ФайлВерсии);

	УправлениеИБ.ВыгрузитьКонфигурациюВФайлы(КаталогВыгрузки, ФайлВерсии, ИмяРасширения,
		Синхронизировать, ВАрхив, НаСервере, КоличествоПотоков, НеВыгружатьНеСуществующиеОбъекты);

КонецПроцедуры

// Выгружает расширение в исходники
//
// Параметры:
//   КаталогВыгрузки - Строка - Путь к каталогу выгрузки
//   ИмяРасширения - Строка - Имя расширения
//   ФайлВерсии - Строка - Путь к файлу версии
//   ТолькоИзмененные - Булево - Выгружать только измененные файлы для ускорения выгрузки
//
Процедура РазобратьРасширениеНаИсходники(КаталогВыгрузки, ИмяРасширения,
	Знач ФайлВерсии = "", Знач ТолькоИзмененные = Истина) Экспорт

	НеВыгружатьНеСуществующиеОбъекты = Истина;
	ВАрхив = Ложь;
	НаСервере = Ложь;
	КоличествоПотоков = 0;

	ФС.ОбеспечитьКаталог(КаталогВыгрузки);
	Синхронизировать = ТолькоИзмененные И ФС.ФайлСуществует(ФайлВерсии);

	УправлениеИБ.ВыгрузитьКонфигурациюВФайлы(КаталогВыгрузки, ФайлВерсии, ИмяРасширения,
		Синхронизировать, ВАрхив, НаСервере, КоличествоПотоков, НеВыгружатьНеСуществующиеОбъекты);

КонецПроцедуры

// Выгружает файл конфигурации в исходники
//
// Параметры:
//  ФайлКонфигурации - Строка - Путь к источнику - выгружаемому файлу конфигурации (*.cf)
//  ВыходнойКаталог - Строка - Путь к каталогу выгрузки
//  ФайлВерсии - Строка - Путь к файлу версии
//  ИспользоватьПереименования - Булево - Переименовывать файлы в удобные имена и раскладывать по папкам согласно иерархии метаданных
//
Процедура ВыгрузитьКонфигурациюВИсходники(Знач ФайлКонфигурации, Знач ВыходнойКаталог,
	Знач ФайлВерсии = "", Знач ИспользоватьПереименования = Ложь) Экспорт

	ЗагрузитьФайлКонфигурации(ФайлКонфигурации);
	РазобратьНаИсходникиТекущуюКонфигурацию(ВыходнойКаталог, ФайлВерсии, Истина, ИспользоватьПереименования);

КонецПроцедуры

Процедура СобратьИзИсходниковРасширение(Каталог, ИмяРасширения, Обновить = Ложь) Экспорт

	УправлениеИБ.ЗагрузитьКонфигурациюИзФайлов(Каталог, ИмяРасширения);

	Если Обновить Тогда
		УправлениеИБ.ОбновитьКонфигурациюБазыДанных(ИмяРасширения);
	КонецЕсли;

КонецПроцедуры

// Выгружает файл расширения из ИБ
//
// Параметры:
//  ПутьКНужномуФайлуРасширения - Строка - Путь к результату - выгружаемому файлу конфигурации (*.cfe)
//  ИмяРасширения - Строка - Имя расширения
//
Процедура ВыгрузитьРасширениеВФайл(Знач ПутьКНужномуФайлуРасширения, Знач ИмяРасширения) Экспорт
	УправлениеИБ.ВыгрузитьКонфигурациюВФайл(ПутьКНужномуФайлуРасширения, ИмяРасширения);
КонецПроцедуры

// Загружает файл расширения в текущую базу данных.
//	Параметры:
//		ПутьКФайлу - Строка - Путь к файлу *.cfe
//		ИмяРасширения - Строка
//		ОбновитьКонфигурациюИБ - Булево
//
Процедура ЗагрузитьФайлРасширения(Знач ПутьКФайлу, Знач ИмяРасширения, Знач ОбновитьКонфигурациюИБ = Ложь) Экспорт

	УправлениеИБ.ЗагрузитьКонфигурацию(ПутьКФайлу, ИмяРасширения);

	Если ОбновитьКонфигурациюИБ Тогда
		УправлениеИБ.ОбновитьКонфигурациюБазыДанных(ИмяРасширения);
   КонецЕсли;

КонецПроцедуры

// Возвращает каталог времнной ИБ
//
//  Возвращаемое значение:
//   Строка - Каталог временной ИБ
//
Функция КаталогВременнойИБ() Экспорт
	Возврат КаталогВременнойИБ;
КонецФункции

// Возвращает строку, содержащую все изменения конфигурации с момента последней загрузки.
//	Параметры:
//		КаталогВыгрузки - Строка - каталог с исходными файлами конфигурации
//		ПутьКФайлуВерсийДляСравнения - Строка - путь к файлу configDumpInfo на основании которого считаются изменения
//
// Возвращаемое значение:
// 	Строка - Список файлов которые изменились с последней загрузки конфигурации, разделенные ";". 
//				Если необходима полная загрузка будет возвращена строка "FullDump"
Функция ПолучитьИзмененияКонфигурации(Знач КаталогВыгрузки,
										Знач ПутьКФайлуВерсийДляСравнения = "") Экспорт

	ИзмененияКонфигурации = "";

	ПутьКФайлуИзменений = ОбъединитьПути(КаталогВыгрузки, "diff.txt");
	УправлениеИБ.ВыгрузитьВФайлИзмененияКонфигурации(ПутьКФайлуИзменений, ПутьКФайлуВерсийДляСравнения);

	Если ФС.ФайлСуществует(ПутьКФайлуИзменений) Тогда
		ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлуИзменений, КодировкаТекста.UTF8NoBOM);
			
			СтрокаИзменения = ЧтениеТекста.ПрочитатьСтроку();
			Пока СтрокаИзменения <> Неопределено Цикл // строки читаются до символа перевода строки
				Если СтрокаИзменения = "modified: all" Тогда
					ИзмененияКонфигурации = "FullDump";
					Прервать;				
				КонецЕсли;
				Если СтрНачинаетсяС(СтрокаИзменения, "modified:") Тогда
				// Все остальные нам не нужны, нужны только измененные объекты которые нужно перезагрузить в конфигурацию.
					ИмяФайла = НайтиИмяФайлаПоСтроке(СтрокаИзменения);
					ИзмененияКонфигурации = ИзмененияКонфигурации + ИмяФайла + ";";
				КонецЕсли;
				СтрокаИзменения = ЧтениеТекста.ПрочитатьСтроку();
			КонецЦикла;
			ЧтениеТекста.Закрыть();

			УдалитьФайлы(ПутьКФайлуИзменений);	
	КонецЕсли;

	Возврат ИзмененияКонфигурации;
КонецФункции		
#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	ВременныйКаталогДанныхСервера = ВременныеФайлы.СоздатьКаталог();
	Локаль = "";

	УправлениеИБ = Новый УправлениеИБ;
	УправлениеИБ.УстановитьПараметрыАвтономногоСервера(ВременныйКаталогДанныхСервера);

КонецПроцедуры

Процедура Конструктор(Знач ДанныеПодключения, Знач ПараметрыКоманды) Экспорт

	ВерсияПлатформы = ДанныеПодключения.ВерсияПлатформы;
	Если ЗначениеЗаполнено(ВерсияПлатформы) Тогда
		Если ЗначениеЗаполнено(ДанныеПодключения.РазрядностьПлатформы) Тогда
			Разрядность = ОбщиеМетоды.РазрядностьПлатформы(ДанныеПодключения.РазрядностьПлатформы);
			Лог.Отладка("Разрядность платформы 1С указана %1", ДанныеПодключения.РазрядностьПлатформы);
		Иначе
			Разрядность = ОбщиеМетоды.РазрядностьПлатформы("x64x86");
			Лог.Отладка("Разрядность платформы 1С не указана");
		КонецЕсли;

		ПутьКIbcmd = ПутьКIbcmd(ВерсияПлатформы, Разрядность);
		УправлениеИБ.ПутьКПриложению(ПутьКIbcmd);
	КонецЕсли;
	Лог.Информация("Используется ibcmd платформы %1", ТекущаяВерсияПлатформы());

	ИспользоватьВременнуюБазу = ДанныеПодключения.ИспользоватьВременнуюБазу;
	Если ИспользоватьВременнуюБазу Тогда
		Лог.Отладка("ИспользоватьВременнуюБазу %1", ИспользоватьВременнуюБазу);

		КаталогВременнойИБ = ОбъединитьПути(ВременныйКаталогДанныхСервера, "db_data");

		СтрокаСоединения = СтрШаблон("/F%1", КаталогВременнойИБ);
		Пользователь = "";
		Пароль = "";

		УстановитьКонтекст(СтрокаСоединения, Пользователь, Пароль);

	Иначе
		УстановитьКонтекст(ДанныеПодключения.ПутьБазы,
			ДанныеПодключения.Пользователь, ДанныеПодключения.Пароль);
	КонецЕсли;

КонецПроцедуры

Процедура Деструктор() Экспорт

	Попытка
		ВременныеФайлы.УдалитьФайл(ВременныйКаталогДанныхСервера);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Лог.Отладка(КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;

	ВременныйКаталогДанныхСервера = "";

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
Функция НайтиИмяФайлаПоСтроке(СтрокаИзменения)	
	СтрокаИзменения = СтрЗаменить(СтрокаИзменения, "modified: ", "");
	Если СтрНачинаетсяС(СтрокаИзменения, "Configuration") Тогда
		// Если это конфигурация, то возвращаем ФайлКонфигурации
		Возврат "Configuration.xml";
	КонецЕсли;
	МассивЧастей = СтрРазделить(СтрокаИзменения, ".", Ложь);

	КорневойТипМетаданных = МассивЧастей[0] + "s";
	ИмяОбъектаМетаданных = МассивЧастей[1];

	Возврат ОбъединитьПути(КорневойТипМетаданных, ИмяОбъектаМетаданных + ".xml");
КонецФункции

Функция ПутьКIbcmd(ВерсияПлатформы, Разрядность)

	Если Не СтрНачинаетсяС(ВерсияПлатформы, "8.3") Тогда
		ВызватьИсключение "Неверная версия платформы <" + ВерсияПлатформы + ">";
	КонецЕсли;

	Возврат Платформа1С.ПутьКIBCMD(ВерсияПлатформы, Разрядность);

КонецФункции

Функция ЛокальДляЗапуска()

	Если ЗначениеЗаполнено(Локаль) Тогда
		Возврат Локаль;
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции

Процедура ДобавитьБазуВСписокБаз(ИмяБазыВСписке, СтрокаСоединения)

	Если ПустаяСтрока(ИмяБазыВСписке) Тогда
		Возврат;
	КонецЕсли;

	КорневойПутьПроекта = ПараметрыСистемы.КорневойПутьПроекта;

	ДопДанныеСпискаБаз = Новый Структура;
	ДопДанныеСпискаБаз.Вставить("RootPath", КорневойПутьПроекта);
	ДопДанныеСпискаБаз.Вставить("Version", УправлениеИБ.Версия());

	ПолныйПуть = Новый Файл(КорневойПутьПроекта).ИмяБезРасширения;

	Попытка
		МенеджерСпискаБаз.ДобавитьБазуВСписокБаз(СтрокаСоединения, ПолныйПуть, ДопДанныеСпискаБаз);
	Исключение
		Лог.Предупреждение("Добавление базы в список " + ОписаниеОшибки());
	КонецПопытки;

КонецПроцедуры

Функция ТекущаяВерсияПлатформы()
	Возврат СокрЛП(УправлениеИБ.Версия());
КонецФункции

#КонецОбласти
