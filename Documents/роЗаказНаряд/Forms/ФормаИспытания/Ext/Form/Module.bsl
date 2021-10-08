﻿&НаКлиенте
Перем кэшСоо;

&НаСервере
Функция ПечатьИСменаСтатусаНаСервере()
	
	Стк = Новый Структура("ДатаИспытания,ВыявленныеДефекты,Заключение,Испытатель,Мастер,Контролер,КонтролерДеф,ЗаказНаряд,Производитель,ДатаИзготовления,ОписаниеБрака");
	ЗаполнитьЗначенияСвойств(Стк,ЭтаФорма);
	ХранилищеВариантовОтчетов.Сохранить(ЭтаФорма.ИмяФормы,,Стк,,ИмяПользователя());
	
	Таб = Новый ТабличныйДокумент;
	Для каждого Стр из тблОборудование Цикл
		
		ЗаполнитьЗначенияСвойств(Стк,Стр);
		Документы.роЗаказНаряд.ОбновитьДанныеДокумента(Стк.ЗаказНаряд,Стк,Справочники.ро_Статусы.ВРаботе,Справочники.ро_Статусы.Готово);
		пТаб = Справочники.ПечатныеФормы.ПечатьПоКодуФормы(Стк.ЗаказНаряд,"000000006",Стк.ЗаказНаряд.контрагент);
		Таб.Вывести(пТаб);
		Таб.ВывестиГоризонтальныйРазделительСтраниц();
	КонецЦикла;
	
	Возврат Таб;
	
КонецФункции

&НаКлиенте
Процедура ПечатьИСменаСтатуса(Команда)
	Таб = ПечатьИСменаСтатусаНаСервере();
	//Таб.Показать();
	Если Таб = Неопределено Тогда Возврат; КонецЕсли;
	
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,"ОТК"),,Новый УникальныйИдентификатор());
КонецПроцедуры

&НаСервере
Функция ПечатьДефВедомостиНаСервере()
	
	Таб = Новый ТабличныйДокумент;
	Для каждого Стр из тблОборудование Цикл
		
		Если Стр.ЗаказНаряд.Дефектовка.Количество()=0 ТОгда
			Справочники.ро_Оборудование.ЗаполнитьДефектовку(Стр.ЗаказНаряд);
		КонецЕСЛИ;
		
		пТаб = Документы.роЗаказНаряд.ПечатьДефектовка(Стр.ЗаказНаряд);
		Таб.Вывести(пТаб);
		Таб.ВывестиГоризонтальныйРазделительСтраниц();
		
	КонецЦикла;
	
	Возврат Таб;
	
КонецФункции

&НаКлиенте
Процедура ПечатьДефектныеВедомости(Команда)
	Таб = ПечатьДефВедомостиНаСервере();
	//Таб.Показать();
	Если Таб = Неопределено Тогда Возврат; КонецЕсли;
	
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,"ОТК"),,Новый УникальныйИдентификатор());
КонецПроцедуры


&НаСервереБезКонтекста
Процедура КЭШ(соо)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	роЗаказНаряд.Ссылка КАК Ссылка,
	               |	роЗаказНаряд.НомерОборудования КАК НомерОборудования
	               |ИЗ
	               |	Документ.роЗаказНаряд КАК роЗаказНаряд
	               |ГДЕ
	               |	роЗаказНаряд.Статус = Значение(Справочник.ро_Статусы.ВРаботе) 
				   |  и роЗаказНаряд.НомерОборудования<>""""
				   |
				   |UNION ALL
				   |
				   |ВЫБРАТЬ
	               |	роЗаказНаряд.Ссылка КАК Ссылка,
	               |	роЗаказНаряд.Номер КАК НомерОборудования
	               |ИЗ
	               |	Документ.роЗаказНаряд КАК роЗаказНаряд
	               |ГДЕ
	               |	роЗаказНаряд.Статус = Значение(Справочник.ро_Статусы.ВРаботе) 
				   |
				   |";
	
	Тбл =Запрос.Выполнить().Выгрузить();
	Соо.Очистить();
	
	Для каждого Стр из Тбл Цикл
		Соо.Вставить(СокрЛП(Стр.НомерОборудования),Стр.ссылка);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура тблОборудованиеОборудованиеАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ВыборПоНомеру(Текст,ДанныеВыбора);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборПоНомеру(Текст,ДанныеВыбора)
	п = СокрЛП(Текст);
	Если п="" Тогда Возврат; КонецЕСЛИ;
	длСтр = СтрДлина(п);
	
	кол = 0;
	Для каждого эл из кэшСоо Цикл
		Если Лев(эл.ключ,длСтр)=п или Прав(эл.ключ,длСтр)=п Тогда
			Если ДанныеВыбора = Неопределено Тогда
				 ДанныеВыбора = Новый СписокЗначений;
			КонецЕслИ;
			ДанныеВыбора.Добавить(эл.Значение,Эл.ключ);	
			кол=кол+1;
			Если кол=5 ТОгда прервать; КонецЕСлИ;
		КонецЕСЛи;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	кэшСоо = Новый Соответствие;
	КЭШ(кэшСоо);
КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Стк = ХранилищеВариантовОтчетов.Загрузить(ЭтаФорма.ИмяФормы,,,ИмяПользователя());
	Если ТипЗнч(Стк) <> Тип("Структура") ТОгда Возврат; КонецЕсли;
	ЗаполнитьЗначенияСвойств(ЭтаФорма,Стк);
КонецПроцедуры

&НаКлиенте
Процедура тблОборудованиеОборудованиеОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ВыборПоНомеру(Текст,ДанныеВыбора);
КонецПроцедуры



