//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ
//



&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	// Установка значения реквизита АдресКартинки.
	ФайлКартинки = Объект.ФайлКартинки;
	Если НЕ ФайлКартинки.Пустая() Тогда
		АдресКартинки = ПолучитьНавигационнуюСсылку(ФайлКартинки, "ДанныеФайла")
	Конецесли;
		
	ОпределитьДоступнность(ЭтотОбъект); 
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
#Если Не МобильныйАвтономныйСервер Тогда
	ЗаписатьХарактеристики();
#КонецЕсли
	Установлен = Ложь;
#Если Не МобильныйАвтономныйСервер Тогда
	Если ПараметрыЗаписи.Свойство("Уведомление", Установлен) И Установлен Тогда
		Уведомление = Новый ДоставляемоеУведомление();
		Уведомление.Текст = НСтр("ru = 'Добавлен новый товар'", "ru");
		Уведомление.Данные = "1";
		Проблемы = Новый Массив;
        УведомленияСервер.ОтправитьУведомление(Уведомление, Неопределено, Проблемы);
	КонецЕсли;
#КонецЕсли
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	КартинкиИзменены = Ложь;
	КартинкиОписания.Очистить();
	
КонецПроцедуры
	
&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
КонецПроцедуры

&НаКлиенте
Процедура ФайлКартинкиПриИзменении(Элемент)

	// Отслеживание изменения картинки и соответствующее обновление
	// реквизита АдресКартинки.
	ФайлКартинки = Объект.ФайлКартинки;
	Если НЕ ФайлКартинки.Пустая() Тогда
		АдресКартинки = ПолучитьНавигационнуюСсылку(ФайлКартинки, "ДанныеФайла")
	Иначе
		АдресКартинки = "";
	Конецесли;

КонецПроцедуры

&НаКлиенте
Процедура ВидПриИзменении(Элемент)
	ОпределитьДоступнность(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ФайлКартинкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	Если Объект.Ссылка.Пустая() Тогда
		СтандартнаяОбработка = Ложь;
		ОбработкаНеВыбораКартинки();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Асинх Процедура ОбработкаНеВыбораКартинки()
	Ждать ПредупреждениеАсинх(НСтр("ru = 'Данные не записаны'", "ru"));
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////// 
// Процедуры и функции формы

//Расстановка признака доступность элементов в зависимости от того, редактируется  
//товар ИЛИ услуга
&НаКлиентеНаСервереБезКонтекста
Процедура ОпределитьДоступнность(Форма)

	ДоступностьРеквизитовТовара = Форма.Объект.Вид = ПредопределенноеЗначение("Перечисление.ВидыТоваров.Товар");
	Форма.Элементы.ШтрихКод.Доступность = ДоступностьРеквизитовТовара;
	Форма.Элементы.Поставщик.Доступность = ДоступностьРеквизитовТовара;
	Форма.Элементы.Артикул.Доступность = ДоступностьРеквизитовТовара;

КонецПроцедуры

#Если Не МобильныйКлиент Тогда

&НаКлиенте
Процедура ДобавитьХарактеристику(Команда)
	
	//Выберем вид характеристики
	Оповещение = Новый ОписаниеОповещения(
		"ДобавитьХарактеристикуЗавершение",
		ЭтотОбъект);
	ОткрытьФорму("ПланВидовХарактеристик.ВидыХарактеристик.ФормаВыбора",
		,,,,, Оповещение, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьХарактеристикуЗавершение(ВидХарактеристики, Параметры) Экспорт
	Если ВидХарактеристики = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ВыполнитьДобавлениеХарактеристики(ВидХарактеристики);
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьДобавлениеХарактеристики(ВидХарактеристики)
	//Проверим наличие 
	Если ОписаниеХарактеристик.НайтиСтроки(
		 Новый Структура("ВидХарактеристики", ВидХарактеристики)).Количество() > 0 Тогда
		 Ждать ПредупреждениеАсинх(НСтр("ru = 'Характеристика уже существует!'", "ru"));
		 Возврат;
	КонецЕсли;	 
	//Добавим вид характеристики на форму
	ДобавитьХарактеристикуНаСервере(ВидХарактеристики);
КонецПроцедуры

&НаКлиенте
Процедура УдалитьХарактеристику(Команда)
	ВыполнитьУдалениеХарактеристики();
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьУдалениеХарактеристики()
	//Выберем удаляемый вид
	СписокВидов = Новый СписокЗначений;
	Для каждого ОписаниеХарактеристики Из ОписаниеХарактеристик Цикл
		ЭлементСпискаВидов = СписокВидов.Добавить();
		ЭлементСпискаВидов.Значение = ОписаниеХарактеристики.ПолучитьИдентификатор();
		ЭлементСпискаВидов.Представление = Строка(ОписаниеХарактеристики.ВидХарактеристики);
	КонецЦикла;
	ВыбранныйЭлемент = Ждать СписокВидов.ВыбратьЭлементАсинх("Удалить характеристику:");
	//Проверим выбор
	Если ВыбранныйЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	//Выполним удаление
	УдалитьХарактеристикуНаСервере(ВыбранныйЭлемент.Значение);
КонецПроцедуры

#КонецЕсли

#Если Не МобильныйАвтономныйСервер Тогда

&НаСервере
Процедура ДобавитьХарактеристикуНаСервере(ВидХарактеристики)
	
	//Добавление реквизита
	ДобавляемыеРеквизиты = Новый Массив();
	ИмяХарактеристики = "Характеристика" + ВидХарактеристики.Код;
	Если ВидХарактеристики.Множественная Тогда
		Реквизит = Новый РеквизитФормы(ИмяХарактеристики,
				Новый ОписаниеТипов("СписокЗначений"), , , Истина);
	Иначе
		Реквизит = Новый РеквизитФормы(ИмяХарактеристики,
				ВидХарактеристики.ТипЗначения, , , Истина);
	КонецЕсли;
	ДобавляемыеРеквизиты.Добавить(Реквизит);
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	Если ВидХарактеристики.Множественная Тогда
		ЭтотОбъект[ИмяХарактеристики].ТипЗначения = ВидХарактеристики.ТипЗначения;
	КонецЕсли;
	
	//Добавление элемента, заполнение данных
	Элемент = Элементы.Добавить(
					  ИмяХарактеристики,
					  Тип("ПолеФормы"), Элементы.ГруппаХарактеристики); 	
	Элемент.Вид = ВидПоляФормы.ПолеВвода;
	Элемент.Заголовок = ВидХарактеристики.Наименование;
	Элемент.ПутьКДанным = ИмяХарактеристики;
	
	МассивПараметровВыбора = Новый Массив();
	МассивПараметровВыбора.Добавить(Новый ПараметрВыбора("Отбор.Владелец", ВидХарактеристики));
	Элемент.ПараметрыВыбора = Новый ФиксированныйМассив(МассивПараметровВыбора);
	
	//Добавление описания характеристики
	ОписаниеХарактеристики = ОписаниеХарактеристик.Добавить();
	ОписаниеХарактеристики.ВидХарактеристики = ВидХарактеристики;
	ОписаниеХарактеристики.ИмяРеквизита = ИмяХарактеристики;
	
	//Новый элемент установим текущим
	ТекущийЭлемент = Элемент;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьХарактеристикуНаСервере(Идентификатор)
	
	ОписаниеХарактеристики = ОписаниеХарактеристик.НайтиПоИдентификатору(Идентификатор);
	ИмяРеквизита = ОписаниеХарактеристики.ИмяРеквизита;
	
	//Удаление описания
	ОписаниеХарактеристик.Удалить(ОписаниеХарактеристики);
	
	//Удаление элемента
	Элементы.Удалить(Элементы.Найти(ИмяРеквизита));
	
	//Удаление реквизита
	УдаляемыеРеквизиты = Новый Массив();
	УдаляемыеРеквизиты.Добавить(ИмяРеквизита);
	ИзменитьРеквизиты(, УдаляемыеРеквизиты);
	
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьХарактеристики()

	//Сформируем набор записей с новыми значениями характеристик
	НаборЗаписей = РегистрыСведений.Характеристики.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Объект.Установить(Объект.Ссылка);
	Для каждого ОписаниеХарактеристики Из ОписаниеХарактеристик Цикл

		ЗначениеХарактеристики = ЭтотОбъект[ОписаниеХарактеристики.ИмяРеквизита];
		Если ТипЗнч(ЗначениеХарактеристики) = Тип("СписокЗначений") Тогда
			Номер = 0;
			Для Каждого Элемент Из ЗначениеХарактеристики Цикл
				Запись = НаборЗаписей.Добавить();
				Запись.Объект = Объект.Ссылка;
				Запись.ВидХарактеристики = ОписаниеХарактеристики.ВидХарактеристики;
				Запись.Значение = Элемент.Значение;
				Запись.Номер = Номер;
				Номер = Номер + 1;
			КонецЦикла;
		Иначе
			Запись = НаборЗаписей.Добавить();
			Запись.Объект = Объект.Ссылка;
			Запись.ВидХарактеристики = ОписаниеХарактеристики.ВидХарактеристики;
			Запись.Значение = ЗначениеХарактеристики;
		КонецЕсли;
		
	КонецЦикла;
	
	//Запишем набор записей
	НаборЗаписей.Записать();

КонецПроцедуры

#КонецЕсли

&НаКлиенте
Процедура ОбновитьКартинку(Команда)

	Элементы.Картинка.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура КартинкаПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура КартинкаПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ПеретаскиваемоеЗначение = ПараметрыПеретаскивания.Значение;

	Если ТипЗнч(ПеретаскиваемоеЗначение) = Тип("Массив") Тогда
		Если ПеретаскиваемоеЗначение.Количество() > 0 Тогда
			ПеретаскиваемаяКартинка = ПеретаскиваемоеЗначение[0];
		Иначе
			Возврат;
		КонецЕсли;
	Иначе 
		ПеретаскиваемаяКартинка = ПеретаскиваемоеЗначение;
	КонецЕсли;
	ПоместитьФайлНаСервер(ПеретаскиваемаяКартинка);
КонецПроцедуры

&НаКлиенте
Асинх Процедура ПоместитьФайлНаСервер(ПеретаскиваемаяКартинка)
	Если ТипЗнч(ПеретаскиваемаяКартинка) = Тип("СсылкаНаФайл") Тогда
		Расширение = ВРег(ПеретаскиваемаяКартинка.Расширение);
		Если Не (Расширение = ".PNG" ИЛИ Расширение = ".JPG" ИЛИ Расширение = ".JPEG" ИЛИ Расширение = ".GIF" ИЛИ Расширение = ".BMP") Тогда
			Ждать ПредупреждениеАсинх(НСтр("ru = 'Пожалуйста, перетащите картинку'", "ru"));
			Возврат;
		КонецЕсли;
		
		Если ПеретаскиваемаяКартинка.Размер() > 1024 * 1024 * 5 Тогда
			Ждать ПредупреждениеАсинх(НСтр("ru = 'Превышен максимальный размер (5МБ) картинки'", "ru"));
			Возврат;
		КонецЕсли;
	Иначе
		Ждать ПредупреждениеАсинх(НСтр("ru = 'Пожалуйста, перетащите файл'", "ru"));
		Возврат
	КонецЕсли;
	
	Если Объект.Ссылка.Пустая() Тогда
		Ждать ПредупреждениеАсинх(НСтр("ru = 'Данные не записаны'", "ru"));
		Возврат;
	Иначе
		Попытка
			ОписаниеПомещенногоФайла = Ждать ПоместитьФайлНаСерверАсинх(,,, ПеретаскиваемаяКартинка, УникальныйИдентификатор);
		Исключение
			Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка помещения файла на сервер'", "ru"));
			Возврат;
		КонецПопытки;
		Если Не ОписаниеПомещенногоФайла = Неопределено Тогда
			ПослеПомещенияФайлаНаСервере(ОписаниеПомещенногоФайла.Адрес, ОписаниеПомещенногоФайла.СсылкаНаФайл.Имя);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПослеПомещенияФайлаНаСервере(Адрес, ВыбранноеИмяФайла)
	ХранимыйФайл = Справочники.ХранимыеФайлы.СоздатьЭлемент();
	ХранимыйФайл.Владелец = Объект.Ссылка;
	ХранимыйФайл.Наименование = ВыбранноеИмяФайла;
	ХранимыйФайл.ИмяФайла = ВыбранноеИмяФайла;
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(Адрес);
	ХранимыйФайл.ДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных());
	ХранимыйФайл.Записать(); 
	Объект.ФайлКартинки = ХранимыйФайл.Ссылка;
	АдресКартинки = ПолучитьНавигационнуюСсылку(ХранимыйФайл.Ссылка, "ДанныеФайла");
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ПриПереоткрытииСДругогоСервера(ИсходнаяФорма, ПараметрыЗаполнения, СтандартнаяОбработка)
	ПараметрыЗаполнения.ИсключитьРеквизиты.Добавить("Вес");
КонецПроцедуры
