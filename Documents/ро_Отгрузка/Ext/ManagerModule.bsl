﻿Функция ДанныеДляПечати(ссМас,НуженКодR3=Ложь,НуженСкладR3=Ложь,НуженИнвНомер=Ложь,ссПечФормы=Неопределено) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	роЗаказНаряд.Номер КАК НомерЗаказа0,
	               |	CASE WHEN роЗаказНаряд.НомерОборудования="""" THEN роЗаказНаряд.Номер ELSE роЗаказНаряд.НомерОборудования END КАК НомерОборудования0,
	               |	роЗаказНаряд.ОборудованиеПримечание КАК ОборудованиеПримечание,
				   //|	роЗаказНаряд.Оборудование.Код КАК ОборудованиеКод,
	               |	CASE WHEN &НуженКодR3=true    THEN роЗаказНаряд.Оборудование.КодR3 ELSE 0 END КАК КодR3,
	               |	CASE WHEN &НуженСкладR3=true  THEN роЗаказНаряд.ИдентификаторСкладаR3 ELSE 0 END КАК ИдентификаторСкладаR3,
	               |	CASE WHEN &НуженИнвНомер=true THEN роЗаказНаряд.ИнвНомер ELSE 0 END КАК ИнвНомер,
	               |	CASE WHEN роЗаказНаряд.Плательщик = Значение(Справочник.Контрагенты.ПустаяСсылка) 
				   |         THEN ДокОтг.ссылка.Контрагент.НаименованиеДляТТН 
				   |         ELSE роЗаказНаряд.Плательщик.НаименованиеДляТТН 
				   |         END КАК Плательщик,
	               |	роЗаказНаряд.Заключение.ТекстВТТН КАК ТекстВТТН,
	               |	роЗаказНаряд.Масса КАК Масса,
	               |	ДокОтг.ссылка.Контрагент КАК Контрагент,
	               |	ДокОтг.ссылка.Подписант КАК каФИО,
	               |	ДокОтг.ссылка.ПодписантДолжность КАК каДлж,
	               |	ДокОтг.ссылка.Дата КАК ДатаДок,
	               |	ДокОтг.ссылка.Номер КАК Номер,
	               |	ДокОтг.ссылка.ТС КАК ТС,
	               |	ДокОтг.ссылка.ГосНомер КАК ГосНомер,
	               |	ДокОтг.ссылка.ВодительФИО КАК ВодительФИО,
	               |	ДокОтг.ссылка.КонтролерСТК.Наименование КАК КонтролерСТК,
	               |	ДокОтг.ссылка.КонтролерСТК.Должность    КАК длжКонтролерСТК,
	               |	ДокОтг.ссылка.Ответственный.Наименование КАК Ответственный,
	               |	роЗаказНаряд.Оборудование.Наименование КАК ОборудованиеНаименование,
				   |    1 Количество,
	               |	роЗаказНаряд.Оборудование.ЕдиницаИзмерения КАК ЕдИзм
	               |ИЗ
				   |   Документ.ро_Отгрузка.ЗаказНаряды ДокОтг
	               |INNER JOIN 	Документ.роЗаказНаряд КАК роЗаказНаряд ON докОтг.ЗаказНаряд = роЗаказНаряд.ссылка
	               |ГДЕ
	               |	ДокОтг.Ссылка в (&Ссылка)";
	
	Запрос.УстановитьПараметр("ссылка",ссМас);
	Запрос.УстановитьПараметр("НуженКодR3",НуженКодR3);
	Запрос.УстановитьПараметр("НуженСкладR3",НуженСкладR3);
	Запрос.УстановитьПараметр("НуженИнвНомер",НуженИнвНомер);
	
	Если ТипЗнч(ссМас) = Тип("ДокументСсылка.ро_ПриходОборудования") Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"Документ.ро_Отгрузка.ЗаказНаряды","Документ.ро_ПриходОборудования.Оборудования");
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"докОтг.ЗаказНаряд","докОтг.ДокЗаказНаряд");
	КонецЕсли;
	
	Если ссПечФормы<>Неопределено Тогда
		а=0;
		Для каждого стрФлт из ссПечФормы.ФильтрЗапроса Цикл
			а=а+1;
			Запрос.Текст = Запрос.Текст + СтрЗаменить(нрег(стрФлт.СтрокаФильтра),"&зн","&зн"+а);
			Запрос.УстановитьПараметр("зн"+а,стрФлт.ЗнФильтра);
		КонецЦикла;
	КонецЕсли;
	
	Тбл = запрос.Выполнить().Выгрузить();
	ТБл.Колонки.Добавить("НомерОборудования");
	ТБл.Колонки.Добавить("НомерЗаказа");
	
	
	Т = Тбл.Скопировать(,"ОборудованиеНаименование,КодR3,ИдентификаторСкладаR3,Плательщик,ТекстВТТН,ОборудованиеПримечание");
	Т.Свернуть("ОборудованиеНаименование,КодR3,ИдентификаторСкладаR3,Плательщик,ТекстВТТН,ОборудованиеПримечание","");
	Для каждого С из Т Цикл
		Мас = Тбл.НайтиСтроки(Новый Структура("ОборудованиеНаименование,КодR3,ИдентификаторСкладаR3,Плательщик,ТекстВТТН,ОборудованиеПримечание",с.ОборудованиеНаименование,с.КодR3,с.ИдентификаторСкладаR3,с.Плательщик,с.ТекстВТТН,с.ОборудованиеПримечание));
		пСтр = "";
		пЗак = "";
		Для каждого Эл из Мас Цикл
			пСтр = пСтр + ","+СокрЛП(эл.НомерОборудования0);
			пЗак = пЗак + ","+СокрЛП(эл.НомерЗаказа0);
		КонецЦикла;
		пСтр = Сред(пСтр,2);
		пЗак = Сред(пЗак,2);
		
		Если СокрЛП(С.ТекстВТТН)<>"" Тогда
			пСтр = ""+С.ТекстВТТН+": "+пСтр;
		КонецЕсли;
		
		Для каждого Эл из Мас Цикл
			Эл.НомерОборудования = пСтр;
			Эл.НомерЗаказа = пЗак;
		КонецЦикла;
		
	КонецЦикла;
	
	стрСвр = "";
	ДЛя каждого Кол из ТБл.Колонки Цикл
		Если Найти(",номероборудования0,номерзаказа0,количество,",","+нрег(кол.имя)+",")<>0 Тогда Продолжить; КонецЕСлИ;
		стрСвр = СтрСвр +","+Кол.Имя;
	КонецЦикла;
	
	Тбл.свернуть(Сред(Стрсвр,2),"Количество");
	
	
	ТБл.Колонки.Добавить("Дата");
	ТБл.Колонки.Добавить("ДатаМес");
	ТБл.Колонки.Добавить("каФИОРП");
	ТБл.Колонки.Добавить("КонтролерСТКРП");
	Для каждого Стр из Тбл Цикл
		стр.Дата = Формат(Стр.ДатаДок,"ДФ=dd.MM.yyyy");
		стр.ДатаМес = Формат(Стр.ДатаДок,"ДФ='dd MMMM yyyy'");
		
		Стр.КонтролерСТК = СПравочники.ФизическиеЛица.ФИОстр(Стр.КонтролерСТК);
		Стр.КонтролерСТКРП = глСервер.ПросклонятьРП(Стр.КонтролерСТК);
		
		Стр.Ответственный = СПравочники.ФизическиеЛица.ФИОстр(Стр.Ответственный);
		
		Стр.каФИО = СПравочники.ФизическиеЛица.ФИОстр(Стр.каФИО);
		Стр.каФИОРП = глСервер.ПросклонятьРП(Стр.каФИО);
		прервать;
	КонецЦикла;
	
	
	
	Возврат Тбл;
	
	
КонецФункции

Функция ПечатьНакладнаяOLD(Мас,Макет,ссПечФормы=Неопределено) Экспорт
	
	НуженКодR3    = Ложь; тКодR3    = НРЕГ("КодR3");
	НуженСкладR3  = Ложь; тСкладR3  = НРЕГ("ИдентификаторСкладаR3");
	НуженИнвНомер = Ложь; тИнвНомер = НРЕГ("ИнвНомер");
	
	пТ = Новый ТабличныйДокумент;
	Обл = Макет.ПолучитьОбласть("Строка");
	пТ.ВставитьОбласть(Обл.Область(1,1,обл.ВысотаТаблицы,Обл.ширинаТаблицы));
	Для а=1 по пТ.ширинаТаблицы Цикл
		
		Если нрег(пТ.Область(1,а,1,а).текст)      = тКодR3 Тогда
			НуженКодR3 = Истина;
		ИначеЕсли нрег(пТ.Область(1,а,1,а).текст) = тСкладR3 Тогда
			НуженСкладR3 = Истина;
		ИначеЕсли нрег(пТ.Область(1,а,1,а).текст) = тИнвНомер Тогда
			НуженИнвНомер = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	
	
	ТБл = ДанныеДляПечати(Мас,НуженКодR3,НуженСкладR3,НуженИнвНомер,ссПечФормы);
	Таб = Новый ТабличныйДокумент;
	Таб.КлючПараметровПечати = "роПечатьНакладная";
	Если Тбл.Количество()=0 ТОгда Возврат Таб; КонецЕсли;
	
	
	Обл = Макет.ПолучитьОбласть("Шапка");
	Обл.Параметры.Заполнить(Тбл[0]);
	Таб.Вывести(Обл);
	
	
	Обл = Макет.ПолучитьОбласть("Строка");
	
	СткНом = Новый Структура("ном",0);
	Для каждого Стр из Тбл Цикл
		сткНом.ном=сткНом.Ном+1;
		Обл.Параметры.Заполнить(Стр);
		Обл.Параметры.Заполнить(СткНом);
		Таб.Вывести(Обл);
	КонецЦикла;
	
	Обл = Макет.ПолучитьОбласть("Подвал");
	СткНом.Вставить("итКол",Тбл.Итог("Количество"));
	
	Обл.Параметры.Заполнить(Тбл[0]);
	Обл.Параметры.Заполнить(СткНом);
	
	Таб.Вывести(Обл);
	Таб.ТолькоПросмотр = Истина;
	Таб.ОтображатьГруппировки = Ложь;
	Таб.ОтображатьЗаголовки = Ложь;
	Таб.ОтображатьСетку = Ложь;
	
	Возврат Таб;
	
	
	
	
КонецФункции

Функция ПечатьНакладная(Мас,Макет,ссПечФормы=Неопределено) Экспорт

	Возврат Справочники.ПечатныеФормы.ПечатьНакладная(Мас,Макет,ссПечФормы);
	
КонецФункции	
	
#Область ТТН

Функция ДанныеШапка(ссДок,ЦепочкаКА=Ложь)
	Запрос = новый Запрос;
	
	Запрос.Текст = "
	|	
    |ВЫБРАТЬ
	|	ро_Отгрузка.Контрагент КАК Контрагент,
	|	CASE WHEN &ИндПост = TRUE THEN ро_Отгрузка.ПунктПогрузки ELSE ро_Отгрузка.ПунктРазгрузки END КАК ПунктПогрузки,
	|	ISNULL(Тбл1.КонтрагентПосредник,ро_Отгрузка.Организация) Организация,
	|	ISNULL(Тбл1.ПунктПогрузкиПосредник,CASE WHEN &ИндПост = TRUE THEN ро_Отгрузка.ПунктРазгрузки ELSE ро_Отгрузка.ПунктПогрузки END) ПунктРазгрузки,
	|   1 индСорт
	|INTO врКА0																	  
	|ИЗ  Документ.ро_Отгрузка КАК ро_Отгрузка
	|LEFT OUTER JOIN Справочник.Контрагенты.ЦепочкаПоставки      КАК Тбл1 ON Тбл1.ссылка = ро_Отгрузка.Контрагент
	|																	   и Тбл1.НомерСтроки = 1  и &ЦепочкаКА = TRUE
	|
	|ГДЕ ро_Отгрузка.ссылка = &сс
	|
	|UNION ALL
	|
	|ВЫБРАТЬ
	|	Тбл1.КонтрагентПосредник КАК Контрагент,
	|	Тбл1.ПунктПогрузкиПосредник КАК ПунктПогрузки,
	|	ISNULL(Тбл2.КонтрагентПосредник,ро_Отгрузка.Организация) Организация,
	|	ISNULL(Тбл2.ПунктПогрузкиПосредник,CASE WHEN &ИндПост = TRUE THEN ро_Отгрузка.ПунктРазгрузки ELSE ро_Отгрузка.ПунктПогрузки END) ПунктРазгрузки,
	|   1+Тбл1.номерстроки индСорт
	|ИЗ  Документ.ро_Отгрузка КАК ро_Отгрузка
	|INNER JOIN Справочник.Контрагенты.ЦепочкаПоставки      КАК Тбл1 ON Тбл1.ссылка = ро_Отгрузка.Контрагент
	|LEFT OUTER JOIN Справочник.Контрагенты.ЦепочкаПоставки КАК Тбл2 ON Тбл2.ссылка = Тбл1.ссылка 
	|																 и Тбл2.номерСтроки = Тбл1.номерстроки+1
	|ГДЕ ро_Отгрузка.ссылка = &сс и &ЦепочкаКА = TRUE	
	| ;
	//У поступления и отгрузки меняем роль контрагента
	|SELECT
	| CASE WHEN &ИндПост = TRUE THEN Организация    ELSE Контрагент     END Контрагент,
	| CASE WHEN &ИндПост = TRUE THEN ПунктПогрузки  ELSE ПунктРазгрузки END ПунктПогрузки,
	| CASE WHEN &ИндПост = TRUE THEN Контрагент     ELSE Организация    END Организация,
	| CASE WHEN &ИндПост = TRUE THEN ПунктРазгрузки ELSE ПунктПогрузки  END ПунктРазгрузки,
	| CASE WHEN &ИндПост = TRUE THEN индСорт        ELSE -индСорт       END индСорт
	| 
	|INTO врКА
	|FROM врКА0
	| ;
	| ВЫБРАТЬ                                         
	               |	ро_Отгрузка.Номер КАК Номер,
	               |	ро_Отгрузка.Дата КАК ДатаВремяПогрузки,
	               |	спрКА.ссылка  КАК Контрагент,
	               |	спрОрг.ссылка КАК Организация,
	               |	спрОрг.НаименованиеПолное КАК Отправитель,
	               |	спрКА.НаименованиеПолное КАК Получатель,
	               |	ро_Отгрузка.Контрагент.НомерСтрокиМакетаТТН КАК НомерСтрокиМакетаТТН,
				   |	СпрПП.НаименованиеПолное КАК СкладОтправитель,
				   |	СпрПР.НаименованиеПолное КАК СкладПолучатель,
				   |	СпрПР.Адрес КАК СкладПолучательАдрес,
				   |    КонтрагентыКонтактнаяИнформацияКА.Представление АдресПолучателя,
				   |    КонтрагентыКонтактнаяИнформацияОрг.Представление АдресОтправителя,
	               |	ро_Отгрузка.НомерПЛ КАК НомерПЛ,
	               |	ро_Отгрузка.ДатаПЛ КАК ДатаПЛ,
	               |	ро_Отгрузка.ТС КАК ТС,
	               |	ро_Отгрузка.ГосНомер КАК ГосНомер,
	               |	ро_Отгрузка.ВодительФИО КАК ВодительФИО,
	               |	ро_Отгрузка.Перевозчик КАК Перевозчик,
	               |	ро_Отгрузка.АдресПеревозчика КАК АдресПеревозчика,
	               |	ро_Отгрузка.ТелефоныПеревозчика КАК ТелефоныПеревозчика,
	               |	ро_Отгрузка.СопроводительныеДокументы КАК СопроводительныеДокументы,
	               |	ро_Отгрузка.Ответственный.ФизЛицо.Наименование КАК ФизЛицо,
	               |	ро_Отгрузка.Ответственный.Наименование КАК Ответственный,
	               |	ро_Отгрузка.Ответственный.Должность КАК длжОтв,
	               |	ро_Отгрузка.Ответственный.Телефон КАК ОтветственныйТелефон,
	               |	ро_Отгрузка.ВесТТН КАК массаГруза,
	               |	ро_Отгрузка.КоличествоМестТТН КАК колМест,
	               |	ро_Отгрузка.Упаковка КАК Упаковка,
	               |	ро_Отгрузка.Плательщик КАК Плательщик
				   |
	               |ИЗ
	               |	Документ.ро_Отгрузка КАК ро_Отгрузка
				   |INNER JOIN врКА тблКА ON TRUE
				   |LEFT OUTER JOIN Справочник.ПунктыПогрузки СпрПР  ON СпрПР.ссылка = тблКА.ПунктРазгрузки
				   |LEFT OUTER JOIN Справочник.Контрагенты СпрКА  ON СпрКА.ссылка = CASE WHEN СпрПР.Контрагент = Значение(Справочник.Контрагенты.ПустаяСсылка) 
				   |																	 THEN тблКА.Контрагент
				   |																	 ELSE СпрПР.Контрагент
				   |																	 END 
				   |LEFT OUTER JOIN Справочник.КОнтрагенты СпрОрг ON СпрОрг.ссылка = тблКА.Организация
				   |LEFT OUTER JOIN Справочник.ПунктыПогрузки СпрПП  ON СпрПП.ссылка = тблКА.ПунктПогрузки
				   |LEFT OUTER JOIN Справочник.Контрагенты.КонтактнаяИнформация КАК КонтрагентыКонтактнаяИнформацияКА  ON КонтрагентыКонтактнаяИнформацияКА.ссылка  = СпрКА.ссылка
				   |                                                                                                    И КонтрагентыКонтактнаяИнформацияКА.Вид = ""Юридический адрес""
				   |LEFT OUTER JOIN Справочник.Контрагенты.КонтактнаяИнформация КАК КонтрагентыКонтактнаяИнформацияОрг ON КонтрагентыКонтактнаяИнформацияОрг.ссылка = тблКА.Организация
				   |                                    				                                                И КонтрагентыКонтактнаяИнформацияОрг.Вид = ""Юридический адрес""
				   |
				   |
	               |ГДЕ
	               |	ро_Отгрузка.Ссылка = &сс
				   |
				   |ORDER BY индСорт
				   |";
				   
				   
	Запрос.УстановитьПараметр("сс",ссДок);
	Запрос.УстановитьПараметр("ЦепочкаКА",ЦепочкаКА);
	Запрос.УстановитьПараметр("индПост",ТипЗнч(ссДок)=Тип("ДокументСсылка.ро_ПриходОборудования"));
	
	Если ТипЗнч(ссДок) = Тип("ДокументСсылка.ро_ПриходОборудования") Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"Документ.ро_Отгрузка","Документ.ро_ПриходОборудования");
	КонецЕсли;
	
	ТБл = Запрос.Выполнить().Выгрузить();
	Стк = Новый Структура;
	Для каждого Кол из Тбл.Колонки Цикл
		Стк.Вставить(Кол.Имя);
	КонецЦикла;
	
	ЗаполнитьЗначенияСвойств(Стк,Тбл[0]);
	
	Стк.Вставить("Дата",Формат(Стк.ДатаВремяПогрузки,"ДФ=dd.MM.yyyy"));
	Стк.Вставить("ДатаПЛ",Формат(Стк.ДатаПЛ,"ДФ=dd.MM.yyyy"));
	Стк.Вставить("НомерПЛ",?(СокрЛП(Стк.НомерПЛ)="","б/н",СокрЛП(Стк.НомерПЛ)));
	Стк.вставить("ФИООтв",Справочники.ФизическиеЛица.ФИОстр(Стк.ФизЛицо,Стк.Ответственный));
	Стк.вставить("ДлжФИОТелОтв",Стк.длжОтв+" "+Стк.ФИОотв+" "+Стк.ОтветственныйТелефон);
	
	Стк.вставить("ТСиГосНомер",Стк.ТС+" "+Стк.ГосНомер);
	
	
	//Запрос.Текст = "ВЫБРАТЬ
	//               |	ро_ОтгрузкаЗаказНаряды.ЗаказНаряд.Оборудование.Наименование КАК ЗаказНарядОборудование,
	//               |	ро_ОтгрузкаЗаказНаряды.ЗаказНаряд.Оборудование.ЕдиницаИзмерения КАК ЕдИзм,
	//			   |    SUM(1) Кол
	//               |ИЗ
	//               |	Документ.ро_Отгрузка.ЗаказНаряды КАК ро_ОтгрузкаЗаказНаряды
	//               |ГДЕ
	//               |	ро_ОтгрузкаЗаказНаряды.Ссылка = &сс
	//			   | GROUP BY 
	//			   |ро_ОтгрузкаЗаказНаряды.ЗаказНаряд.Оборудование.Наименование,
	//			   |ро_ОтгрузкаЗаказНаряды.ЗаказНаряд.Оборудование.ЕдиницаИзмерения
	//			   |";
	//Тбл = Запрос.Выполнить().Выгрузить();
	//пСтр = "";
	//ДЛя каждого Стр из Тбл Цикл
	//	пстр = пСтр + ","+Стр.ЗаказНарядОборудование+" - "+Стр.Кол+" "+Стр.ЕдИзм;
	//КонецЦикла;
	//Стк.Вставить("Груз",Сред(пСтр,2));
	Стк.Вставить("Груз","ТМЦ согласно приложения к ТТН");
	Стк.Вставить("тблГруз",ДанныеДляПечати(ссДок,Истина,Истина));
	
	Стк.Вставить("Посредники",Тбл.Скопировать(,"Контрагент,Организация,Отправитель,Получатель,СкладОтправитель, СкладПолучатель, СкладПолучательАдрес,АдресОтправителя,АдресПолучателя"));	
	
	Если ЗначениеЗаполнено(Стк.СкладПолучатель)=Ложь Тогда
		Стк.Вставить("СкладПолучатель",Стк.Контрагент);
	КонецЕСЛИ;
	
	Возврат Стк;
	
КонецФункции

Функция РазбитьНаДвеСтроки(ТекСтр,чс)
	
	текЧс = чс;
	Для а=-чс по -1 Цикл
		ЕСли Сред(ТекСтр,-а,1)="," Тогда
			текЧс = -а;
			прервать;
		КонецеСЛИ;
	КонецЦикла;
	
	Возврат Новый Структура("стр1,стр2",Лев(текСтр,текЧс),Сред(текСтр,текЧс+1));
	
КонецФункции

Функция ПечатьТТН(ссДок,ЦепочкаКА=Ложь) Экспорт
	
	Стк = ДанныеШапка(ссДок,ЦепочкаКА);
	
	Таб = Новый ТабличныйДокумент;
	Таб.КлючПараметровПечати = "Печать_МакетТТН1529";
	Макет = ПолучитьМакет("МакетТТН1529");
	
//Таб часть
	//лимитСтрокВТТН = 200;
	//Если Стк.тблГРуз.Количество()<=лимитСтрокВТТН Тогда
	Если СокрлП(Стк.НомерСтрокиМакетаТТН) = "" ТОгда
		Обл = Макет.получитьОбласть("стр21");
	ИНаче
		Обл = Макет.получитьОбласть("стр"+СокрлП(Стк.НомерСтрокиМакетаТТН));
	КонецЕсли;
	
	колСимволов = 31;
	Если СокрлП(Стк.НомерСтрокиМакетаТТН)="25" Тогда
		колСимволов = 50;
	КонецеСЛИ;
		
	облТаб = Новый ТабличныйДокумент;	
	ОблНО = Макет.получитьОбласть("стр23");
	Для каждого стр из Стк.тблГруз Цикл
		Обл.Параметры.Заполнить(стр);
		Если СтрДлина(стр.НомерОборудования)>31 Тогда
			пСтк = РазбитьНаДвеСтроки(стр.НомерОборудования,31);
			Обл.Параметры.НомерОборудования = пстк.стр1;
			облНО.Параметры.НомерОборудования = пСтк.Стр2;
			облТаб.Вывести(Обл);
			облТаб.Вывести(облНО);
		Иначе	
			облТаб.Вывести(Обл);
		КонецЕСлИ;
	КонецЦикла;
	
//Оборотная сторона	
	ОБлОборот = Макет.получитьОбласть("ГоризонтальнаяОборотнаяСторона");
	ОБлОборот.Параметры.Заполнить(Стк);
	
	
	
	Обл1 = Макет.получитьОбласть("стр1");
	Обл1.Параметры.Заполнить(Стк);
	
	ОБл3 = Макет.получитьОбласть("стр3");
	Обл3.Параметры.Заполнить(Стк);
	
	
	Для каждого стрКА из Стк.Посредники Цикл
		
		Обл1.Параметры.Заполнить(стрКА);
		Таб.Вывести(Обл1);
		
		Таб.Вывести(облТаб);
		
		Обл3.Параметры.Заполнить(стрКА);
		Таб.Вывести(Обл3);
		Таб.ВывестиГоризонтальныйРазделительСтраниц();
		
		Таб.Вывести(ОБлОборот);
		
		Таб.ВывестиГоризонтальныйРазделительСтраниц();
	КонецЦикла;
	
	//Если Стк.тблГРуз.Количество()>лимитСтрокВТТН Тогда
	//	Таб.ВывестиГоризонтальныйРазделительСтраниц();
	//	
	//	макетПрил = ДОкументы.ро_Отгрузка.ПолучитьМакет("МакетПриложениеКТТН");
	//	обл = ПечатьНакладная(ссДок,макетПрил);
	//	
	//	
	//	НачалоНовогоФорматаСтрок = Таб.ВысотаТаблицы + 1;
	//	ОбластьПрямоугольная = обл.Область(1, , обл.ВысотаТаблицы, );
	//	Таб.ВставитьОбласть(ОбластьПрямоугольная, Таб.Область(НачалоНовогоФорматаСтрок, 1));
	//	Таб.Область(НачалоНовогоФорматаСтрок, ,	НачалоНовогоФорматаСтрок + обл.ВысотаТаблицы - 1, ).СоздатьФорматСтрок();
	//	
	//	Для Счетчик = 1 По обл.ШиринаТаблицы Цикл
	//		Таб.Область(НачалоНовогоФорматаСтрок, Счетчик).ШиринаКолонки = Обл.Область(1, Счетчик).ШиринаКолонки;
	//	КонецЦикла;
	//	Таб.ВывестиГоризонтальныйРазделительСтраниц();
	//	
	//КонецЕСЛИ;
	
	Таб.ТолькоПросмотр = Истина;
	Таб.ОтображатьГруппировки = ложь;
	Таб.ОтображатьЗаголовки = Ложь;
	Таб.ОтображатьСетку = Ложь;
	
	Возврат Таб;
	
КонецФункции
#КонецОбласти