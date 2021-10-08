﻿
Функция ПолучитьЦифры(Стр)
	
	Рез="";
	ДЛя а=1 по СтрДлина(Стр) Цикл
		п = Сред(Стр,а,1);
		ЕСли НАйти("0123456789",п)<>0 ТОгда
			Рез = рез+п;
		ИНАчеЕсли Рез<>"" Тогда 
			Прервать; 
		КонецЕСЛИ;
		
	КонецЦикла;
	
	Возврат Рез;
	
КонецФункции

Процедура ПередЗаписью(Отказ)
	
	Наименование = ""+СокрЛП(ТС)+" "+СокрЛП(ГосНомер)+" "+ВодительФИО;
	
	Код = ПолучитьЦифры(ГосНомер);
	Если Код="" ТОгда
		Сообщить("Не указан гос.номер");
		Отказ = Истина;
	КонецЕсЛИ;
	
КонецПроцедуры
