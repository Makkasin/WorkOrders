﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Если ЗначениеЗаполнено(Ответственный) = Ложь Тогда
		Ответственный = ПараметрыСеанса.ТекущийПользователь;
	КонецЕСЛИ;
	Если ЗначениеЗаполнено(Организация) = Ложь Тогда
		Организация = Константы.ОсновнаяОрганизация.Получить();
	КонецЕСЛИ;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Т = Оборудования.Выгрузить(,"ИдентификаторСкладаR3");
	Т.свернуть("ИдентификаторСкладаR3","");
	Стр = "";
	Для каждого С из Т ЦИкл
		Стр = Стр+С.ИдентификаторСкладаR3+" ";
	КонецЦИкла;
	Если СокрЛП(Стр) = "" Тогда
		стрИдентификаторСкладаR3 = СокрЛП(ПунктПогрузки);
	Иначе
		стрИдентификаторСкладаR3 = СокрЛП(Стр);
	КонецЕсли;
	
	КоличествоПозиций =  Оборудования.Количество();
	
КонецПроцедуры


Процедура ПроверитьРеквизитыЗаказНаряда(сс)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_ПриходОборудованияОборудования.ДокЗаказНаряд КАК ДокЗаказНаряд,
	               |	ро_ПриходОборудованияОборудования.Оборудование КАК Оборудование,
	               |	ро_ПриходОборудованияОборудования.НомерОборудования КАК НомерОборудования,
	               |	ро_ПриходОборудованияОборудования.ИнвНомер КАК ИнвНомер,
	               |	ро_ПриходОборудованияОборудования.ОборудованиеПримечание КАК ОборудованиеПримечание,
	               |	ро_ПриходОборудованияОборудования.Плательщик КАК Плательщик,
	               |	ро_ПриходОборудованияОборудования.Ссылка.Контрагент КАК Контрагент,
	               |	ро_ПриходОборудованияОборудования.Ссылка.НомерТТНвходящий КАК НомерТТНвходящий,
	               |	ро_ПриходОборудованияОборудования.масса КАК масса,
	               |	CASE WHEN ро_ПриходОборудованияОборудования.ИдентификаторСкладаR3 = Значение(Справочник.ро_ИдентификаторСкладаЗаказчика.ПустаяСсылка)
				   |         THEN ро_ПриходОборудованияОборудования.Ссылка.ПунктПогрузки
				   |         ELSE ро_ПриходОборудованияОборудования.ИдентификаторСкладаR3
				   |         END КАК ИдентификаторСкладаR3
	               |ИЗ
	               |	Документ.ро_ПриходОборудования.Оборудования КАК ро_ПриходОборудованияОборудования
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.роЗаказНаряд КАК роЗаказНаряд
	               |		ПО ро_ПриходОборудованияОборудования.ДокЗаказНаряд = роЗаказНаряд.Ссылка
	               |ГДЕ
	               |	ро_ПриходОборудованияОборудования.Ссылка = &Ссылка
	               |	И  (
				   |         ро_ПриходОборудованияОборудования.Оборудование <> роЗаказНаряд.Оборудование
	               |	  or ро_ПриходОборудованияОборудования.НомерОборудования <> роЗаказНаряд.НомерОборудования
	               |	  or ро_ПриходОборудованияОборудования.ИнвНомер <> роЗаказНаряд.ИнвНомер
	               |	  or ро_ПриходОборудованияОборудования.Плательщик <> роЗаказНаряд.Плательщик
	               |	  or ро_ПриходОборудованияОборудования.ссылка.Контрагент <> роЗаказНаряд.Контрагент
	               |	  or ро_ПриходОборудованияОборудования.ссылка.НомерТТНвходящий <> роЗаказНаряд.НомерТТНвходящий
	               |	  or ро_ПриходОборудованияОборудования.ИдентификаторСкладаR3 <> роЗаказНаряд.ИдентификаторСкладаR3
	               |	  or ро_ПриходОборудованияОборудования.ОборудованиеПримечание <> роЗаказНаряд.ОборудованиеПримечание
	               |	  or ро_ПриходОборудованияОборудования.масса <> роЗаказНаряд.масса
	               |	  or (роЗаказНаряд.Статус = &ПредСтатус)
				   |     )
				   |";
	Запрос.УстановитьПараметр("ссылка",сс);
	Запрос.УстановитьПараметр("ПредСтатус",Справочники.ро_Статусы.ПустаяСсылка());
	Тбл = Запрос.Выполнить().Выгрузить();
	Для каждого Стр из Тбл Цикл
		Документы.роЗаказНаряд.ОбновитьДанныеДокумента(Стр.ДокЗаказНаряд,Стр,Справочники.ро_Статусы.ПустаяСсылка(),Справочники.ро_Статусы.ВРаботе);
	КонецЦикла;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если Проведен=Ложь Тогда Возврат; КонецЕсли;
	
	Есть = Ложь;
	Для каждого Стр из Оборудования Цикл
		Если ЗначениеЗаполнено(Стр.ДокЗаказНаряд) =Ложь Тогда
			Стр.ДокЗаказНаряд = Документы.роЗаказНаряд.ДокументСоздатьПоПараметрам(Стр,Ссылка,Справочники.ро_Статусы.ПустаяСсылка(),Справочники.ро_Статусы.ВРаботе);
			есть=Истина;
		КонецеслИ;
	КонецЦикла;
	
	Если Есть Тогда 
		Записать(); 
	КонецЕсЛИ;
	
	ПроверитьРеквизитыЗаказНаряда(Ссылка);
	
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Движения.ОстатокРО.Записать();
	//Если Дата < Дата(2020,12,30) Тогда Возврат; КонецЕсли;
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_ОтгрузкаЗаказНаряды.ДокЗаказНаряд КАК ЗаказНаряд,
	               |	ро_ОтгрузкаЗаказНаряды.Ссылка.Дата КАК Период,
	               |	1 КАК Кол
	               |ИЗ
	               |	Документ.ро_ПриходОборудования.Оборудования КАК ро_ОтгрузкаЗаказНаряды
	               |ГДЕ
	               |	ро_ОтгрузкаЗаказНаряды.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("ссылка",Ссылка);
	ТБл = Запрос.Выполнить().Выгрузить();
	
	Движения.ОстатокРО.Загрузить(Тбл);
	Движения.ОстатокРО.Записать();
	
КонецПроцедуры
