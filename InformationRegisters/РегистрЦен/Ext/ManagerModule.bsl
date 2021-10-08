﻿Функция ПолучитьМассивРаботПоПРайсу(ссКА,ссОбр) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_РаботыПоПрайсуРаботы.Работа 		КАК Работа,
	               |	ро_РаботыПоПрайсуРаботы.Количество  КАК Количество,
	               |	ро_РаботыПоПрайсуРаботы.Цена   		КАК Цена
	               |ИЗ
	               |	РегистрСведений.РегистрЦен КАК РегистрЦен
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ро_РаботыПоПрайсу.Работы КАК ро_РаботыПоПрайсуРаботы
	               |		ПО РегистрЦен.Работа = ро_РаботыПоПрайсуРаботы.Ссылка
	               |ГДЕ
	               |	РегистрЦен.Контрагент = &Контрагент
	               |	И РегистрЦен.Оборудование = &Оборудование";
	Запрос.УстановитьПараметр("Контрагент",ссКА);
	Запрос.УстановитьПараметр("Оборудование",ссОбр);
	
	 
	Тбл =  Запрос.Выполнить().Выгрузить();
	
	Мас = Новый Массив;
	Для каждого Стр из Тбл Цикл
		Мас.Добавить(Новый Структура("Работа,Цена,Количество",Стр.Работа,Стр.Цена,Стр.Количество));
	КонецЦикла;
	
	Возврат Мас;
	
КонецФункции

Функция ПолучитьЦену(ссКА,ссОбр) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Контрагент",ссКА);
	Запрос.УстановитьПараметр("Оборудование",ссОбр);
	Запрос.Текст = "ВЫБРАТЬ
	               |	РегистрЦен.Цена КАК Цена
	               |ИЗ
	               |	РегистрСведений.РегистрЦен КАК РегистрЦен
	               |		
				   |WHERE РегистрЦен.Работа = Значение(Справочник.ро_РаботыПоПрайсу.ПустаяСсылка)
	               |	И РегистрЦен.Контрагент = &Контрагент
	               |	И РегистрЦен.Оборудование = &Оборудование";
				   	
	Выб = Запрос.Выполнить().Выбрать();
	Если Выб.Следующий() Тогда
		Возврат Выб.Цена;
	ИНаче
		Возврат 0;
	КонецЕсли;
	
	
КонецФункции
