///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов <ПроверкаКорректностиОбластей>
//
///////////////////////////////////////////////////////////////////////////////

Перем Лог;

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "ПроверкаКорректностиОбластей";
	
КонецФункции // ИмяСценария()

// ОбработатьФайл
//	Выполняет обработку файла
//
// Параметры:
//  АнализируемыйФайл		- Файл - Файл из журнала git для анализа
//  КаталогИсходныхФайлов  	- Строка - Каталог расположения исходных файлов относительно каталог репозитория
//  ДополнительныеПараметры - Структура - Набор дополнительных параметров, которые можно использовать 
//  	* Лог  					- Объект - Текущий лог
//  	* ИзмененныеКаталоги	- Массив - Каталоги, которые необходимо добавить в индекс
//		* КаталогРепозитория	- Строка - Адрес каталога репозитория
//		* ФайлыДляПостОбработки	- Массив - Файлы, изменившиеся / образовавшиеся в результате работы сценария
//											и которые необходимо дообработать
//
// Возвращаемое значение:
//   Булево   - Признак выполненной обработки файла
//
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт
	
	Лог = ДополнительныеПараметры.Лог;
	НастройкиСценария = ДополнительныеПараметры.УправлениеНастройками.Настройка("Precommt4onecСценарии\НастройкиСценариев").Получить(ИмяСценария());
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлИсходников(АнализируемыйФайл) Тогда
		
		Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
		
		ПроверитьНаКорректностьОбластей(АнализируемыйФайл.ПолноеИмя);
		Возврат Истина;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции // ОбработатьФайл()

Процедура ПроверитьНаКорректностьОбластей(ПутьКФайлуМодуля) 
	
	ТекстМодуля = ФайловыеОперации.ПрочитатьТекстФайла(ПутьКФайлуМодуля);

	ТекстОшибки = "";
	ШаблонПоиска = Новый РегулярноеВыражение("^[\t ]*?#[\t ]*?(?:(?:Область[\t ]+?([a-zA-Zа-яА-Я0-9_]+?))|(?:КонецОбласти))[\t ]*?(?:\/\/.*)*$");
	ШаблонПоиска.Многострочный = Истина;
	ШаблонПоиска.ИгнорироватьРегистр = Истина;
	
	Если НЕ ПустаяСтрока(ТекстМодуля) Тогда
		
		Совпадения = ШаблонПоиска.НайтиСовпадения(ТекстМодуля);
		Если Совпадения.Количество() % 2 <> 0 Тогда // простое сравнение
			
			ТекстОшибки = СтрШаблон("В файле '%1' нарушена парность скобок областей: %2 шт", ПутьКФайлуМодуля, Совпадения.Количество());
			Лог.Ошибка(ТекстОшибки);
			
			ВызватьИсключение ТекстОшибки;
			
		Иначе
			
			Открыта = 0;
			Для Каждого Совпадение Из Совпадения Цикл
				
				Если ЗначениеЗаполнено(Совпадение.Группы[1].Значение) Тогда // имя области
					
					Открыта = Открыта + 1;
					
				Иначе
					
					Открыта = Открыта - 1;
					
				КонецЕсли;
				
				Если Открыта < 0 Тогда
					
					ТекстОшибки = СтрШаблон("В файле '%1' нарушена последовательность скобок областей", ПутьКФайлуМодуля);
					Лог.Ошибка(ТекстОшибки);
					
					ВызватьИсключение ТекстОшибки;
					
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры
