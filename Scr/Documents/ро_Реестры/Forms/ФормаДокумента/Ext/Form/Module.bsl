
&НаСервереБезКонтекста
Функция ЗаполнитьНаСервере(ДТ,КА,ФлтОбр,ЗкНаряд=Неопределено)
	
	Запрос = новый Запрос;
	Запрос.Текст = "
	               |ВЫБРАТЬ
	               |	РаботаРООстатки.ЗаказНаряд КАК ЗаказНаряд,
	               |	РаботаРООстатки.Оборудование КАК Оборудование,
	               |	РаботаРООстатки.ппНомерОборудования КАК ппНомерОборудования
				   |INTO ВрТблОст
	               |ИЗ
	               |	РегистрНакопления.РаботаРО.Остатки(&Дт
	               |			,
	               |			      (ЗаказНаряд.Оборудование    В ИЕРАРХИИ (&Обр )      ИЛИ &БезОбр = Истина) 
	               |			    и (ЗаказНаряд.Оборудование НЕ В ИЕРАРХИИ (&ОбрИскл )  ИЛИ &БезОбрИскл = Истина) 
	               |				И ЗаказНаряд.Контрагент = &КА 
				   |                и (ЗаказНаряд = &ЗкНаряд или &ЗкНаряд = Неопределено)
				   |              ) КАК РаботаРООстатки
				   |
				   |
	               |ГДЕ
	               |	РаботаРООстатки.КолОстаток > 0
				   |
	               |;
	               |SELECT
	               |  Док.ссылка ЗаказНаряд,
	               |  Док.Номер НомерЗаказНаряда,
	               |  Док.НомерОборудования НомерОборудования,
	               |  Док.Заключение Заключение,
				   |  РаботаРООстатки.ппНомерОборудования,
	               |  ДОк.Оборудование,
	               |  Док.Цена ЦенаЗН,
	               |  CASE WHEN СпрЗак.ссылка IS NULL THEN 1 ELSE 0 END индОплаты
	               |INTO врТбл
	               |
	               |FROM врТблОст РаботаРООстатки
				   |INNER JOIN Документ.роЗаказНаряд Док ON Док.ссылка = РаботаРООстатки.ЗаказНаряд
	               |                                      и РаботаРООстатки.ппНомерОборудования = 0 
	               |
	               |LEFT OUTER JOIN Справочник.ро_Заключения СпрЗак ON СпрЗак.ссылка = Док.Заключение и СпрЗак.БезОплаты = Истина
	               |
	               |UNION ALL
	               |
	               |SELECT
	               |  Док.ссылка ЗаказНаряд,
	               |  Док.НомерАктаДопОбр НомерЗаказНаряда,
	               |  Док.НомерДопОбр НомерОборудования,
	               |  Док.Заключение Заключение,
				   |  РаботаРООстатки.ппНомерОборудования,
	               |  Спр.Ссылка Оборудование,
	               |  Док.Цена ЦенаЗН,
	               |  CASE WHEN СпрЗак.ссылка IS NULL THEN 1 ELSE 0 END индОплаты
	               |
	               |FROM врТблОст РаботаРООстатки
				   |INNER JOIN Документ.роЗаказНаряд Док ON Док.ссылка = РаботаРООстатки.ЗаказНаряд
	               |                                      и РаботаРООстатки.ппНомерОборудования = 1 
	               |                                      и Док.Цена = 0
	               |INNER JOIN Справочник.ро_Оборудование Спр ON Спр.ссылка = Док.ТипДопОбр
	               |LEFT OUTER JOIN Справочник.ро_Заключения СпрЗак ON СпрЗак.ссылка = Док.Заключение и СпрЗак.БезОплаты = Истина
	               |
	               |UNION ALL
	               |
	               |SELECT
	               |  Док.ссылка,
	               |  Док.НомерАктаДопОбр1 НомерЗаказНаряда,
	               |  Док.НомерДопОбр1 НомерОборудования,
	               |  Док.Заключение Заключение,
				   |  РаботаРООстатки.ппНомерОборудования,
	               |  Спр.Ссылка Оборудование,
	               |  Док.Цена ЦенаЗН,
	               |  CASE WHEN СпрЗак.ссылка IS NULL THEN 1 ELSE 0 END индОплаты
	               |
	               |FROM врТблОст РаботаРООстатки
				   |INNER JOIN Документ.роЗаказНаряд Док ON Док.ссылка = РаботаРООстатки.ЗаказНаряд
				   |                                      и РаботаРООстатки.ппНомерОборудования = 2 
	               |                                      и Док.Цена = 0
				   |INNER JOIN Справочник.ро_Оборудование Спр ON Спр.ссылка = Док.ТипДопОбр1
				   |LEFT OUTER JOIN Справочник.ро_Заключения СпрЗак ON СпрЗак.ссылка = Док.Заключение и СпрЗак.БезОплаты = Истина
				   |;
				   |
				   |SELECT
				   |	Тбл.ЗаказНаряд,
				   |    спрРаб.ссылка РаботаПоПрайсу,
				   |    спрРаб.Работа,
				   |    РегЦен.ОписаниеПараметров,
				   |    РегЦен.НаименованиеДляРеестра,
				   |	спрРаб.Цена,
				   |    докРаб.Количество
				   
				   |INTO врЦенаЗН0
				   |FROM врТбл Тбл
				   
				   |INNER JOIN Документ.роЗаказНаряд Док ON Док.ссылка = Тбл.ЗаказНаряд
				   
				   |INNER JOIN РегистрСведений.регистрЦен РегЦен ON  РегЦен.Контрагент   = &КА
				   |											   и регЦен.Оборудование = Док.Оборудование
				   |													
				   |													
				   |INNER JOIN Документ.роЗаказНаряд.Работы ДокРаб ON ДокРаб.ссылка = Тбл.ЗаказНаряд
				   |												и докРаб.Количество > 0
				   
				   |INNER JOIN Справочник.ро_РаботыПоПрайсу.Работы спрРаб ON спрРаб.ссылка  = регЦен.Работа
				   |													   и спрРаб.Работа  = ДокРаб.Работа	
				   |																									
				   
				   |;
				   |
				   |SELECT
				   |	Тбл.ЗаказНаряд,
				   |	Тбл.ОписаниеПараметров,
				   |	Тбл.НаименованиеДляРеестра,
				   |	SUM(Тбл.Цена*Количество) Цена
				   
				   |INTO врЦенаЗН
				   |FROM врЦенаЗН0 Тбл
				   |GROUP BY Тбл.ЗаказНаряд,Тбл.ОписаниеПараметров ,Тбл.НаименованиеДляРеестра
				   |;
				   |SELECT * FROM  врЦенаЗН0 www ORDER BY ЗаказНаряд
				   |;
				   |SELECT
				   |    РаботаРООстатки.ппНомерОборудования,
				   |	РаботаРООстатки.ЗаказНаряд КАК ЗаказНаряд,
				   |	РаботаРООстатки.Оборудование КАК Оборудование,
				   |	РаботаРООстатки.НомерЗаказНаряда КАК НомерЗаказНаряда,
	               |	РаботаРООстатки.НомерОборудования КАК НомерОборудования,
	               |	РаботаРООстатки.Заключение КАК Заключение,
				   |
				   |    CASE WHEN РаботаРООстатки.ЦенаЗН=0 
				   |         THEN MAX(ISNULL(тблЦенаЗН.Цена,ISNULL(Рег.цена,0)))
				   |         ELSE РаботаРООстатки.ЦенаЗН   
				   |         END * индОплаты Цена,
				   |
				   |    ISNULL(тблЦенаЗН.ОписаниеПараметров,Рег.ОписаниеПараметров) ОписаниеПараметров,
				   |
				   |    CASE WHEN  ISNULL(тблЦенаЗН.НаименованиеДляРеестра,Рег.НаименованиеДляРеестра)<>""""
				   |         THEN  ISNULL(тблЦенаЗН.НаименованиеДляРеестра,Рег.НаименованиеДляРеестра)
				   |         ELSE  ISNULL(СпрИмяКАНом.НаименованиеКА, СпрИмяКА.НаименованиеКА+"" ""+Спр.Наименование)
				   |         END    НаименованиеДляРеестра
				   |
				   |
				   |
				   |
				   |     
				   |
				   |
				   |
	               |ИЗ
				   |	врТбл КАК РаботаРООстатки
				   |INNER JOIN Справочник.ро_Оборудование Спр ON   Спр.ссылка = РаботаРООстатки.Оборудование
				   |
				   |LEFT OUTER JOIN РегистрСведений.РегистрЦен Рег ON   Рег.Оборудование = РаботаРООстатки.Оборудование 
				   |				                                 и  Рег.Работа       = Значение(Справочник.ро_РаботыПоПрайсу.ПустаяСсылка)
				   |                                                 и  Рег.Контрагент   = &КА
				   |
				   |	
				   |LEFT OUTER JOIN врЦенаЗН тблЦенаЗН ON тблЦенаЗН.ЗаказНаряд = РаботаРООстатки.ЗаказНаряд
				   |
	               |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрИмяКА ON СпрИмяКА.ссылка     = Спр.Родитель
				   |                                                                                и СпрИмяКА.Контрагент = &КА
				   |
	               |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрИмяКАНом ON СпрИмяКАНом.ссылка     = Спр.ссылка
				   |                                                                                   и СпрИмяКАНом.Контрагент = &КА
				   |
				   |	
				   |
				   |
				   |	
				   |GROUP BY
				   |    РаботаРООстатки.ппНомерОборудования,
	               |	РаботаРООстатки.ЗаказНаряд ,
	               |	РаботаРООстатки.индОплаты ,
	               |	РаботаРООстатки.Оборудование  ,
	               |	РаботаРООстатки.НомерЗаказНаряда  ,
	               |	РаботаРООстатки.НомерОборудования,  
	               |	РаботаРООстатки.Заключение,
	               |	РаботаРООстатки.ЦенаЗН,
				   |    ISNULL(тблЦенаЗН.ОписаниеПараметров,Рег.ОписаниеПараметров),
				   |    ISNULL(тблЦенаЗН.НаименованиеДляРеестра,Рег.НаименованиеДляРеестра),
				   |	
				   |    CASE WHEN  ISNULL(тблЦенаЗН.НаименованиеДляРеестра,Рег.НаименованиеДляРеестра)<>""""
				   |         THEN  ISNULL(тблЦенаЗН.НаименованиеДляРеестра,Рег.НаименованиеДляРеестра)
				   |         ELSE  ISNULL(СпрИмяКАНом.НаименованиеКА, СпрИмяКА.НаименованиеКА+"" ""+Спр.Наименование)
				   |         END   
				   |
				   |	
				   |
				   |ORDER BY РаботаРООстатки.Оборудование.родитель.Наименование  ,ЗаказНаряд, ппНомерОборудования 
				   |";
	
	Запрос.УстановитьПараметр("Дт",Дт);
	Запрос.УстановитьПараметр("КА",КА);
	Запрос.УстановитьПараметр("ЗкНаряд",ЗкНаряд);
	
	Запрос.УстановитьПараметр("Обр",Новый МАссив);
	Запрос.УстановитьПараметр("ОбрИскл",Новый МАссив);
	Запрос.УстановитьПараметр("БезОбр",Истина);
	Запрос.УстановитьПараметр("БезОбрИскл",Истина);
	Если ЗначениеЗаполнено(ФлтОбр) Тогда
		Если ФлтОбр.ИсключитьГруппы Тогда
			Запрос.УстановитьПараметр("ОбрИскл",флтОбр.ГруппыОборудования.выгрузитьКолонку("ГруппаОборудования"));
			Запрос.УстановитьПараметр("БезОбрИскл",Ложь);
		Иначе
			Запрос.УстановитьПараметр("Обр",флтОбр.ГруппыОборудования.выгрузитьКолонку("ГруппаОборудования"));
			Запрос.УстановитьПараметр("БезОбр",Ложь);
		КонецЕсЛИ;
	КонецЕСли;
	
	Рез = Запрос.ВыполнитьПакет();
	
	Тбл = Рез[Рез.Количество()-1].Выгрузить();
	масТбл = глСервер.ТблВМасСтк(Тбл);
	
	ТблРаб = Рез[Рез.Количество()-2].Выгрузить();
	масРаб = глСервер.ТблВМасСтк(ТблРаб);
	
	Рез = Новый МАссив;
	Рез.Добавить(масТбл);
	рез.Добавить(масРаб);
	
	Возврат Рез;

КонецФункции



&НаСервереБезКонтекста
Функция ОбновитьДанныеПоОборудованию(Мас)
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_Оборудование.Ссылка КАК СсылкаОбр,
	               |	ро_Оборудование.Родитель КАК ГруппаРодитель,
	               |	ро_Оборудование.Диаметр КАК Диаметр,
	               |	ро_Оборудование.Давление КАК Давление
	               |ИЗ  Справочник.ро_Оборудование КАК ро_Оборудование  				  
				   |
	               |ГДЕ
	               |	ро_Оборудование.Ссылка в (&Ссылка) ";
	Запрос.УстановитьПараметр("Ссылка",Мас);
	
	Тбл = Запрос.Выполнить().Выгрузить();
	сткСтр = "";
	Для каждого Кол из ТБл.Колонки Цикл
		СткСтр = СткСтр+","+Кол.Имя;
	КонецЦикла;
	СткСтр = Сред(СткСтр,2);
	
	Рез = Новый Соответствие;
	Для каждого Стр из Тбл Цикл
		Стк = Новый Структура(СткСтр);
		ЗаполнитьЗначенияСвойств(Стк,Стр);
		Рез.Вставить(Стр.СсылкаОбр,Стк);
	КонецЦикла;
	
	Возврат Рез;
	
	
КонецФункции

&НаКлиенте
Процедура ОбновитьРеквизитыОборудования(МасСтр = Неопределено,ОбновитьОписаниеПараметров=Ложь)
	
	Если МасСтр = Неопределено Тогда
		МасСтр = Объект.ЗаказНаряды;	
	КонецесЛИ;
	
	МАс = Новый Массив;
	Для каждого Стр из МасСтр Цикл
		Мас.Добавить(Стр.Оборудование);
	КонецЦикла;
	
	СооОбр = ОбновитьДанныеПоОборудованию(Мас);
	Для каждого Стр из МасСтр Цикл
		Стк = СооОбр.Получить(Стр.Оборудование);
		ЕСли Стк=Неопределено ТОгда Продолжить; КонецЕСлИ;
		ЗаполнитьЗначенияСвойств(Стр,Стк);
	Конеццикла;
	
	Элементы.стрРаботы.Видимость = Объект.Работы.Количество()<>0;
	
КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	
	Если Объект.Проведен ТОгда
		ПоказатьПредупреждение(,"Нельзя заполнять проведенный документ");
		Возврат;
	КонецеСЛИ;
	
	
	масРез = ЗаполнитьНаСервере(Объект.Дата,Объект.Контрагент,Объект.ФильтрОтбораДляРеестра);
	
	Рез    = масРез[0];
	РезРаб = масРез[1];
	
	СооРуч = новый Соответствие;
	Для каждого Стр из ОБъект.ЗаказНаряды Цикл
		Если Стр.РучКорректировка = Истина Тогда
			СооРуч.Вставить(Стр.ЗаказНаряд,Стр.цена);
		КонецЕсли;
	КонецЦикла;
	
	Если  Команда.Имя = "Заполнить" Тогда
		Объект.ЗаказНаряды.Очистить();
		Для каждого Эл из Рез Цикл
			НовСтр = Объект.ЗаказНаряды.Добавить();
			ЗаполнитьЗначенияСвойств(НовСтр,Эл);
		КонецЦикла;
	Иначе  //Обновить
		Для каждого Стр из ОБъект.ЗаказНаряды Цикл
			Стр.Цена = 0;
		КонецЦикла;
		
		Стк = Новый Структура("ЗаказНаряд,ппНомерОборудования");
		Для каждого Эл из Рез Цикл
			ЗаполнитьЗначенияСвойств(Стк,эл);
			Мас = Объект.ЗаказНаряды.НайтиСтроки(Стк);
			Для каждого НовСтр из Мас Цикл
				ЗаполнитьЗначенияСвойств(НовСтр,Эл);
			КонецЦикла;
		КонецЦикла;
		
	КонецЕсли;
	
	Для каждого Эл из СооРуч Цикл
		Мас = Объект.ЗаказНаряды.НайтиСтроки(Новый Структура("ЗаказНаряд",Эл.Ключ));
		Если МАс=Неопределено ТОгда Продолжить; КонецЕсли;
		Мас[0].Цена = Эл.Значение;
		Мас[0].РучКорректировка = Истина;
	КонецЦикла;
	
	
	//Работы
	Объект.Работы.Очистить();
	Для каждого Эл из РезРаб Цикл
		НовСтр = Объект.Работы.Добавить();
		ЗаполнитьЗначенияСвойств(НовСтр,Эл);
	КонецЦикла;

	
	ОбновитьРеквизитыОборудования(,Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьПоСумРеестра()
	
	Если Объект.СуммаРеестра=0 ТОгда Возврат; КонецЕСли;
	Если Объект.ЗаказНаряды.Количество()=0 Тогда Возврат; КонецЕсли;
	
	Сум=0;
	Кол=0;
	Кол0=0;
	Для каждого Стр из Объект.ЗаказНаряды Цикл
		Если Стр.Цена=0 ТОгда 
			Кол0 = Кол0 + 1;
		ИНаче
			Сум = Сум + Стр.Цена;
			Кол = Кол + 1;
		КонецЕсли;
	КонецЦикла;
	
	Если Кол=0 ТОгда
		срЦена = 1;
	ИНАче
		срЦена = Сум/Кол;
	КонецЕсли;
	
	итСум = Сум + кол0*срЦена;
	рееСум = 0;
	послСтр = Неопределено;
	
	Для каждого Стр из Объект.ЗаказНаряды Цикл
		Если Стр.цена = 0 Тогда
			пЦен = срЦена;
		Иначе
			пЦен = Стр.Цена;
		КонецЕсли;
		Стр.Цена = ОКР(пЦен/итСум * Объект.СуммаРеестра,2,1);
		рееСум = рееСум + Стр.Цена;
		послСтр = Стр;
	КонецЦикла;
	
	послСтр.Цена = послСтр.Цена+Объект.СуммаРеестра-рееСум;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	Объект.лог = ""+ТекущаяДата()+"-"+ИмяПользователя()+"-"+ИмяКомпьютера();
КонецПроцедуры


&НаКлиенте
Процедура ЗаказНарядыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если ЗначениеЗаполнено(Элемент.ТекущиеДанные.ЗаказНаряд)=Ложь Тогда Возврат; КонецЕсли;
	Если    Поле.Имя = "ЗаказНарядыЗаказНаряд"
		или Поле.Имя = "ЗаказНарядыЦена" 
		или Поле.Имя = "ЗаказНарядыМеталлолом" Тогда
		Возврат;
	ИначеЕсли Поле.Имя = "ЗаказНарядыЗаказНарядОборудованиеРодитель" Тогда
		ПоказатьЗначение(,Элемент.ТекущиеДанные.ГруппаРодитель);
	ИначеЕсли Поле.Имя = "ЗаказНарядыОписаниеПараметров" Тогда
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("Ключ", ПолучитьКлючРегЦен(Объект.Контрагент,Элемент.ТекущиеДанные.Оборудование)); 
		//ПараметрыФормы.Вставить("КлючУникальности", ТекущийВызов.КлючУникальности); 
		ОткрытьФорму("РегистрСведений.РегистрЦен.ФормаЗаписи", ПараметрыФормы,,ЭтаФорма,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	Иначе
		ПоказатьЗначение(,Элемент.ТекущиеДанные.ЗаказНаряд);
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьКлючРегЦен(КА,Обр)
	Возврат РегистрыСведений.РегистрЦен.СоздатьКлючЗаписи(Новый Структура("Контрагент,Оборудование",КА,Обр));
КонецФункции

&НаСервереБезКонтекста
Функция ПечатныеФормыНаСервере(ссДОк,Имя)
	
	Если ЗначениеЗаполнено(ссДОк)=Ложь Тогда Возврат Неопределено; КонецЕсли; 
	
	Если Имя = "Реестр" Тогда
		имя = Имя+" "+ссДок.Номер;
		Возврат Документы.ро_Реестры.ПечатьРеестр(ссДОк);
	ИНАче
		Возврат Справочники.ПечатныеФормы.ПечатьПоКодуФормы(ссДок,Имя);
	КонецЕСЛИ;
	
КонецФункции

&НаКлиенте
Процедура Печать(Команда) Экспорт
	Если ОбщийКлиент.ПроверкаМодифицированности(ЭтаФорма,команда)=Ложь Тогда Возврат; КонецЕсли;
	
	ИмяКодМакета = СокрЛП(Команда.Имя);
	Таб = ПечатныеФормыНаСервере(Объект.Ссылка,ИмяКодМакета);
	Если Таб = Неопределено Тогда Возврат; КонецЕсли;
	
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,ИмяКодМакета),,Новый УникальныйИдентификатор());
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПечатныеФормыСводНаСервере(сс,сска,ИмяКодМакета)
	Возврат Документы.ро_Реестры.ПечатьРеестрСвод(сс,ссКА,ИмяКодМакета);
КонецФункции

&НаСервереБезКонтекста
Функция ПечатныеФормыРеестрРаботНаСервере(сс)
	Возврат Документы.ро_Реестры.ПечатьРеестрРабот(сс);
КонецФункции


&НаКлиенте
Процедура ПЕчатьСвод(Команда)
	Если ОбщийКлиент.ПроверкаМодифицированности(ЭтаФорма,команда)=Ложь Тогда Возврат; КонецЕсли;
	
	ИмяКодМакета = СокрЛП(Команда.Имя);
	Таб = ПечатныеФормыСводНаСервере(Объект.Ссылка,Объект.Контрагент,ИмяКодМакета);
	Если Таб = Неопределено Тогда Возврат; КонецЕсли;
	
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,ИмяКодМакета),,Новый УникальныйИдентификатор());
	
КонецПроцедуры


&НаКлиенте
Процедура ПечатьРеестрРабот(Команда)
	Если ОбщийКлиент.ПроверкаМодифицированности(ЭтаФорма,команда)=Ложь Тогда Возврат; КонецЕсли;
	
	ИмяКодМакета = СокрЛП(Команда.Имя);
	Таб = ПечатныеФормыРеестрРаботНаСервере(Объект.Ссылка);
	Если Таб = Неопределено Тогда Возврат; КонецЕсли;
	
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,ИмяКодМакета),,Новый УникальныйИдентификатор());
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НайтиЗаказНарядПоНомеру(ном,дт,ссЗН)
	
	Если СокрЛП(ном)="" Тогда Возврат Неопределено; КонецЕСЛИ;
	
	Если ЗначениеЗаполнено(ссЗН)=Истина  Тогда
		Если СокрЛП(ссЗН.Номер) = СокрЛП(ном) Тогда Возврат Неопределено; КонецЕсли;
	КонецеСЛИ;
	
	сс = Документы.роЗаказНаряд.НайтиПоНомеру(ном,дт);
	Если сс.Пустая() Тогда Возврат Неопределено; КонецЕсли;
	
	Возврат сс;
	
КонецФункции

&НаКлиенте
Процедура ЗаказНарядыНомерЗаказНарядаПриИзменении(Элемент)
	ТекСтр = Элементы.ЗаказНаряды.ТекущиеДанные;
	ссЗН = НайтиЗаказНарядПоНомеру(Элемент.ТекстРедактирования,Объект.Дата,ТекСтр.ЗаказНаряд);
	Если ссЗН = Неопределено Тогда Возврат; КонецеСЛИ;
	
	текСтр.ЗаказНаряд = ссЗН;
	
	ПриВыбореЗаказНаряд(ТекСтр);
КонецПроцедуры

&НаКлиенте
Процедура ЗаказНарядыЗаказНарядПриИзменении(Элемент)
	ТекСтр = Элементы.ЗаказНаряды.ТекущиеДанные;
	ПриВыбореЗаказНаряд(ТекСтр);
КонецПроцедуры


&НаКлиенте
Процедура ПриВыбореЗаказНаряд(ТекСтр)
	
	Если ЗначениеЗаполнено(ТекСтр.ЗаказНаряд)=Ложь  Тогда Возврат; КонецЕсли;
	масСтр = Новый Массив;
	
	масРез = ЗаполнитьНаСервере(Объект.Дата,ОБъект.Контрагент,Неопределено,ТекСтр.ЗаказНаряд);
	мас    = масРез[0];
	резРаб = масрез[1];
	
	Для а=1 по Мас.Количество() Цикл
		
		пСтр = Мас[а-1];
		
		Если а>1 Тогда
			пМас = Объект.ЗаказНаряды.НайтиСтроки(Новый Структура("ЗаказНаряд,ппНомерОборудования",пСтр.ЗаказНаряд,пСтр.ппНомерОборудования));
			индекс = Объект.ЗаказНаряды.Индекс(текстр);
			Если пМас.Количество()<>0 Тогда
				текСтр = пМас[0];
				индНов = Объект.ЗаказНаряды.Индекс(текстр);
				Объект.ЗаказНаряды.Сдвинуть(индНов,Индекс-индНов);
			ИНАче
				текСтр = Объект.ЗаказНаряды.Вставить(индекс+1);
			КонецеСЛИ;
		КонецЕСлИ;
		
		ЗаполнитьЗначенияСвойств(ТекСтр,пСтр);
		
		масСтр.Добавить(ТекСтр);
	КонецЦикла;
	
	//Работы
	пМас = ОБъект.Работы.НайтиСтроки(Новый Структура("ЗаказНаряд",пСтр.ЗаказНаряд));
	ДЛя каждого эл из пМас Цикл
		Объект.Работы.Удалить(Объект.Работы.Индекс(эл));
	Конеццикла;
	
	Для каждого эл из резРаб Цикл
		новстр = объект.Работы.Добавить();
		ЗаполнитьЗначенияСвойств(новСтр,эл);
	КонецЦикла;
	
	ОбновитьРеквизитыОборудования(масСтр);
	
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ОбновитьРеквизитыОборудования();
	ОбновитьРегБух();
	
	РучнаяКорСуммы = Объект.СуммаРеестра<>0;
	РучнаяКорСуммыПриИзменении();
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьРегБух()
	 Стк = ОбновитьРегБухНаСервере(Объект.ссылка);
	 БухРеализация = Стк.Наименование;
	 Элементы.ФормаПечатьСФ.Видимость = СокрлП(БухРеализация)<>"";
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция ОбновитьРегБухНаСервере(сс)
	
	Стк = Новый Структура("Наименование");
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	СоответсвиеИдБухгалтерии.Наименование КАК Наименование,
	               |	СоответсвиеИдБухгалтерии.ДопНаименование КАК ДопНаименование
	               |ИЗ
	               |	РегистрСведений.СоответсвиеИдБухгалтерии КАК СоответсвиеИдБухгалтерии
	               |ГДЕ
	               |	СоответсвиеИдБухгалтерии.Док = &Док";
	Запрос.УстановитьПараметр("Док",сс);
	Выб = Запрос.Выполнить().Выбрать();
	Если Выб.Следующий() Тогда
		ЗаполнитьЗначенияСвойств(Стк,Выб);
	КонецЕсли;
	
	Возврат Стк;
	
	
КонецФункции


&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	ОбновитьРеквизитыОборудования();
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьВБухгалтерию(Команда)
	ВыгрузитьВБухгалтериюНаСервере(Объект.Ссылка);
	ОбновитьРегБух();
КонецПроцедуры

&НаСервереБезКонтекста
Функция ВыгрузитьВБухгалтериюНаСервере(ссДок)
	
	Стк = Новый Структура();
	
	
	Стк.Вставить("GUID",ссДок.УникальныйИдентификатор());
	Стк.Вставить("Дата",ссДок.Дата);
	Стк.Вставить("ВидДок","РеализацияТоваровУслуг");
	Стк.Вставить("КратностьВзаиморасчетов",1);
	Стк.Вставить("КурсВзаиморасчетов",1);
	Стк.Вставить("КодВидаОперации","01");
	Стк.Вставить("СуммаВключаетНДС",Ложь);
	Стк.Вставить("ИННКонтрагентаДляПоиска",ссДок.Контрагент.ИНН);
	Если СокрЛП(ссДок.Контрагент.ДоговорБухКод)<>"" Тогда
		Стк.Вставить("НомерДоговораДляПоиска",ссДок.Контрагент.ДоговорБухКод);
	КонецЕсли;
	Если СокрЛП(ссДок.Контрагент.СубконтоБухКод)<>"" Тогда
		Стк.Вставить("КодСубконто",ссДок.Контрагент.СубконтоБухКод);
	КонецЕсли;
	
	Стк.Вставить("Таблица_Услуги",АлгаРеаПокупателюТаб(ссДок));
	
	СткСоединение = глСервер.СткПолучитьСоединение();
	
	Соединение = Новый HTTPСоединение(
	СткСоединение.Сервер, // сервер (хост)
	СткСоединение.Порт, // порт, по умолчанию для http используется 80, для https 443
	СткСоединение.Логин, // пользователь для доступа к серверу (если он есть)
	СткСоединение.Пароль, // пароль для доступа к серверу (если он есть)
	, // здесь указывается прокси, если он есть
	, // таймаут в секундах, 0 или пусто - не устанавливать
	// защищенное соединение, если используется https
	);
	адресБух = "buh1";
	стрАПИ = адресБух+"/hs/invAPI/LOADDOC";
	Запрос = Новый HTTPЗапрос(стрАПИ);    
	
	хр = Новый ХранилищеЗначения(Стк);
	Запрос.УстановитьТелоИзСтроки(XMLстрока(хр));
	
	Результат = Соединение.POST(Запрос);	
	
	Если Результат.КодСостояния <> 200 Тогда 
		Сообщить("Ошибка синхронизации: код "+Результат.КодСостояния);
		Сообщить(результат.ПолучитьТелоКакСтроку());
		Возврат Неопределено;
	КонецЕСЛИ;
	
	рез = XMLзначение(Тип("ХранилищеЗначения"),Результат.ПолучитьТелоКакСтроку()).Получить();
	
	Если ТипЗнч(Рез) = Тип("Структура") Тогда
		Зап = РегистрыСведений.СоответсвиеИдБухгалтерии.СоздатьМенеджерЗаписи();
		Зап.Док = ссДок;
		Зап.Наименование = Рез.Док;
		Зап.ДопНаименование = "Сч.ф. "+Рез.сфном+" от "+Рез.СФдт;
		Зап.Записать();
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаСервереБезКонтекста
Функция АлгаРеаПокупателюТаб(ссДок) 
	
	ТБл = Новый ТаблицаЗначений;
	ТБл.Колонки.Добавить("Содержание");
	ТБл.Колонки.Добавить("Сумма");
	ТБл.Колонки.Добавить("СуммаНДС");
	ТБл.Колонки.Добавить("СчетКодДоходов");
	ТБл.Колонки.Добавить("СчетКодРасходов");
	ТБл.Колонки.Добавить("СчетКодУчетаНДСПоРеализации");
	ТБл.Колонки.Добавить("НДС20");
	
	
	новСтр = Тбл.Добавить();
	новстр.Содержание = "Оказание услуг по входному контролю и опрессовке запорной и фонтанной арматуры";
	новстр.Сумма = ссДок.СуммаДокумента;
	новстр.СуммаНДС = ОКР(ссДок.СуммаДокумента/5,2,1);
	новСтр.СчетКодДоходов = "90.01.1";
	новСтр.СчетКодРасходов = "90.02.1";
	новСтр.СчетКодУчетаНДСПоРеализации = "90.03";
	
	
	Возврат Тбл;
	
КонецФункции


&НаСервереБезКонтекста
Функция ПечатьСФНаСервере(ссДок)
	
	Стк = Новый Структура();
	Стк.Вставить("ГУИД",ссДок.УникальныйИдентификатор());
	
	СткСоединение = глСервер.СткПолучитьСоединение();
	
	Соединение = Новый HTTPСоединение(
	СткСоединение.Сервер, // сервер (хост)
	СткСоединение.Порт, // порт, по умолчанию для http используется 80, для https 443
	СткСоединение.Логин, // пользователь для доступа к серверу (если он есть)
	СткСоединение.Пароль, // пароль для доступа к серверу (если он есть)
	, // здесь указывается прокси, если он есть
	, // таймаут в секундах, 0 или пусто - не устанавливать
	// защищенное соединение, если используется https
	);
	адресБух = "buh1";
	стрАПИ = адресБух+"/hs/invAPI/PRNDOC";
	Запрос = Новый HTTPЗапрос(стрАПИ);    
	
	хр = Новый ХранилищеЗначения(Стк);
	Запрос.УстановитьТелоИзСтроки(XMLстрока(хр));
	
	Результат = Соединение.POST(Запрос);	
	
	Если Результат.КодСостояния <> 200 Тогда 
		Сообщить("Ошибка синхронизации: код "+Результат.КодСостояния);
		Сообщить(результат.ПолучитьТелоКакСтроку());
		Возврат Неопределено;
	КонецЕСЛИ;
	
	резХР = XMLзначение(Тип("ХранилищеЗначения"),Результат.ПолучитьТелоКакСтроку());
	Если резХР=Неопределено ТОгда Возврат РезХР; КонецЕсли;
	
	Возврат РезХР.Получить();
	
КонецФункции


&НаКлиенте
Процедура ПечатьСФ(Команда)
	
	Если СокрЛП(БухРеализация) ="" ТОгда Возврат; КонецеСЛИ;
	
	Мас = ПечатьСФНаСервере(Объект.Ссылка);
	
	Если ТипЗнч(Мас) = Тип("Массив") Тогда
		Для каждого Таб из Мас Цикл
			ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,"Печать из бух."),,Новый УникальныйИдентификатор());
		КонецЦикла;
		//Таб.ПОказать();
	ИНаче
		Сообщить("Не найдена счет-фактура в подистеме бухгалтерия!");
	КонецЕсли;
	
КонецПроцедуры


&НаСервере
Процедура КонтрагентПриИзмененииНаСервере()
	Справочники.ПечатныеФормы.ДобавитьКнопкиПечати(ЭтаФорма,Объект.Контрагент,Перечисления.ВидыДокументовДЛяПечФорм.Реестр);
КонецПроцедуры

&НаСервереБезКонтекста
Функция Контрагент_Реквизиты(сс)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Контрагенты.ПунктПогрузки КАК ПунктПогрузки,
	               |	Контрагенты.Подписант КАК Подписант,
	               |	Контрагенты.ПодписантДолжность КАК ПодписантДолжность
	               |ИЗ
	               |	Справочник.Контрагенты КАК Контрагенты
	               |ГДЕ
	               |	Контрагенты.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка",Сс);
	Тбл = Запрос.Выполнить().Выгрузить();
	
	Стк = Новый Структура;
	Для каждого Кол из ТБл.Колонки Цикл
		Стк.вставить(Кол.имя,ТБл[0][Кол.имя]);
	Конеццикла;
	
	
	//Последний док
	Запрос.Текст = "ВЫБРАТЬ TOP 1
	               |	ро_Реестры.Организация КАК Организация
	               |ИЗ
	               |	Документ.ро_Реестры КАК ро_Реестры
	               |ГДЕ
	               |	ро_Реестры.Контрагент = &Ссылка
	               |	И ро_Реестры.Проведен = TRUE
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	ро_Реестры.Дата УБЫВ";
	
	Выб = Запрос.Выполнить().Выбрать();
	Если Выб.Следующий() ТОгда
		Стк.Вставить("Организация",Выб.Организация);
	КонецЕсли;
	
	
	
	Возврат Стк;
	
КонецФункции


&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	КонтрагентПриИзмененииНаСервере();
	Стк = Контрагент_Реквизиты(Объект.Контрагент);
	ЗаполнитьЗначенияСвойств(Объект,Стк);
КонецПроцедуры


&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	КонтрагентПриИзмененииНаСервере();
КонецПроцедуры


&НаКлиенте
Процедура РучнаяКорСуммыПриИзменении(Элемент=Неопределено)
	
	Если  Элемент<>Неопределено Тогда
		Если РучнаяКорСуммы=Ложь  Тогда
			Объект.СуммаРеестра=0;
			СуммаРестраПриИзменении(Элемент);
		КонецеСЛИ;
	КонецЕсли;
	
	Элементы.СуммаРеестра.Видимость = РучнаяКорСуммы;
	
КонецПроцедуры

&НаКлиенте
Процедура СуммаРестраПриИзменении(Элемент)
	Если Объект.СуммаРеестра<>0 Тогда
		ПересчитатьПоСумРеестра();
	Иначе
		Заполнить(Новый Структура("Имя","Обновить"));
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаказНарядыЦенаПриИзменении(Элемент)
	Элементы.ЗаказНаряды.ТекущиеДанные.РучКорректировка = Истина;
КонецПроцедуры


&НаСервереБезКонтекста
Функция ПечатьДефектовкиНаСервере(сс,СткДопИнфо)
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_РеестрыЗаказНаряды.ЗаказНаряд КАК ЗаказНаряд
	               |ИЗ
	               |	Документ.ро_Реестры.ЗаказНаряды КАК ро_РеестрыЗаказНаряды
	               |ГДЕ
	               |	ро_РеестрыЗаказНаряды.Ссылка = &Ссылка";
 	Запрос.УстановитьПараметр("Ссылка",сс);
	Выб = Запрос.Выполнить().Выбрать();
	
	Таб = Новый ТабличныйДокумент;
	Пока Выб.Следующий() Цикл
		
		Если Выб.ЗаказНаряд.Дефектовка.Количество()=0 Тогда
			Обк = Выб.ЗаказНаряд.ПолучитьОбъект();
			Мас = Справочники.ро_Оборудование.ПолучитьДеталиДефектовки(Обк.Оборудование.Родитель);
			Для каждого эл из МАс Цикл
				новСтр = Обк.Дефектовка.Добавить();
				ЗаполнитьЗначенияСвойств(новстр,Эл);
			КонецЦИкла;
			Обк.записать();
		КонецеСЛИ;
		
		пТ = Документы.роЗаказНаряд.ПечатьДефектовка(Выб.ЗаказНаряд,СткДопИНфо);
		Таб.вывести(пТ);
		Таб.ВывестиГоризонтальныйРазделительСтраниц();
		
	Конеццикла;
	
	
	Возврат Таб;
	
КонецФункции


&НаКлиенте
Процедура ПечатьДефектовки(Команда)
	
	Если ОбщийКлиент.ПроверкаМодифицированности(ЭтаФорма,команда)=Ложь Тогда Возврат; КонецЕсли;
	
	СткДопИНфо = Новый Структура();
	Если СокрЛП(Объект.Подписант)<>"" Тогда
		СткДопИнфо.Вставить("каДлж",Объект.ПодписантДолжность);
		СткДопИнфо.Вставить("каФИО",Объект.Подписант);
	КонецЕсли;
	Если СокрЛП(Объект.Подписант)<>"" Тогда
		Стк = ФИОДЛЖ(Объект.Подписант);
		СткДопИнфо.Вставить("каДлж",Объект.ПодписантДолжность);
		СткДопИнфо.Вставить("каФИО",Стк.ФИО);
	КонецЕсли;
	ЕСли ЗначениеЗаполнено(Объект.КонтролерСТК) Тогда
		Стк = ФИОДЛЖ(Объект.КонтролерСТК);
		СткДопИнфо.Вставить("длжКонтролерДеф",Стк.Длж);
		СткДопИнфо.Вставить("КонтролерДеф",Стк.ФИО);
	КонецЕсли;
	
	ЕСли СокрлП(Объект.БухРеализация)<>"" Тогда
		СткДопИнфо.Вставить("ДопИнфоЗгл","Счет-фактура: ");
		СткДопИнфо.Вставить("ДопИнфо",Объект.БухРеализация);
	КонецЕсли;	
	
	Таб = ПечатьДефектовкиНаСервере(Объект.Ссылка,СткДопИнфо);
	
	ОткрытьФорму("ОбщаяФорма.ФормаПечати",Новый Структура("Результат,Заголовок",Таб,"Деф.вед."),,Новый УникальныйИдентификатор());
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ФИОДлж(Сотр)
	
	Стк = Новый Структура;
	Если ТипЗнч(Сотр) = Тип("СправочникСсылка.ФизическиеЛица") Тогда
		Стк.Вставить("Длж",Сотр.Должность);
	КонецЕсли;
	Стк.Вставить("ФИО",СПравочники.ФизическиеЛица.ФИОстр(Сотр));
	
	Возврат Стк;
	
КонецФункции

&НаКлиенте
Процедура ОткрытьРегЦен(Команда)
	ОткрытьФорму("РегистрСведений.РегистрЦен.Форма.Форма",Новый Структура("Контрагент",Объект.Контрагент),,ЭтаФорма);
КонецПроцедуры


