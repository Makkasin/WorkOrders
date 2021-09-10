﻿#Область Печать

Функция ДанныеШапка(ссДок)
	
	Стк = Новый Структура();
	
	Стк.Вставить("Дата",Формат(ссДок.Дата,"ДФ=dd.MM.yyyy"));
	Стк.Вставить("дтМес",Формат(ссДок.Дата,"ДФ='MMMM yyyy'"));
	
	
	Стк.Вставить("Номер",СокрЛП(ссДок.Номер));
	Стк.вставить("ФИООтв",Справочники.ФизическиеЛица.ФИОстр(ссДок.Ответственный,ссДок.Ответственный));
	Стк.Вставить("Организация",ссДок.Организация);
	Стк.Вставить("Контрагент",ссДок.Контрагент.НаименованиеПолное);
	Стк.Вставить("Договор",ссДок.Договор);
	Стк.Вставить("ФИООрг",Справочники.ФизическиеЛица.ФИОстр(ссДок.КонтролерСТК));
	Стк.Вставить("длжОрг",ссДок.КонтролерСТК.должность);
	Стк.Вставить("ФИОКа",СокрЛП(ссДок.Подписант));
	
	Если ЗначениеЗаполнено(Стк.Договор) Тогда
		Стк.Вставить("ЗаголовокДоговор","Договор : ");
	КонецЕСЛИ;
	
	
	//Стк.вставить("АдресОтправителя",Справочники.Контрагенты.ПолучитьЮрАдрес(Стк.Организация));
	//Стк.вставить("АдресПолучателя",Справочники.Контрагенты.ПолучитьЮрАдрес(Стк.Контрагент));
	
	
	Возврат Стк;
	
КонецФункции

Функция Данные(сс)

	Запрос =Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_РеестрыЗаказНаряды.Цена КАК Цена,
	               |	ро_РеестрыЗаказНаряды.ЗаказНаряд КАК ЗаказНаряд,
	               |	ISNULL(СпрИмяКАНом.НаименованиеКА,СпрОбр.Наименование) КАК Оборудование,
	               |	СпрОбр.Диаметр КАК Диаметр,
	               |	СпрОбр.Давление КАК Давление,
	               |	CASE WHEN ДокЗН.НомерОборудованияКор="""" THEN ДокЗН.НомерОборудования ELSE ДокЗН.НомерОборудованияКор END КАК НомерОборудования,
	               |	ДокЗН.Плательщик.Наименование КАК Плательщик,
	               |	ДокЗН.Производитель.Наименование КАК Производитель,
	               |	ДокЗН.Заключение.Наименование КАК Заключение,
	               |	ДокЗН.ДатаИспытания КАК ДатаИспытания,
	               |	ДокЗН.Дата КАК ДатаЗН,
	               |	CASE WHEN ДокЗН.ИнвНомерКор="""" THEN ДокЗН.ИнвНомер ELSE ДокЗН.ИнвНомерКор END КАК ИнвНомер,
	               |	ро_РеестрыЗаказНаряды.НомерЗаказНаряда КАК ЗаказНарядНомер,
	               |	1 КАК Кол,
	               |	ISNULL(СпрИмяКА.НаименованиеКА,СпрОбр.Родитель.Наименование) КАК Группа,
	               |	ро_РеестрыЗаказНаряды.ОписаниеПараметров КАК ОписаниеПараметров
	               |ИЗ
	               |	Документ.ро_Реестры.ЗаказНаряды КАК ро_РеестрыЗаказНаряды
				   |INNER JOIN Документ.ро_Реестры Док ON Док.ссылка = ро_РеестрыЗаказНаряды.ссылка
				   |INNER JOIN Документ.роЗаказНаряд ДокЗН ON ДокЗН.ссылка = ро_РеестрыЗаказНаряды.ЗаказНаряд
				   |
				   |INNER JOIN Справочник.ро_Оборудование СпрОбр ON  (СпрОбр.ссылка = ДокЗН.Оборудование и  ро_РеестрыЗаказНаряды.ппНомерОборудования = 0)
				   |                                             или (СпрОбр.ссылка = ДокЗН.ТипДопОбр    и  ро_РеестрыЗаказНаряды.ппНомерОборудования = 1)
				   |                                             или (СпрОбр.ссылка = ДокЗН.ТипДопОбр1   и  ро_РеестрыЗаказНаряды.ппНомерОборудования = 2)
				   |
	               |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрИмяКА ON СпрИмяКА.ссылка     = СпрОбр.Родитель
				   |                                                                                и СпрИмяКА.Контрагент = Док.контрагент
				   |
	               |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрИмяКАНом ON СпрИмяКАНом.ссылка     = СпрОбр.ссылка
				   |                                                                                   и СпрИмяКАНом.Контрагент = Док.контрагент
	               |LEFT OUTER JOIN Справочник.ро_Заключения СпрЗак ON СпрЗак.ссылка = ДокЗН.Заключение и СпрЗак.БезОплаты = истина
	               |
	               |ГДЕ
	               |	ро_РеестрыЗаказНаряды.Ссылка = &Ссылка
	               |  и СпрЗак.ссылка IS NULL
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	Группа,
	               |	Оборудование";
	
	  Запрос.УстановитьПараметр("Ссылка",сс);
	  
	  Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ДанныеРаботы(сс)

	Запрос =Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_РеестрыРаботы.Цена КАК Цена,
	               |	ро_РеестрыРаботы.ЗаказНаряд КАК ЗаказНаряд,
	               |	ро_РеестрыРаботы.РаботаПоПрайсу КАК РаботаПоПрайсу,
	               |	ро_РеестрыРаботы.Работа КАК Работа,
	               |	ро_РеестрыРаботы.Работа.ЕдиницаИзмерения КАК ЕдИзм,
	               |	ISNULL(СпрИмяКАНом.НаименованиеКА,ДокЗН.Оборудование.Наименование) КАК Оборудование,
	               |	ДокЗН.Оборудование.Диаметр КАК Диаметр,
	               |	ДокЗН.Оборудование.Давление КАК Давление,
	               |	CASE WHEN ДокЗН.НомерОборудованияКор="""" THEN ДокЗН.НомерОборудования ELSE ДокЗН.НомерОборудованияКор END КАК НомерОборудования,
	               |	CASE WHEN ДокЗН.ИнвНомерКор="""" THEN ДокЗН.ИнвНомер ELSE ДокЗН.ИнвНомерКор END КАК ИнвНомер,
	               |	ДокЗН.Номер КАК ЗаказНарядНомер,
	               |	ро_РеестрыРаботы.Количество КАК Количество
	               |ИЗ
	               |	Документ.ро_Реестры.Работы КАК ро_РеестрыРаботы
				   |INNER JOIN Документ.ро_Реестры Док ON Док.ссылка = ро_РеестрыРаботы.ссылка
				   |
				   |INNER JOIN Документ.роЗаказНаряд ДокЗН ON ДокЗН.ссылка = ро_РеестрыРаботы.ЗаказНаряд
	               |
	               |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрИмяКА ON СпрИмяКА.ссылка     = ДокЗН.Оборудование.Родитель
				   |                                                                                и СпрИмяКА.Контрагент = Док.контрагент
				   |
	               |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрИмяКАНом ON СпрИмяКАНом.ссылка     = ДокЗН.Оборудование
				   |                                                                                   и СпрИмяКАНом.Контрагент = Док.контрагент
	               |ГДЕ
	               |	ро_РеестрыРаботы.Ссылка = &Ссылка
	               |
	               |UNION ALL 
	               |
	               |ВЫБРАТЬ
	               |	ро_РеестрыЗаказНаряды.Цена КАК Цена,
	               |	ро_РеестрыЗаказНаряды.ЗаказНаряд КАК ЗаказНаряд,
	               |	ISNULL(СпрИмяКАНом.НаименованиеКА,ДокЗН.Оборудование.Наименование) КАК РаботаПоПрайсу,
	               |	неопределено КАК Работа,
	               |	ДокЗН.Оборудование.ЕдиницаИзмерения КАК ЕдИзм,
	               |	ISNULL(СпрИмяКАНом.НаименованиеКА,ДокЗН.Оборудование.Наименование) КАК Оборудование,
	               |	ДокЗН.Оборудование.Диаметр КАК Диаметр,
	               |	ДокЗН.Оборудование.Давление КАК Давление,
	               |	CASE WHEN ДокЗН.НомерОборудованияКор="""" THEN ДокЗН.НомерОборудования ELSE ДокЗН.НомерОборудованияКор END КАК НомерОборудования,
	               |	CASE WHEN ДокЗН.ИнвНомерКор="""" THEN ДокЗН.ИнвНомер ELSE ДокЗН.ИнвНомерКор END КАК ИнвНомер,
	               |	ДокЗН.Номер КАК ЗаказНарядНомер,
	               |	1 КАК Количество
	               |ИЗ
	               |	Документ.ро_Реестры.ЗаказНаряды КАК ро_РеестрыЗаказНаряды
				   |
				   |INNER JOIN Документ.ро_Реестры Док ON Док.ссылка = ро_РеестрыЗаказНаряды.ссылка
				   |
				   |INNER JOIN Документ.роЗаказНаряд ДокЗН ON ДокЗН.ссылка = ро_РеестрыЗаказНаряды.ЗаказНаряд
	               |
	               |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрИмяКА ON СпрИмяКА.ссылка     = ДокЗН.Оборудование.Родитель
				   |                                                                                и СпрИмяКА.Контрагент = Док.контрагент
				   |
	               |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрИмяКАНом ON СпрИмяКАНом.ссылка     = ДокЗН.Оборудование
				   |                                                                                   и СпрИмяКАНом.Контрагент = Док.контрагент
				   
	               |LEFT OUTER JOIN	Документ.ро_Реестры.Работы КАК ро_РеестрыРаботы ON  ро_РеестрыРаботы.заказНаряд = ро_РеестрыЗаказНаряды.ЗаказНаряд
				   
	               |ГДЕ
	               |	ро_РеестрыЗаказНаряды.Ссылка = &Ссылка
	               | и  ро_РеестрыРаботы.Ссылка IS NULL
	               |
	               |";
	
	  Запрос.УстановитьПараметр("Ссылка",сс);
	  
	  Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ПечатьРеестр(сс) Экспорт
	
	Макет = Документы.ро_Реестры.ПолучитьМакет("Реестр");
	
	ТБл = Данные(сс);
	сткШапка = ДанныеШапка(сс);
	
	Таб = Новый ТабличныйДокумент;
	Таб.КлючПараметровПечати = "роПечатьРеестр";
	Таб.ОриентацияСтраницы=ОриентацияСтраницы.Ландшафт;
	Если Тбл.Количество()=0 ТОгда Возврат Таб; КонецЕсли;
	
	
	Обл = Макет.ПолучитьОбласть("Шапка");
	ОблТаб = Макет.ПолучитьОбласть("ШапкаТаб");
	Обл.Параметры.Заполнить(сткШапка);
	Таб.Вывести(Обл);
	
	
	ОблГр = Макет.ПолучитьОбласть("Группа");
	Обл   = Макет.ПолучитьОбласть("Строка");
	
	МАсОбл = Новый МАссив;
	МасОбл.Добавить(ОблГР);
	МасОбл.Добавить(Обл);
	
	Т = тбл.Скопировать();
	Т.свернуть("Группа,ОписаниеПараметров","Кол,Цена");
	Т.Сортировать("Группа,ОписаниеПараметров");
	Для каждого С из Т Цикл
		облГр.Параметры.Заполнить(С);
		
		Мас = Тбл.НайтиСтроки(Новый Структура("Группа,ОписаниеПараметров",С.Группа,с.ОписаниеПараметров));
		СткНом = Новый Структура("ном",0);
		Для каждого Стр из Мас Цикл
			сткНом.ном=сткНом.Ном+1;
			Обл.Параметры.Заполнить(Стр);
			Обл.Параметры.Заполнить(СткНом);
			Таб.Вывести(Обл);
			Если Таб.ПроверитьВывод(МасОбл)=Ложь Тогда
				Таб.ВывестиГоризонтальныйРазделительСтраниц();
				Таб.Вывести(облТаб);
			КонецЕСЛИ;
		КонецЦикла;
		
		Таб.Вывести(облГр);
		
	КонецЦикла;
	
	Обл = Макет.ПолучитьОбласть("Итого");
	Обл.Параметры.Заполнить(сткШапка);
	Т.свернуть("","Кол,Цена");
	Обл.Параметры.Заполнить(Т[0]);
	
	
	Таб.Вывести(Обл);
	Таб.ТолькоПросмотр = Истина;
	Таб.ОтображатьГруппировки = Ложь;
	Таб.ОтображатьЗаголовки = Ложь;
	Таб.ОтображатьСетку = Ложь;
	
	Возврат Таб;
	
	
	
	
КонецФункции

Функция ПечатьРеестрСвод(сс,ссКА,ИмяКодМакета) Экспорт

	Макет = НайтиМакетРеестра(ссКА,ИмяКодМакета);
	
	МасКол = Справочники.ПечатныеФормы.ПолучитьМассивПараметров(Макет.ПолучитьОбласть("Строка"));
	Если Макет.Области.Найти("Строка1")<>Неопределено Тогда
		пМас = Справочники.ПечатныеФормы.ПолучитьМассивПараметров(Макет.ПолучитьОбласть("Строка1"));
		ДЛя каждого эл из пМас Цикл
			Если масКол.Найти(эл)=Неопределено Тогда
				масКол.Добавить(эл);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли; 
	Если масКол.Найти("кол")=Неопределено Тогда
		масКол.Добавить("кол");
	КонецеСЛИ;
	Если масКол.Найти("цена")=Неопределено Тогда
		масКол.Добавить("цена");
	КонецеСЛИ;
	
	
	СтрСвр = "";
	СтрСврНомОбр = "";
	СткНомОбр = Новый Структура;
	ЕстьНомОбр=Ложь;
	Для каждого эл из МасКол Цикл
		Если нрег(Эл)="кол" или нрег(Эл)="ном" или нрег(Эл)="сумма"  Тогда  Продолжить; КонецЕсли;
		СтрСвр = СтрСвр+","+Эл;
		
		
		Если  нрег(Эл)="номероборудованиясписок"
			или нрег(Эл)="заказнарядномерсписок"  Тогда
			ЕстьНомОбр = Истина;
		ИНаче
			СтрСврНомОбр = СтрСврНомОбр+","+Эл;
			СткНомОбр.Вставить(Эл);
		КонецЕсли;
		
	КонецЦикла;
	СтрСвр 		 = Сред(СтрСвр,2);
	СтрСврНомОбр = Сред(СтрСврНомОбр,2);
	
	сткШапка = ДанныеШапка(сс);
	Тбл = Данные(сс);
	
	минДатаЗН=Дата(2099,1,1);
	Для каждого Стр из Тбл Цикл
		Если стр.ДатаЗН<минДатаЗН Тогда
			минДатаЗН = Стр.ДатаЗН;
		КонецЕСЛИ;
	КонецЦикла;
	сткШапка.Вставить("минДатаЗН",Формат(минДатаЗН,"ДФ=dd.MM.yyyy"));
	
	
	Если  ЕстьНомОбр=Истина Тогда
		
		Тбл.Колонки.Добавить("НомерОборудованияСписок");
		Тбл.Колонки.Добавить("ЗаказНарядНомерСписок");
		
		Т = Тбл.Скопировать(,СтрСврНомОбр);
		Т.Свернуть(СтрСврНомОбр,"");
		Для каждого С из Т Цикл
			ЗаполнитьЗначенияСвойств(СткНомОбр,с);
			Мас = Тбл.НайтиСтроки(СткНомОбр);
			пСтр = "";
			пЗак = "";
			Для каждого Эл из Мас Цикл
				пСтр = пСтр + ", "+СокрлП(эл.НомерОборудования);
				пЗак = пЗак + ", "+СокрлП(эл.ЗаказНарядНомер);
			КонецЦикла;
			пСтр = Сред(пСтр,3);
			пЗак = Сред(пЗак,3);
			
			Для каждого Эл из Мас Цикл
				Эл.НомерОборудованияСписок = пСтр;
				Эл.ЗаказНарядНомерСписок = пЗак;
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЕСлИ;
	
	
	
	Тбл.Свернуть(СтрСвр,"Кол");
	Тбл.Колонки.Добавить("Сумма",Новый ОПисаниеТипов("Число"));
	
	
	Таб = Новый ТабличныйДокумент;
	Таб.КлючПараметровПечати = "роПечатьРеестрСвод";
	Если Тбл.Количество()=0 ТОгда Возврат Таб; КонецЕсли;
	
	МасОбластей = Новый Массив;
	масОбластей.Добавить("");
	Если Макет.Области.Найти("Шапка1")<>Неопределено Тогда
		масОбластей.Добавить("1");
	КонецЕсли;
	
	
	Для каждого элОбл из МасОбластей Цикл
		
		Обл = Макет.ПолучитьОбласть("Шапка"+элОбл);
		Обл.Параметры.Заполнить(сткШапка);
		
		Таб.Вывести(Обл);
		
		Обл   = Макет.ПолучитьОбласть("Строка"+элОбл);
		
		СткНом = Новый Структура("ном",0);
		Для каждого Стр из Тбл Цикл
			Стр.Сумма = Стр.Цена * Стр.Кол;
			
			сткНом.ном=сткНом.Ном+1;
			Обл.Параметры.Заполнить(Стр);
			Обл.Параметры.Заполнить(СткНом);
			Таб.Вывести(Обл);
			
		КонецЦикла;
		
	КонецЦикла;
	
	ОблИтог = Макет.ПолучитьОбласть("Итого");
	ОблИтог.Параметры.Заполнить(сткШапка);
	Тбл.свернуть("","Кол,Сумма");
	ОблИтог.Параметры.Заполнить(Тбл[0]);
	Таб.Вывести(ОблИтог);
	
	Если Макет.Области.Найти("Оборот")<>Неопределено Тогда
		Обл = Макет.ПолучитьОбласть("Оборот");	
		Обл.Параметры.Заполнить(сткШапка);
		Таб.ВывестиГоризонтальныйРазделительСтраниц();
		Таб.Вывести(Обл);
	КонецЕслИ;
	
	
	Таб.ТолькоПросмотр = Истина;
	Таб.ОтображатьГруппировки = Ложь;
	Таб.ОтображатьЗаголовки = Ложь;
	Таб.ОтображатьСетку = Ложь;
	Таб.АвтоМасштаб = Истина;
	
	Возврат Таб;
	
	
КонецФункции	

Функция НайтиМакетРеестра(ссКА,ИмяКодМакета)
	
	
	код = СтрЗаменить(ИмяКодМакета,"кнПечФорм","");
	сс = Справочники.ПечатныеФормы.НайтиПоКоду(код);
	
	текПечФорма = Неопределено;
	Если сс.Пустая()=Ложь Тогда
		текПечФорма = сс;
		
		ДвоичныеДанные = текПечФорма.хрОбработкаПечати.Получить();
		Поток = ДвоичныеДанные.ОткрытьПотокДляЧтения();
		Макет = Новый ТабличныйДокумент;
		Макет.Прочитать(Поток);
		Поток.Закрыть();
		Возврат Макет;
	КонецЕСлИ;
	
	Макет = Справочники.ПечатныеФормы.НайтиПечФормуПоВиду(Перечисления.ВидыДокументовДЛяПечФорм.Реестр,ссКА);
		
	Если Макет<>Неопределено Тогда
		Возврат Макет;
	Иначе
		Возврат  Документы.ро_Реестры.ПолучитьМакет("РеестрСвод");
	КонецЕсли;
	
КонецФункции

Функция ПечатьНакладная(Мас,Макет,ссПечФормы=Неопределено) Экспорт

	Возврат Справочники.ПечатныеФормы.ПечатьНакладная(Мас,Макет,ссПечФормы);
	
КонецФункции	

Функция ПечатьРеестрРабот(сс) Экспорт
	
	Макет = Документы.ро_Реестры.ПолучитьМакет("РеестрРабот");
	
	ТБл = ДанныеРаботы(сс);
	сткШапка = ДанныеШапка(сс);
	
	Таб = Новый ТабличныйДокумент;
	Таб.КлючПараметровПечати = "роПечатьРеестр";
	Таб.ОриентацияСтраницы=ОриентацияСтраницы.Ландшафт;
	Если Тбл.Количество()=0 ТОгда Возврат Таб; КонецЕсли;
	
	
	Обл = Макет.ПолучитьОбласть("Шапка");
	ОблТаб = Макет.ПолучитьОбласть("ШапкаТаб");
	Обл.Параметры.Заполнить(сткШапка);
	Таб.Вывести(Обл);
	
	
	ОблГр = Макет.ПолучитьОбласть("Группа");
	Обл   = Макет.ПолучитьОбласть("Строка");
	
	МАсОбл = Новый МАссив;
	МасОбл.Добавить(ОблГР);
	МасОбл.Добавить(Обл);
	
	Т = тбл.Скопировать();
	Т.свернуть("РаботаПоПрайсу,НомерОборудования,ИнвНомер","Количество,Цена");
	Т.Сортировать("РаботаПоПрайсу,НомерОборудования,ИнвНомер");
	СткНом = Новый Структура("ном,номс",0,0);
	Для каждого С из Т Цикл
		сткНом.ном=сткНом.Ном+1;
		облГр.Параметры.Заполнить(С);
		облГр.Параметры.Заполнить(сткНом);
		Таб.Вывести(облГр);
		
		Мас = Тбл.НайтиСтроки(Новый Структура("РаботаПоПрайсу,НомерОборудования,ИнвНомер",с.РаботаПоПрайсу,с.НомерОборудования,с.ИнвНомер));
		сткНом.номС=0;
		Для каждого Стр из Мас Цикл
			Если Стр.Работа = Неопределено Тогда ПродолжитЬ; КонецЕсли;
			сткНом.номС=сткНом.НомС+1;
			Обл.Параметры.Заполнить(Стр);
			Обл.Параметры.Заполнить(СткНом);
			Таб.Вывести(Обл);
			Если Таб.ПроверитьВывод(МасОбл)=Ложь Тогда
				Таб.ВывестиГоризонтальныйРазделительСтраниц();
				Таб.Вывести(облТаб);
			КонецЕСЛИ;
		КонецЦикла;
		
		
	КонецЦикла;
	
	Обл = Макет.ПолучитьОбласть("Итого");
	Обл.Параметры.Заполнить(сткШапка);
	Т.свернуть("","Количество,Цена");
	Обл.Параметры.Заполнить(Т[0]);
	
	
	Таб.Вывести(Обл);
	Таб.ТолькоПросмотр = Истина;
	Таб.ОтображатьГруппировки = Ложь;
	Таб.ОтображатьЗаголовки = Ложь;
	Таб.ОтображатьСетку = Ложь;
	
	Возврат Таб;
	
	
	
КонецФункции

#КонецОбласти


Функция ПолучитьЦенуИзПрайса(Дт,КА,Обр) Экспорт
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
				   |    ISNULL(Рег.Цена,0) Цена
	               |ИЗ
	               |	Справочник.ро_Оборудование Спр 
				   |LEFT OUTER JOIN РегистрСведений.Прайс.СрезПоследних(&Дт) Рег ON Рег.Контрагент = &КА
				   |                                           и Рег.Оборудование  = Спр.родитель 
				   |                                           и (Рег.ДиаметрОт   <= Спр.Диаметр  или Рег.ДиаметрОт = 0)
				   |                                           и (Рег.ДиаметрДо   >= Спр.Диаметр  или Рег.ДиаметрДо = 0)
				   |                                           и (Рег.ДавлениеОт  <= Спр.Давление или Рег.ДавлениеОт = 0)
				   |                                           и (Рег.ДавлениеДо  >= Спр.Давление или Рег.ДавлениеДо = 0)
				   |WHERE Спр.ссылка = &Обр
	               |";
	
	Запрос.УстановитьПараметр("Дт",Дт);
	Запрос.УстановитьПараметр("КА",КА);
	Запрос.УстановитьПараметр("Обр",Обр);
	
	Выб = Запрос.Выполнить().Выбрать();
	ЕСли Выб.Следующий() ТОгда
		Рез = Выб.Цена;
	Иначе
		Рез =Неопределено ;
	КонецЕСЛИ;
	
	Возврат Рез;
	
КонецФункции