﻿#Область ПечатьКарточки

Функция КомпонентаФормированияQRКода(Отказ)
	ТекстОшибки = НСтр("ru = 'Не удалось подключить внешнюю компоненту для генерации QR-кода'");
	
	Макет = ПолучитьОбщийМакет("КомпонентаПечатиQRКода");
	Адрес = ПоместитьВоВременноеХранилище(Макет); 
	Попытка
		Если ПодключитьВнешнююКомпоненту(Адрес, "QR") Тогда
			QRCodeGenerator = Новый("AddIn.QR.QRCodeExtension");
		Иначе
			//Чего-то сообщить!!!
		КонецЕсли
	Исключение
		Сообщить(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Возврат QRCodeGenerator;
	
КонецФункции

// Возвращает двоичные данные для формирования QR кода.
//
// Параметры:
//  QRСтрока         - Строка - данные, которые необходимо разместить в QR-коде.
//
//  УровеньКоррекции - Число - уровень погрешности изображения при котором данный QR-код все еще возможно 100%
//                             распознать.
//                     Параметр должен иметь тип целого и принимать одно из 4 допустимых значений:
//                     0(7% погрешности), 1(15% погрешности), 2(25% погрешности), 3(35% погрешности).
//
//  Размер           - Число - определяет длину стороны выходного изображения в пикселях.
//                     Если минимально возможный размер изображения больше этого параметра - код сформирован не будет.
//
//  ТекстОшибки      - Строка - в этот параметр помещается описание возникшей ошибки (если возникла).
//
// Возвращаемое значение:
//  ДвоичныеДанные  - буфер, содержащий байты PNG-изображения QR-кода.
// 
// Пример:
//  
//  // Выводим на печать QR-код, содержащий в себе информацию зашифрованную по УФЭБС.
//
//  QRСтрока = УправлениеПечатью.ФорматнаяСтрокаУФЭБС(РеквизитыПлатежа);
//  ТекстОшибки = "";
//  ДанныеQRКода = УправлениеПечатью.ДанныеQRКода(QRСтрока, 0, 190, ТекстОшибки);
//  Если Не ПустаяСтрока(ТекстОшибки)
//      ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
//  КонецЕсли;
//
//  КартинкаQRКода = Новый Картинка(ДанныеQRКода);
//  ОбластьМакета.Рисунки.QRКод.Картинка = КартинкаQRКода;
//
Функция ДанныеQRКода(QRСтрока, УровеньКоррекции, Размер) Экспорт
	Отказ = Ложь;
	ГенераторQRКода = КомпонентаФормированияQRКода(Отказ);
	Если Отказ Тогда
		Возврат Неопределено;
	КонецЕсли;
	Попытка
		ДвоичныеДанныеКартинки = ГенераторQRКода.GenerateQRCode(QRСтрока, УровеньКоррекции, Размер);
	Исключение
		//ЗаписьЖурналаРегистрации(НСтр("ru = 'Формирование QR-кода'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
		//	УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	Возврат ДвоичныеДанныеКартинки;
КонецФункции

Функция ПечатьКарточки(ссМас0) Экспорт
	
	Если ТипЗнч(ссМАс0)<>Тип("Массив") ТОгда
		ссМас = Новый МАссив;
		ссМАс.добавить(ссМас0);
	Иначе
		ссМас = ссМас0;
	КонецЕСЛИ;
	
	ДЛя а=-ссМас.Количество() по -1 Цикл
		Если ТипЗнч(ссМас[-а-1]) <> Тип("ДокументСсылка.роЗаказНаряд") Тогда
			ссМас.удалить(-а-1);
		КонецЕсли;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	роЗаказНаряд.ссылка КАК ссылка,
	               |	роЗаказНаряд.Номер КАК Номер,
	               |	роЗаказНаряд.Дата КАК Дата,
	               |	роЗаказНаряд.Оборудование.Код КАК ОборудованиеКод,
	               |	роЗаказНаряд.НомерОборудования,
	               |	роЗаказНаряд.Плательщик КАК ЦехКонтрагента,
	               |	роЗаказНаряд.Контрагент КАК Контрагент,
	               |	роЗаказНаряд.Оборудование.Наименование КАК ОборудованиеНаименование,
				   |    ДокПост.ПунктПогрузки ПунктПогрузки
	               |ИЗ
	               |	Документ.роЗаказНаряд КАК роЗаказНаряд
				   |LEFT OUTER JOIN Документ.ро_ПриходОборудования ДокПост ON ДокПост.ссылка = роЗаказНаряд.ДокументПоступление
	               |ГДЕ
	               |	роЗаказНаряд.Ссылка в (&Ссылка)";
	
	Запрос.УстановитьПараметр("ссылка",ссМАс);
	
	Таб = Новый ТабличныйДокумент;
	Макет = Документы.роЗаказНаряд.ПолучитьМакет("Макет");
	Обл = Макет.ПолучитьОбласть("Строка|й1");
	
	Выб = Запрос.Выполнить().Выбрать();
	колВСтр=0;
	колВКол=1;
	Пока Выб.Следующий() Цикл
		
		Обл.Параметры.Заполнить(Выб);
		обл.Параметры.Номер = СокрЛП(Выб.Номер);
		
		//QR Код
		СтрокаQRКода = СформироватьСтрокуQRКода(Выб.ссылка);
		ДанныеQRКода = ДанныеQRКода(СтрокаQRКода,0,252);
		КартинкаQRКода = Новый Картинка(ДанныеQRКода);
		НовыйРисунок = Обл.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Картинка);
		НовыйРисунок.Картинка = КартинкаQRКода;
		НовыйРисунок.Высота = 40; 
		НовыйРисунок.Ширина = 40;
		НовыйРисунок.верх = 70;
		НовыйРисунок.лево = 9;
		НовыйРисунок.РазмерКартинки = РазмерКартинки.Растянуть; 
		НовыйРисунок.ГраницаСверху = Ложь;
		НовыйРисунок.ГраницаСлева = Ложь;
		НовыйРисунок.ГраницаСправа = Ложь;
		НовыйРисунок.ГраницаСнизу = Ложь;	
		
		
		Если колВстр=3 Тогда
			колВСтр=0;
			Если колВКол=2 Тогда
				колВКол=0;
				Таб.ВывестиГоризонтальныйРазделительСтраниц();
			КонецеСЛИ;
			
			Таб.Вывести(Обл);
			колВКол = колВКол+1;
		ИНаче
			Таб.Присоединить(Обл);
		КонецЕСЛИ;
		колВСтр = колВСтр+1;
		
	КонецЦикла;
	
	Таб.ТолькоПросмотр = Истина;
	Таб.ОтображатьГруппировки = Ложь;
	Таб.ОтображатьЗаголовки = Ложь;
	Таб.ОтображатьСетку = Ложь;
	
	Возврат Таб;
	
КонецФункции

Функция СформироватьСтрокуQRКода(сс)
	
	Возврат "!!1!!"+СокрлП(сс.уникальныйИдентификатор())+"!!"+СокрЛП(сс);
	
КонецФункции

#КонецОбласти

#Область ПечатьНакладная
Функция ДанныеДляПечати(ссМас,ссПечФормы) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	роЗаказНаряд.Номер КАК Номер,
	               |	роЗаказНаряд.Дата КАК ДатаДок,
	               |	роЗаказНаряд.ДатаИспытания КАК ДатаИспытанияДок,
	               |	ISNULL(СпрОбрИмя.НаименованиеКА,СпрОбр.Наименование) КАК Оборудование,
	               |    роЗаказНаряд.НомерОборудования КАК НомерОборудования,
	               |    CASE WHEN роЗаказНаряд.НомерОборудования="""" THEN роЗаказНаряд.Номер ELSE роЗаказНаряд.НомерОборудования END КАК НомерОборудованияИлиНомер,
	               |	роЗаказНаряд.ДатаИзготовления КАК ДатаИзготовленияДок,
	               |	роЗаказНаряд.ОписаниеБрака КАК ОписаниеБрака,
	               |	СпрОбр.КодR3 КАК ОборудованиеКодR3,
	               |	СпрОбр.Диаметр КАК Dy,
	               |	СпрОбр.Давление КАК Py,
	               |	СпрОбр.ХодШтока КАК ХодШтока,
	               |	СпрОбр.СтроительнаяДлина КАК СтроительнаяДлина,
	               |	роЗаказНаряд.ИдентификаторСкладаR3 КАК ОборудованиеИдентификатор,
	               |	роЗаказНаряд.Заключение.Наименование КАК Заключение,
	               |	роЗаказНаряд.ВыявленныеДефекты.Наименование КАК ВыявленныеДефекты,
	               |	роЗаказНаряд.Примечание.Наименование КАК Примечание,
	               |	роЗаказНаряд.ПримечаниеСтрока КАК ПримечаниеСтрока,
	               |	роЗаказНаряд.Контрагент.НаименованиеПолное+"" ""+ISNULL(СпрИдСкл.НаименованиеЗаказчикаНаПечать,"""") КАК Контрагент,
	               |	ISNULL(СпрИдСкл.Организация.НаименованиеПолное,роЗаказНаряд.Контрагент.ОрганизацияИсполгитель.НаименованиеПолное) КАК Организация,
				   |	роЗаказНаряд.Испытатель.Наименование КАК фиоИспытатель,
				   |	роЗаказНаряд.Испытатель.Должность КАК длжИспытатель,
				   |	роЗаказНаряд.Мастер.Наименование КАК фиоМастер,
				   |	роЗаказНаряд.Мастер.Должность КАК длжМастер,
				   |	роЗаказНаряд.Контролер.Наименование КАК фиоКонтролер,
	               |	роЗаказНаряд.Контролер.Должность КАК длжКонтролер,
	               |	роЗаказНаряд.Контролер.УдостоверениеНомер КАК УдостоверениеНомер,
	               |	роЗаказНаряд.Контролер.УдостоверениеДата КАК УдостоверениеДата0,
				   |	роЗаказНаряд.Производитель.Наименование КАК Производитель,
	               |	роЗаказНаряд.КлассГерметичности КАК КлассГерметичности,
	               |	роЗаказНаряд.ТипДопОбр КАК ТипДопОбр,
	               |	роЗаказНаряд.НомерАктаДопОбр КАК НомерАктаДопОбр,
	               |	роЗаказНаряд.НомерДопОбр КАК НомерДопОбр,
	               |	роЗаказНаряд.ДатаИзготовленияДопОбр КАК ДатаИзготовленияДопОбр,
	               |	роЗаказНаряд.ДиаметрДопОбр КАК ДиаметрДопОбр,
	               |	роЗаказНаряд.ДавлениеДопОбр КАК ДавлениеДопОбр,
	               |	роЗаказНаряд.ТипДопОбр1 КАК ТипДопОбр1,
	               |	роЗаказНаряд.НомерАктаДопОбр1 КАК НомерАктаДопОбр1,
	               |	роЗаказНаряд.НомерДопОбр1 КАК НомерДопОбр1,
	               |	роЗаказНаряд.ДатаИзготовленияДопОбр1 КАК ДатаИзготовленияДопОбр1,
	               |	роЗаказНаряд.ДиаметрДопОбр1 КАК ДиаметрДопОбр1,
	               |	роЗаказНаряд.ДавлениеДопОбр1 КАК ДавлениеДопОбр1,
	               |	СпрОбр.Родитель Родитель,
	               |	СпрОбр.Родитель.ПроверкаГОСТ ПроверкаГОСТ,
	               |	СпрОбр.Родитель.ПроверкаТипПрибора ПроверкаТипПрибора,
	               |	СпрОбр.Родитель.ПроверкаДатаПрибора ПроверкаДатаПрибора,
				   |    ISNULL(СпрПП.МестоУстановки,роЗаказНаряд.ДокументПоступление.ПунктПогрузки.Наименование) ПунктПогрузки,
				   |    роЗаказНаряд.НомерПружины.Код НомерПружины,
				   |    роЗаказНаряд.НомерПружины.МаксимальнаяНагрузка МаксимальнаяНагрузкаПружины,
				   |    роЗаказНаряд.УстановочноеДавление УстановочноеДавлениеПружины,
				   |    роЗаказНаряд.НомерПружины.Высота ВысотаПружины,
				   |    роЗаказНаряд.НомерПружины.ОсевоеСмещение ОсевоеСмещениеПружины
				   |
				   |
				   |
	               |ИЗ
	               |	Документ.роЗаказНаряд КАК роЗаказНаряд
				   |LEFT OUTER JOIN Справочник.ро_Оборудование.НаименованиеДляКонтрагента СпрОбрИмя ON СпрОбрИмя.ссылка = роЗаказНаряд.Оборудование
				   |                                                                                 и СпрОбрИмя.Контрагент = роЗаказНаряд.Контрагент
				   |                                                                                 и роЗаказНаряд.ОборудованиеКор=Значение(Справочник.ро_Оборудование.ПустаяСсылка) 
				   |
				   |INNER JOIN Справочник.ро_Оборудование СпрОбр ON СпрОбр.ссылка = CASE WHEN роЗаказНаряд.ОборудованиеКор=Значение(Справочник.ро_Оборудование.ПустаяСсылка) 
				   |         																  THEN роЗаказНаряд.Оборудование 
				   |         																  ELSE роЗаказНаряд.ОборудованиеКор END
				   |
				   |LEFT OUTER JOIN Справочник.ро_ИдентификаторСкладаЗаказчика СпрИдСкл ON СпрИдСкл.ссылка = роЗаказНаряд.ИдентификаторСкладаR3 и СпрИдСкл.НаименованиеЗаказчикаНаПечать <> """"
				   |LEFT OUTER JOIN Справочник.ПунктыПогрузки СпрПП ON СпрПП.ссылка = роЗаказНаряд.ДокументПоступление.ПунктПогрузки и СпрПП.МестоУстановки <> """"
				   |
	               |ГДЕ
	               |	роЗаказНаряд.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("ссылка",ссМас);
	
	
	Тбл = запрос.Выполнить().Выгрузить();
	Если Тбл.Количество()=0 Тогда Возврат Неопределено; КонецЕсли;
	Стк = Новый Структура;
	ТекСтр = ТБл[0];
	Для каждого Кол из Тбл.Колонки Цикл
		Стк.Вставить(Кол.имя,текСтр[Кол.имя]);		
	КонецЦикла;
	
	//Проставим дату
	Стк.Вставить("Дата",Формат(Стк.ДатаДок,"ДФ=dd.MM.yyyy"));
	Стк.Вставить("ДатаМес",Формат(Стк.ДатаДок,"ДФ='dd MMMM yyyy'"));
	Стк.Вставить("ДатаИспытания",Формат(Стк.ДатаИспытанияДок,"ДФ=dd.MM.yyyy"));
	Стк.Вставить("ДатаИспытанияМес",Формат(Стк.ДатаИспытанияДок,"ДФ='dd MMMM yyyy'"));
	Стк.Вставить("ДатаИзготовления",Формат(Стк.ДатаИзготовленияДок,"ДФ=dd.MM.yyyy"));
	Стк.Вставить("ДатаИзготовленияДопОбр",Формат(Стк.ДатаИзготовленияДопОбр,"ДФ=dd.MM.yyyy"));
	Стк.вставить("фиоИспытатель",Справочники.ФизическиеЛица.ФИОстр(Стк.фиоИспытатель));
	Стк.вставить("фиоМастер",Справочники.ФизическиеЛица.ФИОстр(Стк.фиоМастер));
	Стк.вставить("фиоКонтролер",Справочники.ФизическиеЛица.ФИОстр(Стк.фиоКонтролер));
	Стк.Вставить("УдостоверениеДата",Формат(Стк.УдостоверениеДата0,"ДФ=dd.MM.yyyy"));
	
	Если Стк.Py<>0 Тогда
		п = Стк.Py/10;
		
		Стк.Вставить("ВеличинаДавленияНаГерметичность",п);//,п);	
		Стк.Вставить("ГерметичностьЗатвора",ОКР(п*1.1,1,1));	
		Стк.Вставить("ВеличинаДавленияНаПрочность",ОКР(п*1.4,1,1));	
		
	КонецЕсли;
	
	Если Стк.УстановочноеДавлениеПружины>12 ТОгда
		Стк.Вставить("УстановочноеДавлениеПружиныИсп",60);
		Стк.Вставить("РабочееДавление",40);
	ИНаче
		Стк.Вставить("УстановочноеДавлениеПружиныИсп",24);
		Стк.Вставить("РабочееДавление",12);
	КонецЕсли;
	
	
	
	Если СОкрЛП(Стк.Py)="0" и СОкрЛП(Стк.Dy)="0" Тогда
		пСтк = Справочники.ро_Оборудование.РазобратьНаименование(Стк.Оборудование);
		Если пСтк<>Неопределено Тогда
			Стк.Вставить("Dy",пСтк.Ч1);
			Стк.Вставить("Py",пСтк.Ч2);
		КонецеСЛИ;
	КонецеСЛИ;
	
	Если СокрЛП(Стк.КлассГерметичности) = "" Тогда
		Стк.КлассГерметичности = "A";
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Стк.Организация)=Ложь Тогда
		Стк.Организация = "ООО ""НАРС""";
	КонецЕсли;
	
	Если СокрЛП(Стк.НомерОборудования)<>"" Тогда
		Стк.вставить("НадписьЗаводскойНомер","Заводской №");
	КонецЕСлИ;
	
	Если Стк.ДатаИзготовленияДок<>Дата(1,1,1) Тогда
		Стк.вставить("НадписьДатаИзготовления","Дата изготовления");
	КонецЕСлИ;
	
	ЗаполнитьДефекты(Стк,ссМас);
	
	Возврат Стк;
	
	
КонецФункции

Процедура ЗаполнитьДефекты(Стк,ссМас)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ро_ОборудованиеДефектовка.Деталь.Наименование КАК Деталь,
	               |	ро_ОборудованиеДефектовка.ТипМаркаДетали КАК ТипМаркаДетали,
	               |	ро_ОборудованиеДефектовка.Количество КАК ДетальКоличество
	               |ИЗ
	               |	Справочник.ро_Оборудование.Дефектовка КАК ро_ОборудованиеДефектовка
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.роЗаказНаряд КАК роЗаказНаряд
	               |		ПО ро_ОборудованиеДефектовка.Ссылка = роЗаказНаряд.Оборудование.РОдитель
				   |         и ро_ОборудованиеДефектовка.ТипМаркаДетали<>""""
				   |         и роЗаказНаряд.Ссылка = &Ссылка
				   |
				   |";
	
	Запрос.УстановитьПараметр("ссылка",ссМас);
	
	
	Тбл = запрос.Выполнить().Выгрузить();
	Для а=1 по Тбл.Количество() Цикл
		текСтр = Тбл[а-1];
		Для каждого Кол из Тбл.Колонки Цикл
			Стк.Вставить(""+Кол.имя+а,текСтр[Кол.имя]);		
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры	

Функция ПечатьНакладная(Мас,Макет,ссПечФормы) Экспорт
	
	
	
	СткШапка = ДанныеДляПечати(Мас,ссПечФормы);
	Таб = Новый ТабличныйДокумент;
	Таб.КлючПараметровПечати = "роПечатьНакладнаяЗаказНаряд"+СокрлП(ссПечФормы);
	Если СткШапка=Неопределено Тогда Возврат Таб; КонецЕсли;
	
	Обл = Макет.ПолучитьОбласть("Строка");
	Обл.Параметры.Заполнить(СткШапка);
	Таб.Вывести(Обл);
	СткДоп = Новый Структура();
	
	Если СокрлП(СткШапка.ТипДопОбр)<>"" Тогда
		Таб.ВывестиГоризонтальныйРазделительСтраниц();
		СткДоп.Вставить("Номер",СткШапка.НомерАктаДопОбр);
		СткДоп.Вставить("Оборудование",СткШапка.ТипДопОбр);
		СткДоп.Вставить("НомерОборудования",СткШапка.НомерДопОбр);
		СткДоп.Вставить("ДатаИзготовления",СткШапка.ДатаИзготовленияДопОбр);
		СткДоп.Вставить("Dy",СткШапка.ДиаметрДопОбр);
		СткДоп.Вставить("Py",СткШапка.ДавлениеДопОбр);
		Обл.Параметры.Заполнить(СткДоп);
		Таб.Вывести(Обл);
	КонецЕслИ;
	Если СокрлП(СткШапка.ТипДопОбр1)<>"" Тогда
		Таб.ВывестиГоризонтальныйРазделительСтраниц();
		СткДоп.Вставить("Номер",СткШапка.НомерАктаДопОбр1);
		СткДоп.Вставить("Оборудование",СткШапка.ТипДопОбр1);
		СткДоп.Вставить("НомерОборудования",СткШапка.НомерДопОбр1);
		СткДоп.Вставить("ДатаИзготовления",СткШапка.ДатаИзготовленияДопОбр1);
		СткДоп.Вставить("Dy",СткШапка.ДиаметрДопОбр1);
		СткДоп.Вставить("Py",СткШапка.ДавлениеДопОбр1);
		Обл.Параметры.Заполнить(СткДоп);
		Таб.Вывести(Обл);
	КонецЕслИ;
	
	Таб.ТолькоПросмотр = Истина;
	Таб.ОтображатьГруппировки = Ложь;
	Таб.ОтображатьЗаголовки = Ложь;
	Таб.ОтображатьСетку = Ложь;
	Таб.АвтоМасштаб = Истина;
	
	Возврат Таб;
	
	
	
КонецФункции
#КонецОбласти

#Область ПечатьДефектовка

Функция ДанныеДефектовка(сс)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	роЗаказНаряд.Номер КАК Номер,
	               |	роЗаказНаряд.Дата КАК Дата,
	               |	роЗаказНаряд.ДатаИспытания КАК ДатаИспытания,
	               |	роЗаказНаряд.Контрагент.НаименованиеПолное КАК Контрагент,
	               |	ISNULL(СпрИдСкл.Организация.НаименованиеПолное,роЗаказНаряд.Контрагент.ОрганизацияИсполгитель.НаименованиеПолное) КАК Организация,
	               |	CASE WHEN роЗаказНаряд.ОборудованиеКор=Значение(Справочник.ро_Оборудование.ПустаяСсылка) 
				   |         THEN роЗаказНаряд.Оборудование 
				   |         ELSE роЗаказНаряд.ОборудованиеКор END КАК Оборудование,
	               |	роЗаказНаряд.НомерОборудования КАК НомерОборудования,
	               |	CASE WHEN роЗаказНаряд.ИнвНомерКор="""" THEN роЗаказНаряд.ИнвНомер ELSE роЗаказНаряд.ИнвНомерКор END  КАК ИнвНомер,
	               |	роЗаказНарядДефектовка.Деталь КАК Деталь,
	               |	роЗаказНарядДефектовка.Количество КАК Количество,
	               |	роЗаказНарядДефектовка.Дефект КАК Дефект,
	               |	роЗаказНарядДефектовка.Годен КАК Годен,
	               |	роЗаказНарядДефектовка.Реставрация КАК Реставрация,
	               |	роЗаказНарядДефектовка.Изготовление КАК Изготовление,
	               |	роЗаказНарядДефектовка.Покупка КАК Покупка,
	               |	ВЫБОР
	               |		КОГДА роЗаказНарядДефектовка.Годен = ЛОЖЬ
	               |			ТОГДА роЗаказНарядДефектовка.Количество
	               |		ИНАЧЕ """"
	               |	КОНЕЦ КАК колНеГоден,
	               |	роЗаказНаряд.Контролер КАК КонтролерСТК,
	               |	роЗаказНаряд.Контролер.Должность КАК длжКонтролерСТК,
	               |	роЗаказНаряд.Контрагент.Подписант КАК каФИО,
	               |	роЗаказНаряд.Контрагент.ПодписантДолжность КАК каДлж
	               |ИЗ
	               |	Документ.роЗаказНаряд.Дефектовка КАК роЗаказНарядДефектовка
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.роЗаказНаряд КАК роЗаказНаряд
	               |		ПО роЗаказНарядДефектовка.Ссылка = роЗаказНаряд.Ссылка
				   |
				   |LEFT OUTER JOIN Справочник.ро_ИдентификаторСкладаЗаказчика СпрИдСкл ON СпрИдСкл.ссылка = роЗаказНаряд.ИдентификаторСкладаR3
				   |
				   |
	               |ГДЕ
	               |	роЗаказНаряд.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("ссылка",сс);
	
	ТБл = Запрос.Выполнить().Выгрузить();
	
	Стк = Новый Структура("НомерОборудования,ИнвНомер");
	ДЛя каждого Стр из ТБл Цикл
		Для каждого Кол из Тбл.Колонки Цикл
			Стк.вставить(Кол.Имя,Стр[Кол.имя]);
		Конеццикла;
		Стк.вставить("КонтролерСТК",СПравочники.ФизическиеЛица.ФИОстр(Стр.КонтролерСТК));
		Стк.вставить("каФИО",СПравочники.ФизическиеЛица.ФИОстр(Стр.каФИО));
		Стк.вставить("Дата",Формат(Стр.Дата,"ДФ=dd.MM.yyyy"));
		Стк.вставить("ДатаИспытания",Формат(Стр.ДатаИспытания,"ДФ=dd.MM.yyyy"));
		Стк.вставить("ДатаМес",Формат(Стр.Дата,"ДФ='dd MMMM yyyy'"));
		
		прервать;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(Стк.Организация)=Ложь Тогда
		Стк.вставить("Организация","ООО ""НАРС"" ");
	КонецЕсли;
	Стк.вставить("Тбл",Тбл);
	
	
	Если СокрЛП(Стк.НомерОборудования) <> "" Тогда
		Стк.НомерОборудования = "Зав.№"+Стк.НомерОборудования;
	КонецеСЛИ;
	Если СокрЛП(Стк.ИнвНомер) <> "" Тогда
		Стк.ИнвНомер = "Инв.№"+Стк.ИнвНомер;
	КонецеСЛИ;
	
	Возврат Стк;
	
КонецФункции


Функция ПечатьДефектовка(сс,СткДопИнфо=Неопределено) Экспорт
	
	 Макет = Документы.роЗаказНаряд.ПолучитьМакет("ДефВедомость");
	 
	 облШапка = Макет.ПолучитьОбласть("Шапка");
	 облСтрока= Макет.ПолучитьОбласть("Строка");
	 облПодвал= Макет.ПолучитьОбласть("Подвал");
	
	СткШапка = ДанныеДефектовка(сс);
	Если СткДопИНфо<>Неопределено Тогда
		Для каждого эл из СткДопИнфо Цикл
			СткШапка.Вставить(Эл.Ключ,Эл.Значение);	
		Конеццикла;
	КонецЕсли;
	
	Таб = Новый ТабличныйДокумент;
	Таб.КлючПараметровПечати = "роПечатьДефектовка";
	Если СткШапка=Неопределено Тогда Возврат Таб; КонецЕсли;
	
	ОблШапка.Параметры.Заполнить(СткШапка);
	Таб.Вывести(облШапка);
	ном = 0;
	Для каждого Стр из СткШАпка.Тбл Цикл
		ном = ном+1;
		облСтрока.Параметры.Заполнить(стр);
		облСтрока.Параметры.ном = ном;;
		Таб.Вывести(облСтрока);
	КонецЦикла;
	облПодвал.Параметры.Заполнить(СткШапка);
	Таб.Вывести(облПодвал);
	
	Таб.ТолькоПросмотр = Истина;
	Таб.ОтображатьГруппировки = Ложь;
	Таб.ОтображатьЗаголовки = Ложь;
	Таб.ОтображатьСетку = Ложь;
	
	Возврат Таб;
	
	
	
КонецФункции

#КонецОбласти

Функция ДокументСоздатьПоПараметрам(Стк,ссДок,ПредСтатус,ТекСтатус) Экспорт
	
	Обк = Документы.роЗаказНаряд.СоздатьДокумент();
	ЗаполнитьЗначенияСвойств(Обк,Стк);
	Обк.Дата = ссДок.Дата;
	Обк.Контрагент = ссДок.Контрагент;
	Обк.НомерТТНвходящий = ссДок.НомерТТНвходящий;
	Обк.Ответственный = ссДок.Ответственный;
	Обк.ДокументПоступление = ссДок;
	
	Если Обк.Статус = ПредСтатус Тогда
		Обк.Статус = ТекСтатус;
	КонецЕсли;
	
	Обк.Записать();
	
	Возврат Обк.ссылка;
	
КонецФункции

Процедура ОбновитьДанныеДокумента(ссДок,Стк,ПредСтатус,ТекСтатус) Экспорт
	
	Обк = ссДок.ПолучитьОбъект();
	ЗаполнитьЗначенияСвойств(Обк,Стк);
	
	Если Обк.Статус = ПредСтатус Тогда
		Обк.Статус = ТекСтатус;
	КонецЕсли;
	
	Обк.Записать();
	
КонецПроцедуры