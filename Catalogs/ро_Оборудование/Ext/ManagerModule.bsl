﻿
Функция ПолучитьЧислоИзСтр(стр,Прямой)
	
	Стр = СтрЗаменить(Стр,",",".");
	
	Рез = "";
	был46 = Ложь;
	колПромахов=0;
	
	Если Прямой Тогда
		ДЛя а=1 по СтрДлина(стр) Цикл
			п = Сред(Стр,а,1);
			Если  КодСимвола(п,1) = 46 Тогда
				Если был46 Тогда
					прервать;
				КонецеСЛИ;
				Рез =  Рез + п;
				был46 = Истина;
			ИНачеЕсли (КодСимвола(п,1) >= 48 и КодСимвола(п,1)<= 57)   Тогда
				Рез =  Рез + п;
			ИНаче
				прервать;
			КонецЕсли;
		КонецЦикла;
		
	ИНаче
		ДЛя а=-СтрДлина(стр) по -1 Цикл
			п = Сред(Стр,-а,1);
			Если  КодСимвола(п,1) = 46 Тогда
				Если был46 Тогда
					прервать;
				КонецеСЛИ;
				Рез = п + Рез;
				был46 = Истина;
			ИНачеЕсли (КодСимвола(п,1) >= 48 и КодСимвола(п,1)<= 57)   Тогда
				Рез = п + Рез;
			ИначеЕсли колПромахов=0 и а=-СтрДлина(стр) Тогда
				колПромахов=колПромахов+1;
			ИНаче
				прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЕСЛИ;
	
	Если Рез = "" ТОгда
		Возврат Неопределено;
	ИНАче
		Возврат Число(Рез);
	КонецЕсли;
	
КонецФункции

Функция РазобратьНаименование(Имя) Экспорт
	пСтр = СтрЗаменить(нрег(Имя),"-"," ");
	пСтр = Стрзаменить(пСтр,"*"," * ");
	пСтр = Стрзаменить(пСтр,"х"," * ");
	пСтр = Стрзаменить(пСтр,"x"," * ");
	пСтр = СтрЗаменить(пСтр," ",Символы.ПС);
	
	Для  а=2 по СтрЧислоСтрок(пстр)-1 Цикл
		п = СтрПолучитьстроку(пстр,а);
		Если п="*" Тогда
			Ч1 = ПолучитьЧислоИзСтр(СтрПолучитьСтроку(пСтр,а-1),Ложь);
			Если ч1 <> Неопределено ТОгда
				Ч2 = ПолучитьЧислоИзСтр(СтрПолучитьСтроку(пСтр,а+1),Истина);
				Если Ч2<>Неопределено Тогда
					Возврат Новый Структура("Ч1,Ч2",Ч1,Ч2);
				КонецЕСЛИ;
			КонецЕсли;
			
		КонецеслИ;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

Функция ПолучитьДеталиДефектовки(сс) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_ОборудованиеДефектовка.Деталь КАК Деталь,
	               |	ро_ОборудованиеДефектовка.Количество КАК Количество,
	               |	ро_ОборудованиеДефектовка.Дефект КАК Дефект,
	               |	ро_ОборудованиеДефектовка.Годен КАК Годен,
	               |	ро_ОборудованиеДефектовка.Реставрация КАК Реставрация,
	               |	ро_ОборудованиеДефектовка.Изготовление КАК Изготовление,
	               |	ро_ОборудованиеДефектовка.Покупка КАК Покупка
	               |ИЗ
	               |	Справочник.ро_Оборудование.Дефектовка КАК ро_ОборудованиеДефектовка
	               |ГДЕ
	               |	ро_ОборудованиеДефектовка.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("ссылка",сс);
	
	Тбл = Запрос.Выполнить().Выгрузить();
	
	Мас = новый Массив;
	Для каждого Стр из Тбл Цикл
		Стк = Новый Структура;
		Для каждого Кол из Тбл.Колонки Цикл
			Стк.Вставить(Кол.имя,Стр[Кол.имя]);
		КонецЦикла;
		Мас.добавить(Стк);
	КонецЦикла;
	
	Возврат Мас;
	
КонецФункции

Процедура ЗаполнитьДефектовку(сс) Экспорт
	
	Объект = сс.ПолучитьОбъект();
	Мас = ПолучитьДеталиДефектовки(Объект.Оборудование.Родитель);
	
	ОБъект.Дефектовка.Очистить();
	Для каждого эл из МАс Цикл
		новСтр = объект.Дефектовка.Добавить();
		ЗаполнитьЗначенияСвойств(новстр,Эл);
	КонецЦИкла;
	
	Объект.Записать();
	
	
КонецПроцедуры