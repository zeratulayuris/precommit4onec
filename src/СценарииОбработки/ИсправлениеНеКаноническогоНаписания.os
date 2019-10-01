///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов 
//	<ИсправлениеНеКаноническогоНаписания>
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
	
	Возврат "ИсправлениеНеКаноническогоНаписания";
	
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
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлИсходников(АнализируемыйФайл) Тогда
		
		Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
		
		Если ИсправитьНаКаноническоеНаписание(АнализируемыйФайл.ПолноеИмя) Тогда
			
			ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);
			
		КонецЕсли;
		
		Возврат Истина;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции // ОбработатьФайл()

Функция ИсправитьНаКаноническоеНаписание(Знач ИмяФайла)
	
	СодержимоеФайла = ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);
	
	Если Не ЗначениеЗаполнено(СодержимоеФайла) Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Эталоны = Эталоны();
	КлючевыеСлова = КлючевыеСлова(Эталоны);
	
	РазбираемоеСодержимоеФайла = СтрЗаменить(СодержимоеФайла, """""", "***ЗАМЕНА_ДВОЙНЫХ_КАВЫЧЕК***");
	РазбираемоеСодержимоеФайла = СтрЗаменить(РазбираемоеСодержимоеФайла, "://", "***ЗАМЕНА_ЧАСТИ_URL***"); // например, URLСтрока = "http://my.domain.com"
	НовоеСодержимоеФайла = Новый ТекстовыйДокумент;
	
	ТекстРазбора = Новый ТекстовыйДокумент;
	ТекстРазбора.УстановитьТекст(РазбираемоеСодержимоеФайла);
	ВсегоСтрок = ТекстРазбора.КоличествоСтрок();
	СтрокаОткрыта = Ложь;
	
	// символы, которые будут использоваться для нормализации строки
	ЗаменяемыеСимволы = "; = ( ) , " + Символы.Таб;
	ЗаменяемыеСимволы = СтрРазделить(ЗаменяемыеСимволы, " ", Истина);
	// Построчная проверка
	Для Ит = 1 По ВсегоСтрок Цикл
		
		СтрокаМодуля = ТекстРазбора.ПолучитьСтроку(Ит);
		
		// оставим строки, которые обрабатывать не нужно
		Если ПустаяСтрока(СтрокаМодуля)
			ИЛИ СтрНачинаетсяС(СокрЛ(СтрокаМодуля), "//") Тогда
			
			ДобавитьСтрокуСодержимого(НовоеСодержимоеФайла, СтрокаМодуля);
			
			Продолжить;
		КонецЕсли;
		
		НоваяСтрокаМодуля = СтрокаМодуля;
		Если НЕ СтрокаОткрыта Тогда
			
			НоваяСтрокаМодуля = УдалитьКомИКавИзСтроки(НоваяСтрокаМодуля);
			
		КонецЕсли;
		
		// Вырезаем часть строки в кавычках
		ПоследняяПозиция = 0;
		ПозицияКавычек = СтрНайти(НоваяСтрокаМодуля, """");
		
		НоваяСтрокаМодуля = ВырезатьТекстВКавычках(НоваяСтрокаМодуля, ПозицияКавычек, ПоследняяПозиция, СтрокаОткрыта);
		
		// ничего интересного не осталось
		Если СтрокаОткрыта И ПозицияКавычек = 0
			ИЛИ ПустаяСтрока(НоваяСтрокаМодуля) Тогда
			
			ДобавитьСтрокуСодержимого(НовоеСодержимоеФайла, СтрокаМодуля);
			Продолжить;
			
		КонецЕсли;
		
		// Проверяем правильное использование каждого ключевого слова
		ВРегНоваяСтрокаМодуля = НормализоватьСтроку(НоваяСтрокаМодуля, ЗаменяемыеСимволы);
		
		ДлинаСтроки = СтрДлина(ВРегНоваяСтрокаМодуля);
		
		Для Каждого ЭлементТаблицы Из КлючевыеСлова Цикл
			Эталон = ЭлементТаблицы.Наименование;
			ПозицияЭталона = СтрНайти(ВРегНоваяСтрокаМодуля, " " + Эталон + " ");
			Если НЕ ПозицияЭталона Тогда
				Продолжить;
			КонецЕсли;
			
			ДлинаЭталона = СтрДлина(Эталон);
			
			// Нашли ключевое слово, проверяем каноническое написание
			Пока ПозицияЭталона > 0 Цикл
				
				СтартоваяПозиция = ПозицияЭталона - 1;
				Написание = СокрЛП(Сред(СтрокаМодуля, ПозицияЭталона, ДлинаЭталона));
				
				Если Эталоны.Найти(Написание) = Неопределено Тогда // Ключевое слово написано не канонически
					
					СтрокаМодуля = Лев(СтрокаМодуля, СтартоваяПозиция)
						+ ЭлементТаблицы.Значение
						+ Сред(СтрокаМодуля, СтартоваяПозиция + ДлинаЭталона + 1);
					
					СтрокаСообщения = СтрШаблон("В строке %1 найдено ключевое слово '%2' заменено на '%3'",
							Ит, Написание, ЭлементТаблицы.Значение);
					Лог.Информация(СтрокаСообщения);
				КонецЕсли;
				
				ПозицияЭталона = СтрНайти(ВРегНоваяСтрокаМодуля, " " + Эталон + " ", , ПозицияЭталона + ДлинаЭталона);
				
			КонецЦикла;
			
		КонецЦикла;
		
		ДобавитьСтрокуСодержимого(НовоеСодержимоеФайла, СтрокаМодуля);
		
	КонецЦикла;
	
	Если НовоеСодержимоеФайла.ПолучитьТекст() <> СодержимоеФайла Тогда
		
		ФайловыеОперации.ЗаписатьТекстФайла(ИмяФайла, НовоеСодержимоеФайла.ПолучитьТекст());
		Возврат Истина; // переиндексируем
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции


Функция НормализоватьСтроку(Знач Строка, ЗаменяемыеСимволы)
	
	Строка = " " + ВРег(Строка) + " ";

	Для Каждого Символ Из ЗаменяемыеСимволы Цикл
		
		Строка = СтрЗаменить(Строка, Символ, " ");
		
	КонецЦикла;
	
	Возврат Строка;
	
КонецФункции

Процедура ДобавитьСтрокуСодержимого(НовоеСодержимоеФайла, Знач СтрокаМодуля)
	
	СтрокаМодуля = СтрЗаменить(СтрокаМодуля, "***ЗАМЕНА_ДВОЙНЫХ_КАВЫЧЕК***", """""");
	СтрокаМодуля = СтрЗаменить(СтрокаМодуля, "***ЗАМЕНА_ЧАСТИ_URL***", "://");
	
	НовоеСодержимоеФайла.ДобавитьСтроку(СтрокаМодуля);
	
КонецПроцедуры

Функция ВырезатьТекстВКавычках(Знач СтрокаМодуля, ПозицияКавычек, ПоследняяПозиция, СтрокаОткрыта)
	
	Пока ПозицияКавычек > 0 Цикл
		
		Если СтрокаОткрыта Тогда
			
			// кавычки закрывают строку, вырезаем часть в кавычках
			СтрокаМодуляВКавычках = Сред(СтрокаМодуля, ПозицияКавычек + 1);
			СтрокаМодуля = Лев(СтрокаМодуля, ПоследняяПозиция - 1)
				+ ДополнитьСтроку("", ПозицияКавычек - ПоследняяПозиция + 1, " ")
				+ СтрокаМодуляВКавычках;
			СтрокаОткрыта = Ложь;
			ПоследняяПозиция = 0;
			
		Иначе
			
			// позиция кавычек начинают строку
			ПоследняяПозиция = ПозицияКавычек;
			СтрокаОткрыта = Истина;
			СтрокаМодуля = Лев(СтрокаМодуля, ПозицияКавычек - 1) + " " + Сред(СтрокаМодуля, ПозицияКавычек + 1);
			
		КонецЕсли;
		
		ПозицияКавычек = Найти(СтрокаМодуля, """");
		
	КонецЦикла;
	
	Возврат СтрокаМодуля;
	
КонецФункции

Функция УдалитьКомИКавИзСтроки(Знач СтрокаМодуля)
	
	ПозицияКомментария = СтрНайти(СтрокаМодуля, "//");
	
	Если ПозицияКомментария > 0 Тогда // есть комментарий
		ДлинаСтроки = СтрДлина(СтрокаМодуля);
		ПозицияКавычек = СтрНайти(СтрокаМодуля, """");
		Если ПозицияКавычек = 0 // нет кавычек, удаляем комментарий
			ИЛИ ПозицияКавычек > ПозицияКомментария Тогда // кавычки после комментария, удаляем комментарий 
			
			СтрокаМодуля = ДополнитьСтроку(Лев(СтрокаМодуля, ПозицияКомментария - 1), ДлинаСтроки, " ", "Справа");
			
		Иначе
			
			КоличествоКавычекДоКомментария = СтрЧислоВхождений(Лев(СтрокаМодуля, ПозицияКомментария), """");
			Если КоличествоКавычекДоКомментария % 2 = 0 Тогда // строка открывается и закрывается до комментария, удаляем комментарий
				
				СтрокаМодуля = ДополнитьСтроку(Лев(СтрокаМодуля, ПозицияКомментария - 1), ДлинаСтроки, " ", "Справа");
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат СтрокаМодуля;
	
КонецФункции

Функция КлючевыеСлова(Эталоны)
	
	КлючевыеСлова = Новый ТаблицаЗначений;
	КлючевыеСлова.Колонки.Добавить("Наименование");
	КлючевыеСлова.Колонки.Добавить("Значение");
	Для Каждого Эталон Из Эталоны Цикл
		
		Если КлючевыеСлова.НайтиСтроки(Новый Структура("Наименование", ВРег(Эталон))).Количество() = 0 Тогда
			
			СтрокаТаблицы = КлючевыеСлова.Добавить();
			СтрокаТаблицы.Наименование = ВРег(Эталон);
			СтрокаТаблицы.Значение = Эталон;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат КлючевыеСлова;
	
КонецФункции

Функция Эталоны()
	
	Эталоны = Новый Массив;
	
	Эталоны.Добавить("Если");
	Эталоны.Добавить("#Если");
	Эталоны.Добавить("Тогда");
	Эталоны.Добавить("#Тогда");
	Эталоны.Добавить("Иначе");
	Эталоны.Добавить("#Иначе");
	Эталоны.Добавить("ИначеЕсли");
	Эталоны.Добавить("#ИначеЕсли");
	Эталоны.Добавить("КонецЕсли");
	Эталоны.Добавить("#КонецЕсли");
	Эталоны.Добавить("#Область");
	Эталоны.Добавить("#КонецОбласти");
	Эталоны.Добавить("Клиент");
	Эталоны.Добавить("НаКлиенте");
	Эталоны.Добавить("НаСервере");
	Эталоны.Добавить("ТолстыйКлиентОбычноеПриложение");
	Эталоны.Добавить("ТолстыйКлиентУправляемоеПриложение");
	Эталоны.Добавить("Сервер");
	Эталоны.Добавить("ВнешнееСоединение");
	Эталоны.Добавить("ТонкийКлиент");
	Эталоны.Добавить("ВебКлиент");
	Эталоны.Добавить("&НаКлиенте");
	Эталоны.Добавить("&НаСервере");
	Эталоны.Добавить("&НаСервереБезКонтекста");
	Эталоны.Добавить("&НаКлиентеНаСервереБезКонтекста");
	Эталоны.Добавить("&НаКлиентеНаСервере");
	Эталоны.Добавить("Для");
	Эталоны.Добавить("Каждого");
	Эталоны.Добавить("Цикл");
	Эталоны.Добавить("КонецЦикла");
	Эталоны.Добавить("Выполнить");
	Эталоны.Добавить("По");
	Эталоны.Добавить("Прервать");
	Эталоны.Добавить("Продолжить");
	Эталоны.Добавить("Из");
	Эталоны.Добавить("Новый");
	Эталоны.Добавить("Перейти");
	Эталоны.Добавить("Перем");
	Эталоны.Добавить("Пока");
	Эталоны.Добавить("Попытка");
	Эталоны.Добавить("Исключение");
	Эталоны.Добавить("КонецПопытки");
	Эталоны.Добавить("ВызватьИсключение");
	Эталоны.Добавить("Процедура");
	Эталоны.Добавить("КонецПроцедуры");
	Эталоны.Добавить("Функция");
	Эталоны.Добавить("КонецФункции");
	Эталоны.Добавить("Возврат");
	Эталоны.Добавить("ДобавитьОбработчик");
	Эталоны.Добавить("УдалитьОбработчик");
	Эталоны.Добавить("И");
	Эталоны.Добавить("ИЛИ");
	Эталоны.Добавить("НЕ");
	Эталоны.Добавить("Или");
	Эталоны.Добавить("Не");
	Эталоны.Добавить("Истина");
	Эталоны.Добавить("ИСТИНА");
	Эталоны.Добавить("Ложь");
	Эталоны.Добавить("ЛОЖЬ");
	Эталоны.Добавить("Знач");
	Эталоны.Добавить("ЗНАЧ");
	Эталоны.Добавить("Неопределено");
	Эталоны.Добавить("НЕОПРЕДЕЛЕНО");
	Эталоны.Добавить("NULL");
	Эталоны.Добавить("Null");
	
	Возврат Эталоны;
	
КонецФункции

// перенесено из строковых ф-ий ибо там ошибка

Функция СформироватьСтрокуСимволов(Знач Символ, Знач ДлинаСтроки)
	
	Результат = "";
	Для Счетчик = 1 По ДлинаСтроки Цикл
		Результат = Результат + Символ;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ДополнитьСтроку(Знач Строка, Знач ДлинаСтроки, Знач Символ = "0", Знач Режим = "Слева")
	
	// Длина символа не должна превышать единицы.
	Символ = Лев(Символ, 1);
	
	КоличествоСимволовНадоДобавить = ДлинаСтроки - СтрДлина(Строка);
	
	Если КоличествоСимволовНадоДобавить > 0 Тогда
		
		СтрокаДляДобавления = СформироватьСтрокуСимволов(Символ, КоличествоСимволовНадоДобавить);
		
		Если ВРег(Режим) = "СЛЕВА" Тогда
			
			Строка = СтрокаДляДобавления + Строка;
			
		ИначеЕсли ВРег(Режим) = "СПРАВА" Тогда
			
			Строка = Строка + СтрокаДляДобавления;
		Иначе
			// ничего
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Строка;
	
КонецФункции
