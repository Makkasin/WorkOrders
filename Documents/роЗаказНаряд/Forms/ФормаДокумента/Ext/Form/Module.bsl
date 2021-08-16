﻿&НаКлиенте
Перем СсылкаДефектГоден;

&НаСервереБезКонтекста
Функция РодителиОбр(ТекОбр)
	
	Стк = новый Структура("Род1,Род2");
	Если ЗначениеЗаполнено(ТекОбр.Родитель) = Ложь ТОгда Возврат Стк; КонецЕСЛИ;
	Стк.Род1 = ТекОбр.Родитель; 
	Стк.Род2 = Стк.Род1.Родитель; 
	//п = ТекОбр.Родитель.ПолноеНаименование(); 
	//П = СтрЗаменить(п,"/",Символы.ПС);
	
	Возврат Стк;
	
КонецФункции

&НаСервере
Процедура ОборудованиеПриИзмененииНаСервере()
	Справочники.ПечатныеФормы.ДобавитьКнопкиПечати(ЭтаФорма,Объект.Оборудование,,,Объект.Контрагент);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьФорму(Элемент=Неопределено)
	
	пОбр = Объект.Оборудование;
	Если ЗначениеЗаполнено(Объект.ОборудованиеКор) Тогда
		пОбр = Объект.ОборудованиеКор;
	КонецЕсли;
	
	СткРод = РодителиОбр(пОбр);
	оборудованиеРод1 = СткРод.род1;
	оборудованиеРод2 = СткРод.род2;
	
	Если Объект.ВидДопОбр = 1 Тогда
		Элементы.стрДопОбр.Видимость=Истина;
		Элементы.стрДопОбр.Заголовок="Доп.оборудование: Лубрикатор";
	ИНачеЕсли Объект.ВидДопОбр = 2 Тогда
		Элементы.стрДопОбр.Видимость=Истина;
		Элементы.стрДопОбр.Заголовок="Доп.оборудование: Задвижка";

	Иначе
		Элементы.стрДопОбр.Видимость=Ложь;
	КонецЕСлИ;
	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ОбновитьФорму();
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПечатьКарточкиНаСервере(сс)
	// Вставить содержимое обработчика.
	Возврат Документы.роЗаказНаряд.ПечатьКарточки(сс);
КонецФункции

&НаКлиенте
Процедура ПечатьКарточки(Команда)
	Таб = ПечатьКарточкиНаСервере(Объект.Ссылка);
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,"Карточки"),,Новый УникальныйИдентификатор());

	//Таб.Показать();
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если ЗначениеЗаполнено(Объект.Ссылка)=ЛОжь Тогда
		Объект.Статус = Справочники.ро_Статусы.ВРаботе;
	КонецЕсли;
	ОборудованиеПриИзмененииНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСткПодписантов(ссОбр)
	
	Стк = Новый Структура;
	
	эл = Справочники.ПечатныеФормы.НайтиЭлементСПечФормами(ссОбр);
	Тбл = эл.Подписи.выгрузить();
	ном = 0;
	ДЛя каждого Стр из Тбл Цикл
		ном = Ном +1;
		Стк.вставить("Подписант"+ном,Стр.ФизЛицо);
	КонецЦикла;
	
	Возврат Стк;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьПодписантовСТК()
	Стк = ПолучитьСткПодписантов(Объект.Оборудование);
	
	Если Стк.свойство("Подписант1")=Истина Тогда
		Стк.свойство("Подписант1",Объект.Испытатель);
	КонецЕСЛИ;
	Если Стк.свойство("Подписант2")=Истина Тогда
		Стк.свойство("Подписант2",Объект.Мастер);
	КонецЕСЛИ;
	Если Стк.свойство("Подписант3")=Истина Тогда
		Стк.свойство("Подписант3",Объект.Контролер);
	КонецЕСЛИ;
	
КонецПроцедуры

&НаКлиенте
Процедура ОборудованиеПриИзменении(Элемент)
	ОборудованиеПриИзмененииНаСервере();
	ЗаполнитьПодписантовСТК();
	ОбновитьФорму();
КонецПроцедуры

&НасервереБезКонтекста
Функция ПечатныеФормыНаСервере(ссДок,Имя,Контрагент)
	Если ЗначениеЗаполнено(ссДОк)=Ложь Тогда Возврат Неопределено; КонецЕсли; 
	
		Возврат Справочники.ПечатныеФормы.ПечатьПоКодуФормы(ссДок,Имя,Контрагент);
	
КонецФункции

&НаКлиенте
Процедура Печать(Команда) Экспорт
	
	Если ОбщийКлиент.ПроверкаМодифицированности(ЭтаФорма,команда)=Ложь Тогда Возврат; КонецЕсли;
	
	ИмяКодМакета = СокрЛП(Команда.Имя);
	Если ИмяКодМакета = "ПечатьДефектовка" Тогда
		ПечатьДефектовка(Команда);Возврат;
	ИначеЕсли Объект.ДатаИспытания = Дата(1,1,1) Тогда
		ПоказатьПредупреждение(,"Не указана дата испытания");
		Возврат;
	КонецЕсли;
	
	Таб = ПечатныеФормыНаСервере(Объект.Ссылка,ИмяКодМакета,Объект.Контрагент);
	Если Таб = Неопределено Тогда Возврат; КонецЕсли;
	
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,ИмяКодМакета),,Новый УникальныйИдентификатор());
	
КонецПроцедуры


&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	ЭтаФорма.ТолькоПросмотр = Истина;
	ЦенаСтрока = ""+Документы.ро_Реестры.ПолучитьЦенуИзПрайса(Объект.Дата,ОБъект.Контрагент,Объект.Оборудование)+" руб.";
	тблДокументы.Загрузить(ЗаполнитьТблДОкументы(Объект.Ссылка));
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЗаполнитьТблДОкументы(сс)
	
	Запрос = Новый ЗАпрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	РаботаРО.Период КАК Период,
	               |	РаботаРО.Регистратор КАК Регистратор
	               |ИЗ
	               |	РегистрНакопления.РаботаРО КАК РаботаРО
				   |ГДЕ  ЗаказНаряд = &сс
				   |
				   |UNION ALL
				   |
				   |ВЫБРАТЬ
				   |	ОстатокРО.Период КАК Период,
				   |	ОстатокРО.Регистратор КАК Регистратор
				   |ИЗ
				   |	РегистрНакопления.ОстатокРО КАК ОстатокРО
				   |ГДЕ  ЗаказНаряд = &сс
				   |";
	Запрос.УстановитьПараметр("сс",Сс);
	ТБл = Запрос.Выполнить().Выгрузить();
	ТБл.Сортировать("Период");
	
	Возврат ТБл;
	
	
КонецФункции


&НаКлиенте
Процедура Разблокировать(Команда)
	ЭтаФорма.ТолькоПросмотр = Ложь;
	Элементы.ФормаРазблокировать.Видимость = Ложь;
КонецПроцедуры


&НаСервереБезКонтекста
Функция ЗаполнитьДефектовкуНаСервере(ссобр)
	Возврат Справочники.ро_Оборудование.ПолучитьДеталиДефектовки(ссОбр.Родитель);
КонецФункции


&НаКлиенте
Процедура ЗаполнитьДефектовку(Команда)
	
	Если ОБъект.Дефектовка.Количество()<>0 Тогда
		оо = Новый ОписаниеОповещения("ЗаполнитьДефектовкуВопрос",этотОбъект);
		ПоказатьВопрос(оо,"Текущие строки дефектовки будут очищены. Продолжить?",РежимДиалогаВопрос.ДаНет);
	ИНАче
		ЗаполнитьДефектовкуАЛГА();
	КонецЕсли;
	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДефектовкуВопрос(Рез,параметры) Экспорт
	Если Рез<>КодВозвратаДиалога.Да ТОгда Возврат; КонецеСЛИ;
	ЗаполнитьДефектовкуАЛГА();
КонецПроцедуры


&НаКлиенте
Процедура ЗаполнитьДефектовкуАЛГА()
	Мас = ЗаполнитьДефектовкуНаСервере(Объект.Оборудование);
	
	ОБъект.Дефектовка.Очистить();
	Для каждого эл из МАс Цикл
		новСтр = объект.Дефектовка.Добавить();
		ЗаполнитьЗначенияСвойств(новстр,Эл);
	КонецЦИкла;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСсылкаДефектГоден()
	Возврат Справочники.Дефекты.Годен;
КонецФункции

&НаКлиенте
Процедура ДефектовкаГоденПриИзменении(Элемент)
	
	Если СсылкаДефектГоден=Неопределено Тогда
		СсылкаДефектГоден = ПолучитьСсылкаДефектГоден();
	КонецЕсли;
	
	Стр = Элементы.Дефектовка.текущиеДанные;
	Стр.Годен = Истина;
	Стр.Реставрация = ложь;
	Стр.Изготовление = ложь;
	Стр.Покупка = ложь;
	Стр.Дефект = СсылкаДефектГоден;
	
КонецПроцедуры

&НаКлиенте
Процедура ДефектовкаНеГоденПриИзменении(Элемент)
	Если СсылкаДефектГоден=Неопределено Тогда
		СсылкаДефектГоден = ПолучитьСсылкаДефектГоден();
	КонецЕсли;
	
	имя = СтрЗаменить(Элемент.Имя,"Дефектовка","");
	
	Стр = Элементы.Дефектовка.текущиеДанные;
	Стр.Годен = ложь;
	Стр.Реставрация = ложь;
	Стр.Изготовление = ложь;
	Стр.Покупка = ложь;
	Стр[Имя] = Истина;
	
	Если Стр.Дефект = СсылкаДефектГоден Тогда
		Стр.Дефект = Неопределено;
	КонецЕСЛИ;
	
КонецПроцедуры

&НаКлиенте
Процедура ДефектовкаДефектыПриИзменении(Элемент)
	Если СсылкаДефектГоден=Неопределено Тогда
		СсылкаДефектГоден = ПолучитьСсылкаДефектГоден();
	КонецЕсли;
	
	Стр = Элементы.Дефектовка.текущиеДанные;
	Если Стр.Дефект = СсылкаДефектГоден Тогда
		ДефектовкаГоденПриИзменении(Элемент);
	ИНачеЕсли Стр.Годен = Истина Тогда
		ДефектовкаНеГоденПриИзменении(Новый Структура("Имя","Изготовление"));
	КонецЕСЛИ;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПечатьДефектовкаНаСервере(сс)
	Возврат Документы.роЗаказНаряд.ПечатьДефектовка(сс);
КонецФункции

&НаКлиенте
Процедура ПечатьДефектовка(Команда)
	
	Если ОбщийКлиент.ПроверкаМодифицированности(ЭтаФорма,команда)=Ложь Тогда Возврат; КонецЕсли;
	
	Если Объект.Дефектовка.Количество()=0 Тогда
		ЗаполнитьДефектовкуАЛГА();
		ЭтаФорма.Записать();
	КонецЕсли;
	
	Таб = ПечатьДефектовкаНаСервере(Объект.Ссылка);
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,"Деф.вед."),,Новый УникальныйИдентификатор());
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если Объект.ВключитьВРеестр = Истина и Объект.ДатаИспытания=Дата(1,1,1) ТОгда
		Сообщить("Не указана дата испытания!");
		отказ = Истина;
	КонецЕСЛИ;
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьВРеестрПриИзменении(Элемент)
		ЭтаФорма.Записать();
КонецПроцедуры

&НаКлиенте
Процедура ОборудованиеКоррПриИзменении(Элемент)
	ОбновитьФорму();
КонецПроцедуры

&НаКлиенте
Процедура тблДокументыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ТекСтр = Элементы.тблДокументы.ТекущиеДанные;
	Если ТекСтр = Неопределено ТОгда Возврат; КонецЕСлИ;
	ПоказатьЗначение(,ТекСтр.Регистратор);
КонецПроцедуры

&НаСервереБезКонтекста
Функция ОбновитьРаботыНаСервере(ссКА,ссОбр)
	
	Возврат РегистрыСведений.РегистрЦен.ПолучитьМассивРаботПоПРайсу(ссКА,ссОбр); 
	
КонецФункции

&НаКлиенте
Процедура ОбновитьРаботы(Команда)
	Мас = ОбновитьРаботыНаСервере(Объект.Контрагент,Объект.Оборудование);
	масВып = новый Массив;
	Для каждого Стр из Объект.Работы Цикл
		Если стр.выполнено = Истина Тогда
			масВып.Добавить(Стр.Работа);
		КонецЕСлИ;
	КонецЦикла;
	
	Объект.Работы.Очистить();
	Для каждого эл из Мас Цикл
		новСтр = Объект.Работы.Добавить();
		новстр.Работа = эл;
		
		новСтр.выполнено =  масВып.Найти(эл)<>Неопределено;
	КонецЦикла;
	
КонецПроцедуры
