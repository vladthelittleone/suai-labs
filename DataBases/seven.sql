-- вставку с пополнением справочников (вставляется информация о аудитории, 
-- если указанный номер корпуса  отсутствует в БД, запись добавляется в таблицу с перечнем корпусов);

CREATE PROCEDURE add_audience @audience INT,@corps CHAR(1)
AS
BEGIN
	IF not exists (SELECT * FROM corps WHERE  corps = @corps)
		BEGIN
			PRINT 'No corpus with given id = ' + @corps
			INSERT INTO corps(corps) VALUES (@corps)
		END

	INSERT INTO audience(audience, corps) VALUES(@audience, @corps) 
END
GO

exec add_audience 36, 6
GO
