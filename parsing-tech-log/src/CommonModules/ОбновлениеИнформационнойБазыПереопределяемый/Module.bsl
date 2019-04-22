///////////////////////////////////////////////////////////////////////////////
// ИНТЕРФЕЙСНАЯ ЧАСТЬ ПЕРЕОПРЕДЕЛЯЕМОГО МОДУЛЯ

// Возвращает список процедур-обработчиков обновления ИБ для всех поддерживаемых версий ИБ.
//
// Пример добавления процедуры-обработчика в список:
//    Обработчик = Обработчики.Добавить();
//    Обработчик.Версия = "1.0.0.0";
//    Обработчик.Процедура = "ОбновлениеИБ.ПерейтиНаВерсию_1_0_0_0";
//
// Вызывается перед началом обновления данных ИБ.
//
Функция ОбработчикиОбновления() Экспорт
	
	Обработчики = ОбновлениеИнформационнойБазы.НоваяТаблицаОбработчиковОбновления();
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "0.0.0.0";
	Обработчик.Процедура = "ОбновлениеИнформационнойБазыПереопределяемый.НачальнаяИнициализация";

	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "2.0.2.0";
	Обработчик.Процедура = "ОбновлениеИнформационнойБазыПереопределяемый.ПолучитьСоздатьПользователейПоПользователямИБ";
	
	Возврат Обработчики;
	
КонецФункции

// Вызывается при подготовке табличного документа с описанием изменений системы.
//
// Параметры:
//   Макет - ТабличныйДокумент - описание обновлений.
//   
// См. также общий макет ОписаниеИзмененийСистемы.
//
Процедура ПриПодготовкеМакетаОписанияОбновлений(Знач Макет) Экспорт
	
КонецПроцедуры	

// Вызывается после завершении обновления данных ИБ.
// 
// Параметры:
//   ПредыдущаяВерсияИБ     - Строка - версия ИБ до обновления. "0.0.0.0" для "пустой" ИБ.
//   ТекущаяВерсияИБ        - Строка - версия ИБ после обновления.
//   ВыполненныеОбработчики - ДеревоЗначений - список выполненных процедур-обработчиков
//                                             обновления, сгруппированных по номеру версии.
//  Итерирование по выполненным обработчикам:
//		Для Каждого Версия Из ВыполненныеОбработчики.Строки Цикл
//	
//			Если Версия.Версия = "*" Тогда
//				группа обработчиков, которые выполняются всегда
//			Иначе
//				группа обработчиков, которые выполняются для определенной версии 
//			КонецЕсли;
//	
//			Для Каждого Обработчик Из Версия.Строки Цикл
//				...
//			КонецЦикла;
//	
//		КонецЦикла;
//
//   ВыводитьОписаниеОбновлений - Булево -	если Истина, то выводить форму с описанием 
//											обновлений.
// 
Процедура ПослеОбновления(Знач ПредыдущаяВерсияИБ, Знач ТекущаяВерсияИБ, 
	Знач ВыполненныеОбработчики, ВыводитьОписаниеОбновлений) Экспорт
	
	Для Каждого Версия Из ВыполненныеОбработчики.Строки Цикл
		
		Для Каждого Версия Из ВыполненныеОбработчики.Строки Цикл
			
			Если Версия.Версия = "*" Тогда
				
			Иначе
				
			КонецЕсли;
			
			Для Каждого Обработчик Из Версия.Строки Цикл
				
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

#Область НачальнаяИнициализация

// начальная инициализация
Процедура НачальнаяИнициализация() Экспорт
	
	// обновляем идентификаторы метаданных
	ЕстьИзменения = Ложь;
	ЕстьУдаленные = Ложь;
	ТолькоПроверка = Ложь;	
	Справочники.ИдентификаторыОбъектовМетаданных.ВыполнитьОбновлениеДанных(ЕстьИзменения,ЕстьУдаленные,ТолькоПроверка);

КонецПроцедуры

#КонецОбласти


#Область ОбработчикиОбновлений

// создадим пользователей по пользователям ИБ
Процедура ПолучитьСоздатьПользователейПоПользователямИБ() Экспорт
	
	МассивПользователейИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	
	Если МассивПользователейИБ.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	СоответствиеПользователейПользователямИБ = новый Соответствие();
	
	// получим существующих пользователей базы
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Пользователи.Ссылка,
	|	Пользователи.ИдентификаторПользователяИБ
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СоответствиеПользователейПользователямИБ.Вставить(Выборка.ИдентификаторПользователяИБ,Выборка.Ссылка);
	КонецЦикла;
	
	Для каждого ПользовательИБ из МассивПользователейИБ Цикл
		Если НЕ СоответствиеПользователейПользователямИБ.Получить(ПользовательИБ.УникальныйИдентификатор)=Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		// создаем если не нашли
		Пользователь = Справочники.Пользователи.СоздатьЭлемент();
		Пользователь.Наименование = ПользовательИБ.ПолноеИмя;
		Пользователь.НаименованиеСокращенное = ПользовательИБ.Имя;
		Пользователь.ПользовательОС = ПользовательИБ.ПользовательОС;
		Пользователь.АутентификацияОС = ПользовательИБ.АутентификацияОС;
		Пользователь.АутентификацияСтандартная = ПользовательИБ.АутентификацияСтандартная;
		Пользователь.Недействителен = ПользовательИБ.АутентификацияОС И ПользовательИБ.АутентификацияСтандартная;
		Пользователь.ПоказыватьВСпискеВыбора = ПользовательИБ.ПоказыватьВСпискеВыбора;
		Пользователь.ЗапрещеноИзменятьПароль = ПользовательИБ.ЗапрещеноИзменятьПароль;
		Пользователь.ИдентификаторПользователяИБ = ПользовательИБ.УникальныйИдентификатор;
		
		Если ПользовательИБ.РежимЗапуска=РежимЗапускаКлиентскогоПриложения.Авто Тогда
			Пользователь.РежимЗапуска=Перечисления.РежимЗапускаКлиентскогоПриложения.Авто;
		ИначеЕсли ПользовательИБ.РежимЗапуска=РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение Тогда
			Пользователь.РежимЗапуска=Перечисления.РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение;
		Иначе
			Пользователь.РежимЗапуска=Перечисления.РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение;
		КонецЕсли;
			
		Попытка
			Если ПользовательИБ.ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях = Истина Тогда
				Пользователь.ЗащитаОтОпасныхДействий = Истина;	
			КонецЕсли;
		Исключение
		КонецПопытки;
					
		Попытка
			Пользователь.ОбменДанными.Загрузка = Истина;
			Пользователь.Записать();
		Исключение
			ЗаписьЖурналаРегистрации("Обновление",УровеньЖурналаРегистрации.Ошибка,Неопределено,Неопределено,ОписаниеОшибки());
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры 

#КонецОбласти