///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Выполнение команды/действия в 1С:Предприятие в режиме тонкого/толстого клиента с передачей запускаемых обработок и параметров
//
// TODO добавить фичи для проверки команды
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

Перем Лог; // Экземпляр логгера

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания =
		"     Выгрузка информационной базы в dt-файл.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды,
		ТекстОписания);

	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "dtpath",
		"Путь к результату - выгружаемому файлу с данными (*.dt)");
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
	ФайлВыгрузки = ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["dtpath"]);

	МенеджерСборки = ОбщиеМетоды.ФабрикаМенеджераСборки(ПараметрыКоманды);
	МенеджерСборки.Конструктор(ДанныеПодключения, ПараметрыКоманды);

	Лог.Информация("Запускаем выгрузку информационной базы в dt...");
	Попытка
		МенеджерСборки.ВыгрузитьИнфобазуВФайл(ФайлВыгрузки);
	Исключение
		МенеджерСборки.Деструктор();
		ВызватьИсключение;
	КонецПопытки;
	Лог.Информация("Выгрузка информационной базы в dt завершена.");

	МенеджерСборки.Деструктор();

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции // ВыполнитьКоманду

#КонецОбласти
