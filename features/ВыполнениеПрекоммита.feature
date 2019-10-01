# language: ru

Функциональность: Выполнение прекоммита

Как разработчик
Я хочу быть уверенным, что precommit4onec корректно обрабатывает изменения в репозитории

Контекст:
	Допустим Я очищаю параметры команды "oscript" в контексте 
		И я очищаю параметры команды "git" в контексте
		И Я устанавливаю кодировку вывода "utf-8" команды "git"
		И я включаю отладку лога с именем "oscript.app.precommit4onec"
		И я создаю временный каталог и запоминаю его как "КаталогРепозиториев"
		И я переключаюсь во временный каталог "КаталогРепозиториев"
		И я создаю новый репозиторий без инициализации "rep1" в каталоге "КаталогРепозиториев" и запоминаю его как "РабочийКаталог"
		И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os install rep1"
		И я установил рабочий каталог как текущий каталог

Сценарий: Успешный инициализирующий коммит в репозиторий после установки прекоммита
	Когда Я создаю файл "РабочийКаталог/readme.md" с текстом "Инициализация"
		И я выполняю команду "git" с параметрами "add ."
		И я выполняю команду "git" с параметрами "commit -m init"
	Тогда я не вижу в консоли вывод "ВызватьИсключение"
		И я не вижу в консоли вывод "fatal:"

Контекст:
	Допустим Я очищаю параметры команды "oscript" в контексте 
		И я очищаю параметры команды "git" в контексте
		И Я устанавливаю кодировку вывода "utf-8" команды "git"
		И я включаю отладку лога с именем "oscript.app.precommit4onec"
		И я создаю временный каталог и запоминаю его как "КаталогРепозиториев"
		И я переключаюсь во временный каталог "КаталогРепозиториев"
		И я создаю новый репозиторий "rep1" в каталоге "КаталогРепозиториев" и запоминаю его как "РабочийКаталог"
		И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os install rep1"
		И я установил рабочий каталог как текущий каталог
		
Сценарий: Разбор отчетов, обработок, конфигурации на исходники.
	Когда Я копирую файл "tests/fixtures/demo/DemoОбработка.epf" в каталог репозитория "РабочийКаталог"
		И я копирую файл "tests/fixtures/demo/DemoОтчет.erf" в каталог репозитория "РабочийКаталог"
		И я копирую файл "tests/fixtures/demo/DemoРасширение.cfe" в каталог репозитория "РабочийКаталог"
		И я фиксирую изменения в репозитории "РабочийКаталог" с комментарием "demo коммит"
	Тогда В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяОФ\Ext\Form\Module.bsl"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяОФ\Ext\Form\form"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Templates\ОсновнаяСхемаКомпоновкиДанных.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Templates\ОсновнаяСхемаКомпоновкиДанных\Ext\Template.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяОФ.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяОФ\Ext\Form.bin"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяУФ.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяУФ\Ext\Form.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ\Ext\Form.bin"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяУФ.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяУФ\Ext\Form.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ\Ext\Form\Module.bsl"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ\Ext\Form\form"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\ConfigDumpInfo.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\Configuration.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\CommonModules\DemoРасш_Demo.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\CommonModules\DemoРасш_Demo\Ext\Module.bsl"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\Subsystems\DemoРасш_Demo.xml"
		И В каталоге "src" репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\Languages\Русский.xml"

Сценарий: Успешный коммит в репозиторий
	Когда Я копирую файл "tests\fixtures\ПроверкаДублейПроцедурПоложительныйТест.bsl" в каталог репозитория "РабочийКаталог"
	И Я установил рабочий каталог как текущий каталог
	И Я выполняю команду "git" с параметрами "add --all"
	И Я выполняю команду "git" с параметрами "commit -m addProcedure" 
	Тогда Вывод команды "git" не содержит "обнаружены неуникальные имена методов"

Сценарий: Прекоммит заблокировал коммит в репозиторий
	Когда Я копирую файл "tests\fixtures\ПроверкаДублейПроцедурНегативныйТест.bsl" в каталог репозитория "РабочийКаталог"
	И Я установил рабочий каталог как текущий каталог
	И Я выполняю команду "git" с параметрами "add --all"
	И Я выполняю команду "git" с параметрами "commit -m addProcedure"
	Тогда Вывод команды "git" содержит "обнаружены неуникальные имена методов"

Сценарий: Прекоммит использует локальные настройки репозитория вместо глобальных
	Когда Я копирую каталог "localscenario" из каталога "tests\fixtures" проекта в рабочий каталог
		И Я копирую файл "v8config.json" из каталога "tests\fixtures" проекта в рабочий каталог
		И я выполняю команду "git" с параметрами "add --all"
		И я выполняю команду "git" с параметрами "commit -m addFile"
	Тогда я вижу в консоли вывод "Используем локальные настройки"

Сценарий: Выполнение локальных сценариев к каталоге репозитория
	Когда Я копирую файл "tests\fixtures\demo\DemoОбработка.epf" в каталог репозитория "РабочийКаталог"
		И Я копирую каталог "localscenario" из каталога "tests\fixtures" проекта в рабочий каталог
		И Я копирую файл "v8config.json" из каталога "tests\fixtures" проекта в рабочий каталог
		И я выполняю команду "git" с параметрами "add --all"
		И я выполняю команду "git" с параметрами "commit -m addFile"
	Тогда я вижу в консоли вывод "ДобавлениеHelloWorld"

Сценарий: Когда выключены глобальные сценарии и нет локальных прекоммит выдает ошибку
	Когда Я копирую файл "v8config.json" из каталога "tests\fixtures" проекта в рабочий каталог
		И я выполняю команду "git" с параметрами "add --all"
		И я выполняю команду "git" с параметрами "commit -m addFile"
	Тогда я вижу в консоли вывод "Нет доступных сценариев обработки файлов"

Сценарий: В коммит попадают только проиндексированные файлы
	Когда Я копирую файл "tests\fixtures\demo\DemoОбработка.epf" в каталог репозитория "РабочийКаталог"
		И я фиксирую изменения в репозитории "РабочийКаталог" с комментарием "demo коммит"
		И в каталоге "src" репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ\Ext\Form\Module.bsl"
		И я создаю файл "РабочийКаталог/src/ФайлСТекстом.bsl" с текстом "текст178"
		И я выполняю команду "git" с параметрами "add --all"
		И я создаю файл "РабочийКаталог\src\epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ\Ext\Form\Module.bsl" с текстом "текст178"
		И я выполняю команду "git" с параметрами "commit -m addFile"
	Тогда Вывод команды "git" не содержит "Module.bsl"

Сценарий: По умолчанию прекоммит убирает полнотекстовый поиск в исходниках конфигуратора
	Когда Я копирую файл "tests\fixtures\Документ.xml" в каталог репозитория "РабочийКаталог"
		И Файл "Документ.xml" в рабочем каталоге содержит "FullTextSearch>Use<"
		И я фиксирую изменения в репозитории "РабочийКаталог" с комментарием "demo коммит"
	Тогда Файл "Документ.xml" в рабочем каталоге не содержит "FullTextSearch>Use<"

Сценарий: По умолчанию прекоммит убирает полнотекстовый поиск в исходниках EDT
	Когда Я копирую файл "tests\fixtures\Документ.mdo" в каталог репозитория "РабочийКаталог"
		И Файл "Документ.mdo" в рабочем каталоге содержит "fullTextSearch>Use<"
		И я фиксирую изменения в репозитории "РабочийКаталог" с комментарием "demo коммит"
	Тогда Файл "Документ.mdo" в рабочем каталоге не содержит "fullTextSearch>Use<"

Сценарий: Отключение полнотекстового поиска игнорирует файл в исключении
	Когда Я создаю каталог "src" в рабочем каталоге
		И Я копирую файл "Документ.mdo" из каталога "tests\fixtures" проекта в подкаталог "src" рабочего каталога
		И Я копирую файл "Документ.xml" из каталога "tests\fixtures" проекта в подкаталог "src" рабочего каталога
		И Файл "src\Документ.mdo" в рабочем каталоге содержит "fullTextSearch>Use<"
		И Файл "src\Документ.xml" в рабочем каталоге содержит "FullTextSearch>Use<"
		И я создаю файл "РабочийКаталог\v8config.json" с текстом  
		"""
		{
			"Precommt4onecСценарии": {
				"ИспользоватьСценарииРепозитория": false,
				"КаталогЛокальныхСценариев": "",
				"ГлобальныеСценарии": [
					"ОтключениеПолнотекстовогоПоиска.os"
				],
				"НастройкиСценариев": {
					"ОтключениеПолнотекстовогоПоиска": {
						"МетаданныеДляИсключения": {
							"src\\Документ.mdo": []
						}
					}
				}
			}
		}
		"""
		И я фиксирую изменения в репозитории "РабочийКаталог" с комментарием "demo коммит"
	Тогда Файл "\src\Документ.mdo" в рабочем каталоге содержит "fullTextSearch>Use<"
		И Файл "\src\Документ.xml" в рабочем каталоге не содержит "FullTextSearch>Use<"

Сценарий: Прекоммит, анализируя исходники исправляет неканоничкое написание ключевых слов на каноническое 
	Когда Я копирую файл "tests\fixtures\ИсправлениеНеКаноническогоНаписания.bsl" в каталог репозитория "РабочийКаталог"
		И я выполняю команду "git" с параметрами "add --all"
		И я выполняю команду "git" с параметрами "commit -m addFile"
	Тогда Вывод команды "git" содержит """
		ИНФОРМАЦИЯ - В строке 5 найдено ключевое слово '#область' заменено на '#Область'
		ИНФОРМАЦИЯ - В строке 7 найдено ключевое слово 'ПЕРЕМ' заменено на 'Перем'
		ИНФОРМАЦИЯ - В строке 8 найдено ключевое слово 'перем' заменено на 'Перем'
		ИНФОРМАЦИЯ - В строке 14 найдено ключевое слово '#КонецОБласти' заменено на '#КонецОбласти'
		ИНФОРМАЦИЯ - В строке 16 найдено ключевое слово '&НаКлиентенаСервере' заменено на '&НаКлиентеНаСервере'
		ИНФОРМАЦИЯ - В строке 17 найдено ключевое слово 'ПРоцедура' заменено на 'Процедура'
		ИНФОРМАЦИЯ - В строке 18 найдено ключевое слово 'конецпроцедуры' заменено на 'КонецПроцедуры'
		ИНФОРМАЦИЯ - В строке 20 найдено ключевое слово '&Насервере' заменено на '&НаСервере'
		ИНФОРМАЦИЯ - В строке 21 найдено ключевое слово 'процедура' заменено на 'Процедура'
		ИНФОРМАЦИЯ - В строке 24 найдено ключевое слово '&Наклиенте' заменено на '&НаКлиенте'
		ИНФОРМАЦИЯ - В строке 25 найдено ключевое слово 'функция' заменено на 'Функция'
		ИНФОРМАЦИЯ - В строке 26 найдено ключевое слово '#если' заменено на '#Если'
		ИНФОРМАЦИЯ - В строке 26 найдено ключевое слово '#тогда' заменено на '#Тогда'
		ИНФОРМАЦИЯ - В строке 26 найдено ключевое слово 'КлиенТ' заменено на 'Клиент'
		ИНФОРМАЦИЯ - В строке 26 найдено ключевое слово 'сервер' заменено на 'Сервер'
		ИНФОРМАЦИЯ - В строке 27 найдено ключевое слово 'перейти' заменено на 'Перейти'
		ИНФОРМАЦИЯ - В строке 28 найдено ключевое слово '#Конецесли' заменено на '#КонецЕсли'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'если' заменено на 'Если'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'тогда' заменено на 'Тогда'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'иначе' заменено на 'Иначе'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'конецесли' заменено на 'КонецЕсли'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'возврат' заменено на 'Возврат'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'и' заменено на 'И'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'не' заменено на 'НЕ'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'истина' заменено на 'Истина'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'ложь' заменено на 'Ложь'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'НеОпределено' заменено на 'Неопределено'
		ИНФОРМАЦИЯ - В строке 30 найдено ключевое слово 'null' заменено на 'NULL'
		ИНФОРМАЦИЯ - В строке 32 найдено ключевое слово 'цикл' заменено на 'Цикл'
		ИНФОРМАЦИЯ - В строке 32 найдено ключевое слово 'пока' заменено на 'Пока'
		ИНФОРМАЦИЯ - В строке 33 найдено ключевое слово 'прервать' заменено на 'Прервать'
		ИНФОРМАЦИЯ - В строке 34 найдено ключевое слово 'конеццикла' заменено на 'КонецЦикла'
		ИНФОРМАЦИЯ - В строке 38 найдено ключевое слово 'иначеЕсли' заменено на 'ИначеЕсли'
		ИНФОРМАЦИЯ - В строке 39 найдено ключевое слово 'попытка' заменено на 'Попытка'
		ИНФОРМАЦИЯ - В строке 40 найдено ключевое слово 'новый' заменено на 'Новый'
		ИНФОРМАЦИЯ - В строке 41 найдено ключевое слово 'исключение' заменено на 'Исключение'
		ИНФОРМАЦИЯ - В строке 42 найдено ключевое слово 'вызватьИсключение' заменено на 'ВызватьИсключение'
		ИНФОРМАЦИЯ - В строке 43 найдено ключевое слово 'конецпопытки' заменено на 'КонецПопытки'
		ИНФОРМАЦИЯ - В строке 47 найдено ключевое слово 'ТолстыйКлиентОбычноеприложение' заменено на 'ТолстыйКлиентОбычноеПриложение'
		ИНФОРМАЦИЯ - В строке 47 найдено ключевое слово 'толстыйКлиентУправляемоеПриложение' заменено на 'ТолстыйКлиентУправляемоеПриложение'
		ИНФОРМАЦИЯ - В строке 47 найдено ключевое слово 'Тонкийклиент' заменено на 'ТонкийКлиент'
		ИНФОРМАЦИЯ - В строке 47 найдено ключевое слово 'вебклиент' заменено на 'ВебКлиент'
		ИНФОРМАЦИЯ - В строке 47 найдено ключевое слово 'и' заменено на 'И'
		ИНФОРМАЦИЯ - В строке 47 найдено ключевое слово 'не' заменено на 'НЕ'
		ИНФОРМАЦИЯ - В строке 51 найдено ключевое слово 'для' заменено на 'Для'
		ИНФОРМАЦИЯ - В строке 51 найдено ключевое слово 'каждого' заменено на 'Каждого'
		ИНФОРМАЦИЯ - В строке 51 найдено ключевое слово 'из' заменено на 'Из'
		ИНФОРМАЦИЯ - В строке 52 найдено ключевое слово 'выполнить' заменено на 'Выполнить'
		ИНФОРМАЦИЯ - В строке 55 найдено ключевое слово 'по' заменено на 'По'
		ИНФОРМАЦИЯ - В строке 58 найдено ключевое слово 'добавитьОбработчик' заменено на 'ДобавитьОбработчик'
		ИНФОРМАЦИЯ - В строке 58 найдено ключевое слово 'Удалитьобработчик' заменено на 'УдалитьОбработчик'
		ИНФОРМАЦИЯ - В строке 59 найдено ключевое слово 'истина' заменено на 'Истина'
		ИНФОРМАЦИЯ - В строке 59 найдено ключевое слово 'истина' заменено на 'Истина'
		ИНФОРМАЦИЯ - В строке 59 найдено ключевое слово 'истина' заменено на 'Истина'
		ИНФОРМАЦИЯ - В строке 59 найдено ключевое слово 'ложь' заменено на 'Ложь'
		ИНФОРМАЦИЯ - В строке 60 найдено ключевое слово 'конецфункции' заменено на 'КонецФункции'
		ИНФОРМАЦИЯ - В строке 62 найдено ключевое слово '&НасерверебезКонтекста' заменено на '&НаСервереБезКонтекста'
		ИНФОРМАЦИЯ - В строке 68 найдено ключевое слово '&наКлиентеНаСервереБезКонтекста' заменено на '&НаКлиентеНаСервереБезКонтекста'
		ИНФОРМАЦИЯ - В строке 72 найдено ключевое слово '&наКлиентенаСервере' заменено на '&НаКлиентеНаСервере'
		"""