Функция ЭлементПоУмолчанию() Экспорт
	
	сс = Справочники.ро_Заключения.НайтиПоКоду(1);
	Если сс.Пустая() Тогда
		Обк = Справочники.ро_Заключения.СоздатьЭлемент();
		обк.код = 1;
		обк.Наименование = "К эксплуатации пригодна";
		Обк.Записать();
		сс = обк.Ссылка;
	КонецЕСЛИ;
	
	Возврат сс;
	
КонецФункции