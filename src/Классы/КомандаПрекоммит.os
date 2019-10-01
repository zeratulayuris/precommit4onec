///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды <precommit>
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

#Использовать gitrunner

Перем Лог;
Перем РепозиторийGit;

///////////////////////////////////////////////////////////////////////////////

Процедура НастроитьКоманду(Знач Команда, Знач Парсер) Экспорт
	
	// Добавление параметров команды
	Парсер.ДобавитьПозиционныйПараметрКоманды(Команда, "КаталогРепозитория", "Каталог анализируемого репозитория");
	Парсер.ДобавитьИменованныйПараметрКоманды(Команда, "-source-dir", 
		"Каталог расположения исходных файлов относительно корня репозитория. По умолчанию <src>");
	
КонецПроцедуры // НастроитьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт
	
	Лог = Приложение.ПолучитьЛог();
	
	КаталогРепозитория = ПараметрыКоманды["КаталогРепозитория"];
	ФайлКаталогРепозитория = Новый Файл(КаталогРепозитория);
	Если НЕ ФайлКаталогРепозитория.Существует() ИЛИ ФайлКаталогРепозитория.ЭтоФайл() Тогда
		
		Лог.Ошибка("Каталог репозитория '%1' не существует или это файл", КаталогРепозитория);
		Возврат Приложение.РезультатыКоманд().НеверныеПараметры;
		
	КонецЕсли;
	
	УправлениеНастройками = Новый НастройкиРепозитория(КаталогРепозитория);
	Если УправлениеНастройками.ЭтоНовый() 
			ИЛИ УправлениеНастройками.НастройкиПриложения("Precommt4onecСценарии").Количество() = 0 Тогда
		
		Лог.Информация("Используем глобальные настройки");
		УправлениеНастройками = Новый НастройкиРепозитория(Приложение.ПутьКРодительскомуКаталогу());
		
	Иначе
		
		Лог.Информация("Используем локальные настройки");
		
	КонецЕсли;
	
	КаталогИсходныхФайлов = ПараметрыКоманды["-source-dir"];
	Если Не ЗначениеЗаполнено(КаталогИсходныхФайлов) Тогда
		
		КаталогИсходныхФайлов = "src";
		
	КонецЕсли;
	
	ТекущийКаталогИсходныхФайлов = ОбъединитьПути(КаталогРепозитория, КаталогИсходныхФайлов);
	ФайлТекущийКаталогИсходныхФайлов = Новый Файл(ТекущийКаталогИсходныхФайлов);
	ТекущийКаталогИсходныхФайлов = ФайлТекущийКаталогИсходныхФайлов.ПолноеИмя;
	
	Если НЕ ФайлТекущийКаталогИсходныхФайлов.Существует() Тогда
		
		СоздатьКаталог(ТекущийКаталогИсходныхФайлов);
		
	КонецЕсли;
	
	КаталогРепозитория = ФайлКаталогРепозитория.ПолноеИмя;
	РепозиторийGit = Новый ГитРепозиторий();
	РепозиторийGit.УстановитьРабочийКаталог(КаталогРепозитория);
	
	Если НЕ РепозиторийGit.ЭтоРепозиторий() Тогда
		
		Лог.Ошибка("Каталог '%1' не является репозиторием git", КаталогРепозитория);
		Возврат Приложение.РезультатыКоманд().НеверныеПараметры;
		
	КонецЕсли;

	НастройкиПроектов = УправлениеНастройками.ПолучитьПроектыКонфигурации();	
	НаборНастроек = Новый Соответствие;
	
	Для Каждого ЭлементНастройки из НастройкиПроектов Цикл
		Настройка = Новый Структура("СценарииОбработки, НастройкиСценариев");
		Настройка.СценарииОбработки = ЗагрузитьСценарииОбработки(Приложение.КаталогСценариев(), 
																УправлениеНастройками, 
																КаталогРепозитория, 
																ЭлементНастройки);
		Настройка.НастройкиСценариев = УправлениеНастройками.НастройкиПриложения(ЭлементНастройки);
		НаборНастроек.Вставить(ЭлементНастройки, Настройка);
	КонецЦикла;
	
	ЖурналИзменений = ПолучитьЖурналИзменений();
	
	Ит = 0;
	ПараметрыОбработки = Новый Структура("ФайлыДляПостОбработки, ИзмененныеКаталоги, КаталогРепозитория, Настройки", 
											Новый Массив, Новый Массив, КаталогРепозитория);
	ПараметрыОбработки.Вставить("Лог", Лог);
	Пока Ит < ЖурналИзменений.Количество() Цикл
		
		АнализируемыйФайл = Новый Файл(ОбъединитьПути(КаталогРепозитория, ЖурналИзменений[Ит].ИмяФайла));
		Лог.Отладка("Анализируется файл <%1>", АнализируемыйФайл.Имя);
		
		ИмяФайла = ФайловыеОперации.ПолучитьНормализованныйОтносительныйПуть(КаталогРепозитория, 
																				ЖурналИзменений[Ит].ИмяФайла);
		НастройкаОбработки = ПолучитьПараметрыОбработкиФайла(ИмяФайла, УправлениеНастройками, НаборНастроек);
	
		СценарииОбработки =  НастройкаОбработки.СценарииОбработки;
		НастройкиСценариев = НастройкаОбработки.НастройкиСценариев;
		
		ПараметрыОбработки.Настройки = НастройкиСценариев.Получить("НастройкиСценариев");
		Для Каждого СценарийОбработки Из СценарииОбработки Цикл
			
			ФайлОбработан = СценарийОбработки.Сценарий.ОбработатьФайл(АнализируемыйФайл, 
																		ТекущийКаталогИсходныхФайлов, 
																		ПараметрыОбработки);
			
			Если НЕ ФайлОбработан Тогда
				Продолжить;
			КонецЕсли;
				
			Для Каждого ФайлДляДопОбработки Из ПараметрыОбработки.ФайлыДляПостОбработки Цикл
					
				ЖурналИзменений.Добавить(Новый Структура("ИмяФайла, ТипИзменения", 
											СтрЗаменить(ФайлДляДопОбработки, КаталогРепозитория, ""), 
											ВариантИзмененийФайловGit.Изменен));
					
			КонецЦикла;
				
			ПараметрыОбработки.ФайлыДляПостОбработки.Очистить();
			
		КонецЦикла;
		
		Ит = Ит + 1;
		
	КонецЦикла;
	
	// измененные каталоги необходимо добавить в индекс
	Лог.Отладка("Добавление измененных каталогов в индекс git");
	Для Каждого Каталог Из ПараметрыОбработки.ИзмененныеКаталоги Цикл
		
		РепозиторийGit.ДобавитьФайлВИндекс("""" + Каталог + """");
		
	КонецЦикла;
	
	// При успешном выполнении возвращает код успеха
	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду

///////////////////////////////////////////////////////////////////////////////

Функция ПолучитьПараметрыОбработкиФайла(ИмяФайла, УправлениеНастройками, НастройкиПроектов)
	
	ИмяОбщейНастройки = УправлениеНастройками.ИмяПоУмолчанию();
	НайденнаяНастройка = НастройкиПроектов.Получить(ИмяОбщейНастройки);
	
	Для Каждого ЭлементНастройки Из НастройкиПроектов Цикл
		
		Если ЭлементНастройки.Ключ = ИмяОбщейНастройки Тогда
				
			Продолжить;
			
		ИначеЕсли СтрНачинаетсяС(ИмяФайла, ЭлементНастройки.Ключ) Тогда 
			
			НайденнаяНастройка = ЭлементНастройки.Значение;
			
		Иначе
			// ничего
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат НайденнаяНастройка;

КонецФункции

Функция ПолучитьЖурналИзменений()
	
	ПараметрыКомандыGit = Новый Массив;
	ПараметрыКомандыGit.Добавить("diff --name-status --staged --no-renames");
	РепозиторийGit.ВыполнитьКоманду(ПараметрыКомандыGit);
	РезультатВывода	= РепозиторийGit.ПолучитьВыводКоманды();
	СтрокиВывода	= СтрРазделить(РезультатВывода, Символы.ПС);
	ЖурналИзменений	= Новый Массив;
	
	Для Каждого СтрокаВывода Из СтрокиВывода Цикл
		
		Лог.Отладка("	<%1>", СтрокаВывода);
		
		СтрокаВывода	= СокрЛП(СтрокаВывода);
		ПозицияПробела	= СтрНайти(СтрокаВывода, Символы.Таб);
		СимволИзменения	= Лев(СтрокаВывода, 1);
		
		ТипИзменения 	= ВариантИзмененийФайловGit.ОпределитьВариантИзменения(СимволИзменения);
		ИмяФайла 		= СокрЛП(СтрЗаменить(Сред(СтрокаВывода, ПозицияПробела + 1), """", ""));
		ЖурналИзменений.Добавить(Новый Структура("ИмяФайла, ТипИзменения", ИмяФайла, ТипИзменения));
		
		Лог.Отладка("		В журнале git %2 файл <%1>", ИмяФайла, ТипИзменения);
		
	КонецЦикла;
	
	Возврат ЖурналИзменений;
	
КонецФункции

Функция ЗагрузитьСценарииОбработки(ТекущийКаталогСценариев, УправлениеНастройками, КаталогРепозитория, КлючНастройки)
	
	СценарииОбработки = Новый Массив;
	ФайлыГлобальныхСценариев = НайтиФайлы(ТекущийКаталогСценариев, "*.os");
	ФайлыЛокальныхСценариев = Новый Массив;
	ИменаЗагружаемыхСценариев = Новый Массив;
	
	Если НЕ УправлениеНастройками.ЭтоНовый() Тогда
		
		Лог.Информация("Читаем настройки " + КлючНастройки);
		ИменаЗагружаемыхСценариев = УправлениеНастройками.Настройка(КлючНастройки + "\ГлобальныеСценарии");
		Если УправлениеНастройками.Настройка(КлючНастройки + "\ИспользоватьСценарииРепозитория") Тогда
			
			ЛокальныйКаталог = УправлениеНастройками.Настройка(КлючНастройки + "\КаталогЛокальныхСценариев");
			ПутьКЛокальнымСценариям = ОбъединитьПути(КаталогРепозитория, ЛокальныйКаталог);
			ФайлПутьКЛокальнымСценариям = Новый Файл(ПутьКЛокальнымСценариям);
			
			Если Не ФайлПутьКЛокальнымСценариям.Существует() ИЛИ ФайлПутьКЛокальнымСценариям.ЭтоФайл() Тогда
				
				Лог.Ошибка("Сценарии из репозитория не загружены т.к. отсутствует каталог %1", ЛокальныйКаталог);
				
			Иначе
				
				ФайлыЛокальныхСценариев = НайтиФайлы(ФайлПутьКЛокальнымСценариям.ПолноеИмя, "*.os");
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ЗагрузитьСценарииИзКаталога(СценарииОбработки, ФайлыГлобальныхСценариев, ИменаЗагружаемыхСценариев);
	ЗагрузитьСценарииИзКаталога(СценарииОбработки, ФайлыЛокальныхСценариев, , Истина);
	
	Если СценарииОбработки.Количество() = 0 Тогда
		
		ВызватьИсключение "Нет доступных сценариев обработки файлов";
		
	КонецЕсли;
	Возврат СценарииОбработки;
КонецФункции

Процедура ЗагрузитьСценарииИзКаталога(СценарииОбработки, ФайлыСценариев, 
										Знач ИменаЗагружаемыхСценариев = Неопределено, 
										ЗагрузитьВсе = Ложь)
	
	Если ИменаЗагружаемыхСценариев = Неопределено Тогда
		
		ИменаЗагружаемыхСценариев = Новый Массив;
		
	КонецЕсли;
	
	Для Каждого ФайлСценария Из ФайлыСценариев Цикл		
		
		Если СтрСравнить(ФайлСценария.ИмяБезРасширения, "ШаблонСценария") = 0 Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Если НЕ ЗагрузитьВсе И ИменаЗагружаемыхСценариев.Найти(ФайлСценария.Имя) = Неопределено Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Попытка
			
			СценарийОбработки = ЗагрузитьСценарий(ФайлСценария.ПолноеИмя);
			СценарииОбработки.Добавить(Новый Структура("ИмяСценария, Сценарий", 
										СценарийОбработки.ИмяСценария(), СценарийОбработки));
			
		Исключение
			
			Лог.Ошибка("Ошибка загрузки сценария %1: %2", ФайлСценария.ПолноеИмя, ОписаниеОшибки());
			Продолжить;
			
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры
