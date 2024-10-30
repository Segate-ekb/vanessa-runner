#Использовать asserts
#Использовать tempfiles
#Использовать "utils"
#Использовать "../.."

#Область ОписаниеПеременных

Перем НакопленныеВременныеФайлы; // фиксация накопленных времнных файлов для сброса

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

&Тест
Процедура ТестДолжен_ВыгрузитьРасширениеВФайлIbcmd() Экспорт

	// Дано
	Исполнитель = Новый Тест_ИсполнительКоманд("unloadext");
	Исполнитель.ДобавитьПараметр("testNew.cfe");
	Исполнитель.ДобавитьПараметр("test");
	Исполнитель.УстановитьКонтекстПустаяИБ();
	Исполнитель.СоздатьПустоеРасширение("test", "Ext1_");
	Исполнитель.ДобавитьФлаг("--ibcmd");
	
	// Когда
	Исполнитель.ВыполнитьКоманду();

	// Тогда
	Исполнитель.ОжидаемЧтоВыводСодержит("Используется ibcmd");
	Исполнитель.ОжидаемЧтоВыводСодержит("Выгрузка расширения в cfe завершена.");
	Исполнитель.ОжидаемЧтоФайлСуществует("testNew.cfe");
		
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