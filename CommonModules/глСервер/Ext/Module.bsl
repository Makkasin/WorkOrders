﻿Процедура ПроставитьПунктПогрузки(ссКА,Пункт) Экспорт
	Если ЗначениеЗаполнено(ссКА) = Ложь Тогда Возврат; КонецЕсли;
	Если ЗначениеЗаполнено(ссКА.ПунктПогрузки) ТОгда Возврат; КонецЕСлИ;
	
	Обк = ссКА.ПолучитьОбъект();
	Обк.ПунктПогрузки = Пункт;
	Обк.Записать();
	
КонецПроцедуры

Функция СткПолучитьСоединение() Экспорт
	
	СткСоединение = новый Структура("Сервер,порт,Логин,Пароль");
	СткСоединение.Сервер = "91.203.11.2";
	СткСоединение.Порт = 53780;
	СткСоединение.Логин = "SERV";
	СткСоединение.Пароль = "1!qqqqqq";
	
	Возврат СткСоединение;

КонецФункции

Функция ПолучитьURLсимвол(Бук)
	Возврат   "."+КодироватьСТроку(Бук,СпособКодированияСтроки.КодировкаURL)+".";
КонецФункции

Функция ПросклонятьРП(ПеремФИО) Экспорт
	
	 ФИО = ПеремФИО;
	 зн = ФИО;
	 Соо =новый Соответствие;
	 Соо.Вставить("/");
	 Соо.Вставить("\");
	 Соо.Вставить("(");
	 Соо.Вставить(")");
	 
	 Для каждого эл из Соо Цикл
		 Если Найти(ФИО,Эл.Ключ)<>0 Тогда
			 п = ПолучитьURLсимвол(Эл.Ключ);
			 Соо.Вставить(Эл.Ключ,п);
			 ФИО = СтрЗаменить(ФИО,Эл.Ключ,п);	 
		 КонецЕСли;
	 КонецЦикла;
	 
	
	 пМас = ПолучитьСклоненияСтроки(ФИО,"ПЛ=Мужской","ПД=Родительный");
	 Если пМас.Количество()<>0 ТОгда
		 зн = пМас[0];
		 
		 Для каждого эл из Соо Цикл
			 Если Эл.Значение = Неопределено Тогда Продолжить; КонецЕсли;
			 зн = СтрЗаменить(зн,Эл.Значение,Эл.Ключ);	 
		 КонецЦикла;
		 
	 КонецЕсли;
	 
	 Возврат зн;       //  ПолучитьСклоненияСтроки("Зам.начальника ПРЦб%2Fо","ПЛ=Мужской","ПД=Родительный");
	
КонецФункции

