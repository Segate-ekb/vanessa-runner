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

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания =
		"     Загрузка расширения в конфигурацию из папки исходников.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, ТекстОписания);

	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "inputPath", "Путь к исходникам расширения");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "extensionName",
		"Имя расширения, под которым оно будет зарегистрировано в списке расширений");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--updatedb", "Признак обновления расширения");
	ОбщиеМетоды.ДобавитьБлокIbcmd(Парсер, ОписаниеКоманды);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
//
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Структура - дополнительные параметры (необязательно)
//
//  Возвращаемое значение:
//   Число - Код возврата команды.
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ОбщиеМетоды.ЛогКоманды(ДополнительныеПараметры);

	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];

	КаталогИсходников = ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["inputPath"]);
	ИмяРасширения = ПараметрыКоманды["extensionName"];
	ОбновлятьИБ = ПараметрыКоманды["--updatedb"];

	МенеджерСборки = ОбщиеМетоды.ФабрикаМенеджераСборки(ПараметрыКоманды);
	МенеджерСборки.Конструктор(ДанныеПодключения, ПараметрыКоманды);
	
	Лог.Информация("Собираем расширение %1 из исходников...", ИмяРасширения);
	Попытка
		МенеджерСборки.СобратьИзИсходниковРасширение(КаталогИсходников,	ИмяРасширения, ОбновлятьИБ);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		МенеджерСборки.Деструктор();
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
	КонецПопытки;
	Лог.Информация("Сборка расширения из исходников завершена.");

	МенеджерСборки.Деструктор();

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции // ВыполнитьКоманду

#КонецОбласти
