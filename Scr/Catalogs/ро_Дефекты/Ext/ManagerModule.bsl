Функция ЭлементПоУмолчанию() Экспорт
	
	сс = Справочники.ро_Дефекты.НайтиПоКоду(1);
	Если сс.Пустая() Тогда
		Обк = Справочники.ро_Дефекты.СоздатьЭлемент();
		обк.код = 1;
		обк.Наименование = "Не обнаружено";
		Обк.Записать();
		сс = обк.Ссылка;
	КонецЕСЛИ;
	
	Возврат сс;
	
КонецФункции