Функция ПолучитьОписаниеПараметров(Зап) Экспорт
	
			Стр = "";
		
		Если Зап.ДиаметрОт=0 и Зап.ДиаметрДо=0 Тогда
		//	Стр = Стр+"любой";
		ИНаче
			Стр = Стр+"Ду "+Формат(Зап.ДиаметрОт,"ЧГ=0");
			
			ЕСли Зап.ДиаметрОт=Зап.ДиаметрДо ТОгда
				
			ИначеЕсли Зап.ДиаметрДо=0 ТОгда
				Стр = Стр+" и более";
			ИНАче
				Стр = Стр+"-"+Формат(Зап.ДиаметрДо,"ЧГ=0");
			КонецЕсли;
		КонецЕСЛИ;
		
		//Стр = прав("                "+Стр,11);
		
		Если Зап.ДавлениеОт=0 и Зап.ДавлениеДо=0 Тогда
		//	Стр = Стр+"любой";
		ИНаче
			Стр = Стр+" Ру "+Формат(Зап.ДавлениеОт,"ЧГ=0");
			
			ЕСли Зап.ДавлениеОт=Зап.ДавлениеДо ТОгда
				
			ИначеЕсли Зап.ДавлениеДо=0 ТОгда
				Стр = Стр+" и более";
			ИНАче
				Стр = Стр+"-"+Формат(Зап.ДавлениеДо,"ЧГ=0");
			КонецЕсли;
		КонецЕсли;
		
		
		Возврат Стр;
		

	
КонецФункции