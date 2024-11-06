#Использовать asserts
#Использовать tempfiles
#Использовать "utils"
#Использовать "../.."

#Область ОписаниеПеременных

Перем НакопленныеВременныеФайлы; // фиксация накопленных времнных файлов для сброса

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

&Тест
Процедура ТестДолжен_РазобратьРасширениеНаИсходникиIbcmd() Экспорт

	// Дано
	ИмяРасширения = "testNew";

	Исполнитель = Новый Тест_ИсполнительКоманд("decompileext");
	Исполнитель.УстановитьКонтекстПустаяИБ();
	КаталогSrc = Исполнитель.ПутьТестовыхДанных("cfe");
	Исполнитель.СоздатьРасширениеИзФайлов(ИмяРасширения, КаталогSrc);
	
	Исполнитель.ДобавитьПараметр(ИмяРасширения);
	Исполнитель.ДобавитьПараметр("src");
	Исполнитель.ДобавитьФлаг("--ibcmd");

	// Когда
	Исполнитель.ВыполнитьКоманду();

	// Тогда
	Исполнитель.ОжидаемЧтоВыводСодержит("Используется ibcmd");
	Исполнитель.ОжидаемЧтоВыводСодержит("Разборка расширения на исходники завершена.");
	Исполнитель.ОжидаемЧтоФайлСуществует("src/Configuration.xml");
	Исполнитель.ОжидаемЧтоФайлСуществует("src/Ext/ManagedApplicationModule.bsl");

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
