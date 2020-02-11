///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды <configuration>
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

#Использовать gitrunner
Перем Лог;

///////////////////////////////////////////////////////////////////////////////

Процедура НастроитьКоманду(Знач Команда, Знач Парсер) Экспорт
	
	// Добавление параметров команды
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-global", "Работа с глобальными настройками.");
	Парсер.ДобавитьИменованныйПараметрКоманды(Команда, "-rep-path", "Каталог репозитория, настройки которого интересуют.");
	Парсер.ДобавитьИменованныйПараметрКоманды(Команда, "-child-path", "Относительный путь к каталогу с исходниками внутри каталога rep-path, для которого нужна отдельная настройка");
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-reset", "Сброс настроек на значения по умолчанию. Если редактируются настройки репозитория, то происходит удаление файла настроек.");
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-config", "Интерактивное конфигурирование настроек.");
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-child", "Указывает на работу с настройками подпроектов в репозитории, вместе с командой -reset удалит только подпроекты");

КонецПроцедуры // НастроитьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт
	
	Лог = Приложение.ПолучитьЛог();
	ОшибкаВводаПараметров = ПроверитьВалидностьПараметров(ПараметрыКоманды);
	
	Если ЗначениеЗаполнено(ОшибкаВводаПараметров) Тогда
		
		Лог.Ошибка(ОшибкаВводаПараметров);
		Возврат Приложение.РезультатыКоманд().НеверныеПараметры;
		
	КонецЕсли;

	РаботаСГлобальнымиНастройками = ПараметрыКоманды["-global"];
	
	Если РаботаСГлобальнымиНастройками Тогда
		
		КаталогРепозитория = Приложение.ПутьКРодительскомуКаталогу();
		УправлениеНастройками = МенеджерНастроек.ГлобальныеНастройки();

	Иначе
		
		КаталогРепозитория = ПараметрыКоманды["-rep-path"];
		УправлениеНастройками = МенеджерНастроек.НастройкиРепозитория(КаталогРепозитория, Ложь);
		
	КонецЕсли;
	
	Если ПараметрыКоманды["-reset"] Тогда
		
		Если РаботаСГлобальнымиНастройками Тогда
			
			РедакторНастроек.СброситьГлобальныеНастройки();
			
		Иначе
			
			РедакторНастроек.СброситьНастройкиРепозитория(ПараметрыКоманды["-child"], ПараметрыКоманды["-child-path"]);
			
		КонецЕсли;
		
	ИначеЕсли ПараметрыКоманды["-config"] Тогда
		
		Если ЗначениеЗаполнено(ПараметрыКоманды["-child-path"]) Тогда
			
			УказанныйПуть = ПараметрыКоманды["-child-path"];
			
			Если ПроверитьАдресДополнительногоКаталога(КаталогРепозитория, УказанныйПуть, УправлениеНастройками) Тогда
				
				УказанныйПуть = ФайловыеОперации.ПолучитьНормализованныйОтносительныйПуть(КаталогРепозитория, УказанныйПуть);
				НовыеНастройки = ИнтерактивнаяНастройка(УказанныйПуть, УправлениеНастройками, Ложь, Приложение.КаталогСценариев(), Истина);
				УправлениеНастройками.ОбновитьКонфигурацию();
				УправлениеНастройками.ЗаписатьНастройкиПриложения(УказанныйПуть, НовыеНастройки.Получить(УказанныйПуть));
				
			КонецЕсли;
			
		Иначе
			
			НовыеНастройки = ИнтерактивнаяНастройка(КаталогРепозитория, УправлениеНастройками, РаботаСГлобальнымиНастройками, Приложение.КаталогСценариев());
			СконфигурироватьДополнительныеКаталоги(УправлениеНастройками, НовыеНастройки, Приложение.КаталогСценариев(), КаталогРепозитория);
			РедакторНастроек.СброситьНастройкиРепозитория();
			РедакторНастроек.ЗаписатьНастройкиРепозитория(НовыеНастройки);
			
		КонецЕсли;
		
	Иначе
		
		НапечататьНастройки(УправлениеНастройками);
		
	КонецЕсли;
	
	// При успешном выполнении возвращает код успеха
	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду

Функция ПроверитьВалидностьПараметров(ПараметрыКоманды)
	
	ОшибкаПараметров = "";
	
	Если НЕ ПараметрыКоманды["-global"]
		И НЕ ЗначениеЗаполнено(ПараметрыКоманды["-rep-path"]) Тогда
		
		ОшибкаПараметров ="Для конфигурирования необходимо передать флаг -global или указать каталог репозитория параметром -rep-path";
		
	ИначеЕсли ПараметрыКоманды["-global"] И ЗначениеЗаполнено(ПараметрыКоманды["-child-path"]) Тогда
		
		ОшибкаПараметров = "Нельзя конфигурировать дополнительные проекты глобально";
		
	КонецЕсли;
	
	Возврат ОшибкаПараметров;
	
КонецФункции

Процедура НапечататьНастройки(УправлениеНастройками)
	
	Если МенеджерНастроек.ЭтоНовый() Тогда
		
		Лог.Информация("Файл настроек не обнаружен");
		Возврат;
		
	КонецЕсли;
	
	НапечататьНастройкиПроекта("", "Базовые настройки");

	ПроектыКонфигурации = МенеджерНастроек.ПроектыКонфигурации();
	
	Для Каждого ИмяПроекта из ПроектыКонфигурации Цикл
		
		НапечататьНастройкиПроекта(ИмяПроекта, ИмяПроекта);

	КонецЦикла;
	
КонецПроцедуры

Процедура НапечататьНастройкиПроекта(ИмяПроекта, ПредставлениеПроекта)

	НастройкиПроекта = МенеджерНастроек.НастройкиПроекта(ИмяПроекта);
		
	Если НЕ ЗначениеЗаполнено(НастройкиПроекта) Тогда
		
		Лог.Информация(СтрШаблон("Настройки %1 в файле отсутствуют", ПредставлениеПроекта));
		Возврат;
		
	КонецЕсли;
	
	Сообщить("Установленные настройки: " + ПредставлениеПроекта);
	
	ВывестиНастройкиРекурсивно(НастройкиПроекта);

КонецПроцедуры

Процедура ВывестиНастройкиРекурсивно(НастройкиПрекоммита, Уровень = 1)
	
	ПробельныеСимволы = "";
	
	Для Счетчик = 1 по Уровень Цикл
		
		ПробельныеСимволы = ПробельныеСимволы + Символы.Таб;
		
	КонецЦикла;
	
	Для Каждого НастройкаПрекоммита Из НастройкиПрекоммита Цикл
		
		Если ТипЗнч(НастройкаПрекоммита.Значение) = Тип("Массив") Тогда
			
			ЗначениеПараметра = СтрСоединить(НастройкаПрекоммита.Значение, ",");
			
		Иначе
			
			ЗначениеПараметра = НастройкаПрекоммита.Значение;
			
		КонецЕсли;
		
		Сообщить(ПробельныеСимволы + НастройкаПрекоммита.Ключ + " = " + ЗначениеПараметра);
		
		Если ТипЗнч(НастройкаПрекоммита.Значение) = Тип("Соответствие") Тогда
			
			ВывестиНастройкиРекурсивно(НастройкаПрекоммита.Значение, Уровень + 1);
			
		КонецЕсли; 
		
	КонецЦикла;
	
КонецПроцедуры

Функция ИнтерактивнаяНастройка(КаталогРепозитория, УправлениеНастройками, ГлобальныеНастройки, КаталогГлобальныхСценариев, ЭтоДопПроект = Ложь)

	ИмяПриложения = УправлениеНастройками.ИмяПоУмолчанию();
	ПолныеНастройки = Новый Соответствие;
	Сообщить(СтрШаблон("Настройка конфигурации precommit %1%2", Символы.ПС, КаталогРепозитория));
	
	ГлобальныеСценарии 	= МенеджерНастроек.ЗначениеНастройки("ГлобальныеСценарии");
	ОтключенныеСценарии = МенеджерНастроек.ЗначениеНастройки("ОтключенныеСценарии");
	ИменаСценариев 		= МенеджерНастроек.ПолучитьИменаСценариевКаталога(КаталогГлобальныхСценариев);
	
	Лог.Отладка("Сохраненные значения опции 'ГлобальныеСценарии': %1%2", 
		Символы.ПС, ?(НЕ ЗначениеЗаполнено(ГлобальныеСценарии), "<пусто>", СтрСоединить(ГлобальныеСценарии, Символы.ПС)));
	Лог.Отладка("Сохраненные значения опции 'ОтключенныеСценарии': %1%2", 
		Символы.ПС, ?(НЕ ЗначениеЗаполнено(ОтключенныеСценарии), "<пусто>", СтрСоединить(ОтключенныеСценарии, Символы.ПС)));

	Если ИнтерактивныйРедактор.ПолучитьНастройкуБулево("Выполнить настройку подключенных глобальных сценариев?", Истина) Тогда
	
		ГлобальныеСценарии = ИнтерактивныйРедактор.ПолучитьНастройкуМассив("Выберите подключаемые глобальные сценарии: ", 
			ИменаСценариев, ГлобальныеСценарии);
		
	ИначеЕсли ИнтерактивныйРедактор.ПолучитьНастройкуБулево("Выполнить настройку отключенных глобальных сценариев?", Истина) Тогда
		
		ОтключенныеСценарии = ИнтерактивныйРедактор.ПолучитьНастройкуМассив("Выберите отключаемые глобальные сценарии: ", 
			ИменаСценариев, ?(ОтключенныеСценарии = Неопределено, Новый Массив, ОтключенныеСценарии));
		
	КонецЕсли;
	
	Если ГлобальныеНастройки Тогда
		
		Подсказка = "Нужно использовать сценарии локальных репозиториев?";
		
	Иначе
		
		Подсказка = "Нужно использовать локальные сценарии?";
		
	КонецЕсли;
	
	ИспользоватьСценарииРепозитория = ИнтерактивныйРедактор.ПолучитьНастройкуБулево(Подсказка, МенеджерНастроек.ЗначениеНастройки("ИспользоватьСценарииРепозитория"));
	
	КаталогЛокальныхСценариев = "";

	Если ИспользоватьСценарииРепозитория Тогда
		
		КаталогЛокальныхСценариев = ИнтерактивныйРедактор.ПолучитьНастройкуСтрока("Укажите относительный путь к сценариям в репозитории: ", 
		УправлениеНастройками.Настройка(ИмяПриложения + "\КаталогЛокальныхСценариев"));
		
	КонецЕсли;
	
	НастройкиПриложения	= РедакторНастроек.ПолучитьСтандартнуюСтруктуруНастроек();
	
	Если ГлобальныеСценарии <> Неопределено Тогда
		
		ИсполняемыеСценарии = МенеджерНастроек.ПолучитьСписокИсполняемыхСценариев(ГлобальныеСценарии, ОтключенныеСценарии);
		
	Иначе

		ИсполняемыеСценарии = МенеджерНастроек.ПолучитьСписокИсполняемыхСценариев(ИменаСценариев, ОтключенныеСценарии);

	КонецЕсли;
	
	Лог.Отладка("Итоговый список исполняемых сценариев: %1%2", Символы.ПС, СтрСоединить(ИсполняемыеСценарии, Символы.ПС));

	НастройкиСценариев	= СценарииОбработки.СформироватьНастройкиСценариев(ИсполняемыеСценарии, КаталогГлобальныхСценариев);
	
	НастройкиПриложения.Вставить("ИспользоватьСценарииРепозитория", ИспользоватьСценарииРепозитория);
	НастройкиПриложения.Вставить("КаталогЛокальныхСценариев", КаталогЛокальныхСценариев);

	Если ГлобальныеСценарии <> Неопределено Тогда
		НастройкиПриложения["ГлобальныеСценарии"] = ГлобальныеСценарии;
		Лог.Отладка("Новое значение опции 'ГлобальныеСценарии': %1", СтрСоединить(ГлобальныеСценарии, ", "));
	ИначеЕсли НЕ ГлобальныеНастройки Тогда
		// Для локальных удалим ключ, чтоб использовались глобальные
		НастройкиПриложения.Удалить("ГлобальныеСценарии");
	Иначе
		// Останется значение по умолчанию - пустой массив
	КонецЕсли;

	Если ОтключенныеСценарии <> Неопределено Тогда
		НастройкиПриложения["ОтключенныеСценарии"] = ОтключенныеСценарии;
		Лог.Отладка("Новое значение опции 'ОтключенныеСценарии': %1", СтрСоединить(ОтключенныеСценарии, ", "));
	КонецЕсли;

	НастройкиПриложения.Вставить("НастройкиСценариев", НастройкиСценариев);
	
	//ИмяПриложения = ?(ЭтоДопПроект, КаталогРепозитория, УправлениеНастройками.ИмяПоУмолчанию());
	Если ЭтоДопПроект Тогда 
		НастройкиКаталога = Новый Соответствие;
		ПолныеНастройки.Вставить(КаталогРепозитория, НастройкиПриложения);
	КонецЕсли;
	
	ПолныеНастройки.Вставить(ИмяПриложения, НастройкиПриложения);
	
	Возврат ПолныеНастройки;
	
КонецФункции

Процедура СконфигурироватьДополнительныеКаталоги(УправлениеНастройками, ОсновныеНастройки, КаталогГлобальныхСценариев, КаталогРепозитория)
	
	Пока ИнтерактивныйРедактор.ПолучитьНастройкуБулево("Сконфигурировать дополнительный каталог со своими правилами обработки?", Ложь) Цикл
		
		АдресКаталога = ИнтерактивныйРедактор.ПолучитьНастройкуСтрока("Введите относительный путь в репозитории к каталогу", "");
		
		Если ПроверитьАдресДополнительногоКаталога(КаталогРепозитория, АдресКаталога, УправлениеНастройками) Тогда 
			
			АдресКаталога = ФайловыеОперации.ПолучитьНормализованныйОтносительныйПуть(КаталогРепозитория, АдресКаталога);
			НастройкиДополнительные = ИнтерактивнаяНастройка(АдресКаталога, УправлениеНастройками, Ложь, КаталогГлобальныхСценариев, Истина);
			ОсновныеНастройки.Вставить(АдресКаталога, НастройкиДополнительные.Получить(АдресКаталога));
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПроверитьАдресДополнительногоКаталога(КаталогРепозитория, АдресКаталога, УправлениеНастройками)
	
	РазрешеноДобавление = Истина;
	КаталогВРепо		= ФайловыеОперации.ПолучитьНормализованныйПолныйПуть(КаталогРепозитория, АдресКаталога);
	НастроенныеПроекты	= МенеджерНастроек.ПроектыКонфигурации();
	Файл				= Новый Файл(КаталогВРепо);
	Сообщение			= "";
	
	Если Файл.Существует() И Файл.ЭтоКаталог() Тогда
		
		Для Каждого ИмяПроекта Из НастроенныеПроекты Цикл
			
			КаталогНастроенныйВКонфигурации = ФайловыеОперации.ПолучитьНормализованныйПолныйПуть(КаталогРепозитория, ИмяПроекта);
			
			Если КаталогВРепо = КаталогНастроенныйВКонфигурации Тогда
				
				Сообщение = "Каталог уже добавлен";
				РазрешеноДобавление = Ложь;
				Прервать;
				
			ИначеЕсли СтрНачинаетсяС(КаталогВРепо, КаталогНастроенныйВКонфигурации) ИЛИ СтрНачинаетсяС(КаталогНастроенныйВКонфигурации, КаталогВРепо) Тогда
				
				РазрешеноДобавление = Ложь;
				Сообщение = "Невозможно добавить вложенный каталог";
				Прервать;
				
			КонецЕсли;
			
		КонецЦикла;

	Иначе
		
		РазрешеноДобавление = Ложь;
		Сообщение = "Каталога не существует или это файл";
		
	КонецЕсли;
	
	Если НЕ РазрешеноДобавление Тогда 
		Сообщить(Сообщение);
	КонецЕсли;
	
	Возврат РазрешеноДобавление;
	
КонецФункции
