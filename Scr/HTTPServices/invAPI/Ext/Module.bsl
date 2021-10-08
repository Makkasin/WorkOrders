﻿Функция ЗаписатьТБлВТекстовыйФайл(Тбл)
	
		//----
	Таб = новый ТабличныйДокумент;
	а=0;
	Для каждого Кол из Тбл.Колонки Цикл
		а=а+1;
		Таб.область(1,а,1,а).Текст = Кол.Имя;
	КонецЦикла;
	
	нс=1;
	Для каждого Стр из Тбл Цикл
		нс=нс+1;
		а=0;
		Для каждого Кол из Тбл.Колонки Цикл
			а=а+1;
			п = стр[Кол.Имя];
			Если ТипЗнч(п)=Тип("Число") Тогда
				п = Формат(п,"ЧН=0; ЧГ=0");
			КонецЕСли;
			Таб.область(нс,а,нс,а).Текст = п;
		КонецЦикла;
		
		
	КонецЦикла;
	
	ПотокФайла = Новый ПотокВПамяти();
	Таб.Записать(ПотокФайла,ТипФайлаТабличногоДокумента.TXT);
	//Здесь ПотокФайла.Размер() больше нуля, т.е. все в порядке.
	ДвоичныеДанныеФайла = ПотокФайла.ЗакрытьИПолучитьДвоичныеДанные();
		
	
	Возврат ДвоичныеДанныеФайла;


	
КонецФункции

Функция ЗаписатьХранилищеВСтроку(Тбл,ТекДт=Неопределено)
	
	Если ТекДт = Неопределено Тогда
		ТекДТ = ТекущаяДата();
	КонецЕСЛИ;
	
	Стк = Новый структура();
	Для а=1 по ТБл.Колонки.Количество() Цикл
		Кол = ТБл.Колонки[а-1];
		
		Если Найти(Кол.Имя,"GUID") <> 0 Тогда
			п = Кол.Имя;
			Кол.Имя = п+"1";
			ТБл.Колонки.Добавить(п,Новый ОписаниеТипов("Строка"));
			Стк.Вставить(п+"1",п);
		КонецЕСЛИ;
		
	КонеццИклА;
	
	Если Стк.Количество()<>0 Тогда
		Для каждого Стр из ТБл Цикл
			Для каждого эл из Стк Цикл
				Стр[эл.Значение] = СокрЛП(Стр[эл.Ключ].УникальныйИдентификатор());
			Конеццикла;
		КонецЦикла;
		
		Для каждого эл из Стк Цикл
			Тбл.Колонки.Удалить(эл.Ключ);
		Конеццикла;
	КонецЕсли;
	
	Если ТекДт = "ТолькоТбл" Тогда
		Возврат Тбл;
	КонецЕсли;
	
	
	
	Мас = Новый МАссив;
	Мас.Добавить(ТекДТ);
	МАс.ДОбавить(ТБл);
	
	хр = Новый ХранилищеЗначения(Мас,Новый СжатиеДанных(5));
	Возврат XMLСтрока(хр);
	
КонецФункции
			
Функция ПечатьРеализацииПоИД(Тело,КодСостояния)
	
	Стк = XMLзначение(Тип("ХранилищеЗначения"),Тело).Получить();
	
	ссРеа = Документы.ро_Реестры.ПОлучитьСсылку(Стк.ГУИД);
	Если НАйти(ссРеа,"не найден")<>0 ТОгда
		Возврат Неопределено; 
	КонецесЛИ;
	
	Таб = Документы.ро_Реестры.ПечатьРеестр(ссРеа);
	
	
	
	хр = Новый ХранилищеЗначения(Таб);
	Возврат XMLстрока(хр);
	
	
КонецФункции

Функция ПолучитьСправочники(СткПар,КодОтвета)
	
	СткРез = Новый Структура("ТекДт", ТекущаяДата());
	                   
	Запрос = Новый Запрос;
	
	Если СткПар.Свойство("izmDt")=FALSE Тогда
		Запрос.УстановитьПараметр("ДтИзм",Дата(1,1,1));
	ИНаче
		Запрос.УстановитьПараметр("ДтИзм",Дата(СткПар.izmDt));
	КонецеСЛИ;
	
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_ОборудованиеДефектовка.Ссылка КАК GUID,
	               |	ро_ОборудованиеДефектовка.Деталь КАК ДетальGUID,
	               |	ро_ОборудованиеДефектовка.Количество КАК Количество
	               |ИЗ
	               |	Справочник.ро_Оборудование.Дефектовка КАК ро_ОборудованиеДефектовка
	               |WHERE (ро_ОборудованиеДефектовка.Ссылка.ДатаИзменения > &ДтИзм or &ДтИзм = ДатаВремя(1,1,1,0,0,0) )
				   |";
	
	Тбл1 = Запрос.Выполнить().Выгрузить();
	
	
	СткРез.Вставить("Дефектовка",ЗаписатьХранилищеВСтроку(Тбл1,"ТолькоТбл"));
	
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	""ДеталиОборудования"" ВидСпр,               
	               |	ДеталиОборудования.Ссылка КАК GUID,
	               |	ложь ЭтоГруппа,               
	               |	ДеталиОборудования.Код КАК Код,
	               |	ДеталиОборудования.Наименование КАК Наименование,
	               |	ДеталиОборудования.ДатаИзменения КАК ДатаИзменения
	               |ИЗ
	               |	Справочник.ДеталиОборудования КАК ДеталиОборудования
	               |WHERE (ДатаИзменения > &ДтИзм or &ДтИзм = ДатаВремя(1,1,1,0,0,0) )
				   |
				   |UNION ALL
				   |
				   |ВЫБРАТЬ
	               |	""Дефекты"" ВидСпр,               
	               |	Дефекты.Ссылка КАК GUID,
	               |	ложь ЭтоГруппа,               
	               |	Дефекты.Код КАК Код,
	               |	Дефекты.Наименование КАК Наименование,
	               |	Дефекты.ДатаИзменения КАК ДатаИзменения
	               |ИЗ
	               |	Справочник.Дефекты КАК Дефекты
	               |WHERE (ДатаИзменения > &ДтИзм or &ДтИзм = ДатаВремя(1,1,1,0,0,0) )
				   |
				   |UNION ALL
				   |
				   |ВЫБРАТЬ
	               |	""ро_Оборудование"" ВидСпр,               
	               |	ро_Оборудование.Ссылка КАК GUID,
	               |	ро_Оборудование.ЭтоГруппа,               
	               |	ро_Оборудование.Код КАК Код,
	               |	ро_Оборудование.Наименование КАК Наименование,
	               |	ро_Оборудование.ДатаИзменения КАК ДатаИзменения
	               |ИЗ
	               |	Справочник.ро_Оборудование КАК ро_Оборудование
				   |INNER JOIN Справочник.ро_Оборудование.Дефектовка СпрДеф ON СпрДеф.ссылка= ро_Оборудование.ссылка и СпрДеф.номерстроки = 1
	               |WHERE (ДатаИзменения > &ДтИзм or &ДтИзм = ДатаВремя(1,1,1,0,0,0) )
				   |";
				   
	Тбл2 = Запрос.Выполнить().Выгрузить();
	СткРез.Вставить("Прочие",ЗаписатьХранилищеВСтроку(Тбл2,"ТолькоТбл"));
	
				   
	хр = Новый ХранилищеЗначения(СткРез,Новый СжатиеДанных(5));
	Возврат XMLСтрока(хр);

	
КонецФункции

Функция ДвиженияОборудования()
	
	Запрос = Новый ЗапроС;
	Запрос.Текст = "ВЫБРАТЬ
				   |  НачалоПериода(Дата,Месяц) Дата,
				   |  Контрагент,
				   |  Группа,
				   |  SUM(Приход) Приход,
				   |  SUM(Расход) Расход
				   |
				   |
				   |FROM (
				   |ВЫБРАТЬ
	               |	ро_ОтгрузкаЗаказНаряды.Ссылка.Дата КАК Дата,
	               |	ро_ОтгрузкаЗаказНаряды.Ссылка.Контрагент.Наименование КАК Контрагент,
	               |	ро_Оборудование.Родитель.Наименование КАК Группа,
	               |	0 Приход,
	               |	1 Расход
	               |ИЗ
	               |	Документ.ро_Отгрузка.ЗаказНаряды КАК ро_ОтгрузкаЗаказНаряды
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.роЗаказНаряд КАК роЗаказНаряд
	               |		ПО ро_ОтгрузкаЗаказНаряды.ЗаказНаряд = роЗаказНаряд.Ссылка
	               |			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ро_Оборудование КАК ро_Оборудование
	               |			ПО роЗаказНаряд.Оборудование = ро_Оборудование.Ссылка
	               |ГДЕ
	               |	ро_ОтгрузкаЗаказНаряды.Ссылка.ПометкаУдаления = Ложь
				   |
				   |UNION ALL
				   |
				   |ВЫБРАТЬ
	               |	ро_ПриходОборудованияЗаказНаряды.Ссылка.Дата КАК Дата,
	               |	ро_ПриходОборудованияЗаказНаряды.Ссылка.Контрагент.Наименование КАК Контрагент,
	               |	ро_Оборудование.Родитель.Наименование КАК Группа,
	               |	1 Приход,
	               |	0 Расход
	               |ИЗ
	               |	Документ.ро_ПриходОборудования.Оборудования КАК ро_ПриходОборудованияЗаказНаряды
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.роЗаказНаряд КАК роЗаказНаряд
	               |		ПО ро_ПриходОборудованияЗаказНаряды.ДокЗаказНаряд = роЗаказНаряд.Ссылка
	               |			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ро_Оборудование КАК ро_Оборудование
	               |			ПО роЗаказНаряд.Оборудование = ро_Оборудование.Ссылка
	               |ГДЕ
	               |	ро_ПриходОборудованияЗаказНаряды.Ссылка.ПометкаУдаления = Ложь
				   |) WWW
				   |
				   |GROUP BY
				   |  НачалоПериода(Дата,Месяц),
				   |  Контрагент,
				   |  Группа
				   |
				   |
				   |";
	
	
	  Возврат ЗаписатьТБлВТекстовыйФайл(Запрос.Выполнить().Выгрузить());
	
	
КонецФункции

Функция ПолучитьОстатки()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ОстатокРООстатки.ЗаказНаряд КАК ЗаказНарядСс,
	               |	ОстатокРООстатки.ЗаказНаряд.Номер КАК ЗаказНаряд,
	               |	ОстатокРООстатки.ЗаказНаряд.Дата КАК ЗаказНарядДата,
	               |	ОстатокРООстатки.ЗаказНаряд.Оборудование.Наименование КАК ОборудованиеСтр,
	               |	ОстатокРООстатки.ЗаказНаряд.Контрагент.Наименование КАК Контрагент,
	               |	ОстатокРООстатки.ЗаказНаряд.НомерОборудования КАК НомерОборудования
	               |ИЗ
	               |	РегистрНакопления.ОстатокРО.Остатки КАК ОстатокРООстатки";
	
	
	ТБл = Запрос.Выполнить().Выгрузить();
	
	текДТ = ТекущаяДАта();
	Тбл.Колонки.Добавить("ЗаказНарядИд");
	Тбл.Колонки.Добавить("дтСинхро");
	
	Для каждого Стр из Тбл Цикл
		Стр.ЗаказНарядИд = Стр.ЗаказНарядСс.УникальныйИдентификатор();
		Стр.дтСинхро = текДт;
	КонецЦикла;
	
	Возврат XMLстрока(Новый ХранилищеЗначения(Тбл,Новый СжатиеДанных(5)));
	
	
КонецФункции

Функция ЗагрузитьОтгрузку(тело,кодОтвета)
	Стк = XMLзначение(Тип("ХранилищеЗначения"),Тело).Получить();
	
	ссДок = Документы.ро_Отгрузка.ПОлучитьСсылку(Стк.ГУИД);
	Если НАйти(ссДок,"не найден")<>0 ТОгда
		обк = Документы.ро_Отгрузка.СоздатьДокумент(); 
		обк.дата = Стк.Дата;
		Обк.Контрагент = Справочники.Контрагенты.НайтиПоНаименованию(стк.контрагент,Истина);
		Обк.Организация = обк.Контрагент.ОрганизацияИсполгитель;
	КонецесЛИ;
	
	Для каждого эл из Стк.масЗН Цикл
		
		ссЗН = Документы.роЗаказНаряд.ПолучитьСсылку(эл);
		Если Найти(ссЗН,"не найден")<>0 Тогда
			Продолжить;
		КонецеслИ;
		
		Если Обк.ЗаказНаряды.Найти(ссЗН)<>Неопределено Тогда Продолжить; КонецЕСЛИ;
		
		новСтр = Обк.ЗаказНаряды.Добавить();
		новСтр.ЗаказНаряд = ссЗН;
		
	КонецЦикла;
	
	Обк.Записать();
	
	Возврат Истина;
	
	
КонецФункции

Функция ЗагрузитьСосВРаботе(тело,кодОтвета)
	Стк = XMLзначение(Тип("ХранилищеЗначения"),Тело).Получить();
	
	
	Для каждого эл из Стк.масЗН Цикл
		
		ссЗН = Документы.роЗаказНаряд.ПолучитьСсылку(эл);
		Если Найти(ссЗН,"не найден")<>0 Тогда
			Продолжить;
		КонецеслИ;
		
		Обк = ссЗН.ПолучитьОбъект();
		Обк.Статус = Справочники.ро_Статусы.ОчередьСТК;
		Обк.Записать();
		
	КонецЦикла;
	
	
	Возврат Истина;
	
	
КонецФункции

Функция GETGET(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Метод = ВРЕГ(Запрос.ПараметрыURL["ИмяМетода"]);
	
	СткПар = Новый Структура;
	Для каждого Эл из Запрос.ПараметрыЗапроса Цикл
		СткПар.Вставить(Эл.Ключ,Эл.Значение);	
	КонецЦикла;
	
	ЕСли Метод = "PRNDOC" Тогда
		Результат = ПечатьРеализацииПоИД(Запрос.ПолучитьТелоКакСтроку(),Ответ.КодСостояния);	
	ИНачеЕСли Метод = "GETSPR" Тогда
		Результат = ПолучитьСправочники(СткПар,Ответ.КодСостояния);	
	ИНачеЕСли Метод = "GETOST" Тогда
		Результат = ПолучитьОстатки();	
	ИНачеЕсли Метод = "DVGOBR" Тогда
		Результат = ДвиженияОборудования();
		Ответ.УстановитьТелоИзДвоичныхДанных(Результат);
		Возврат Ответ;
	ИНачеЕСли Метод = "PUSHOTG" Тогда
		Результат = ЗагрузитьОтгрузку(Запрос.ПолучитьТелоКакСтроку(),Ответ.КодСостояния);	
	ИНачеЕСли Метод = "PUSHSOSRAB" Тогда
		Результат = ЗагрузитьСосВРаботе(Запрос.ПолучитьТелоКакСтроку(),Ответ.КодСостояния);	
	ИНачеЕСли Метод = "TEST" ТОгда
		Результат = СтрокаСоединенияИнформационнойБазы();
	ИНаче
		Запрос.КодСостояния = 404;
		Результат = "Метод "+Метод+" не обнаружен";
	КонецеСли;
	
	Ответ.УстановитьТелоИзСтроки(Результат);
	Возврат Ответ;
	
КонецФункции

Функция GETPOST(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	
	Метод = ВРЕГ(Запрос.ПараметрыURL["ИмяМетода"]);

	
	Возврат Ответ;
КонецФункции

