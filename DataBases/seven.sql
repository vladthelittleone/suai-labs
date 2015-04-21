-- Лабораторная №7.
-- Вариант №15 по дисциплине "Базы данных".
-- СПБ ГУАП 2015.

-- вставку с пополнением справочников (вставляется информация о аудитории, 
-- если указанный номер корпуса  отсутствует в БД, запись добавляется в таблицу с перечнем корпусов)

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

-- Удаление с очисткой справочников (удаляется информация о аудитории, если в 
-- ее корпусе нет больше аудиторий, запись удаляется из таблицы с перечнем корпусов)

CREATE PROCEDURE del_audience @audience INT
AS
DECLARE @idCorps INT
SELECT @idCorps = corps FROM audience WHERE audience = @audience 
DELETE FROM audience WHERE audience =@audience 

PRINT @idCorps
IF NOT EXISTS ( SELECT corps FROM audience WHERE corps=@idCorps ) 
BEGIN
	DELETE FROM corps WHERE corps=@idCorps
END
GO

EXEC del_audience 36
GO

-- Каскадное удаление (при наличии условия ссылочной целостности noaction перед 
-- удалением записи о факультете  удаляются записи о всех занятиях и группах этого факультета)

CREATE PROCEDURE del_faculty @nameFaculty char(1)
AS
DELETE FROM class where n_group in
(SELECT group_id FROM uni_group
  WHERE faculty = @nameFaculty)

DELETE FROM uni_group WHERE faculty = @nameFaculty
DELETE FROM faculty WHERE faculty = @nameFaculty
GO

EXEC del_faculty '4'
GO

-- Вычисление и возврат значения агрегатной функции (на примере одного из запросов из задания: 
-- среднее количество пар для заданной группы)

ALTER PROCEDURE group_avg @group_id INT,@result FLOAT=0 OUT 
AS 
SELECT @result=AVG(count_d) FROM (
	SELECT Count(id) AS count_d
	FROM class
	WHERE (n_group=@group_id)) A
GO 

DECLARE @x FLOAT
EXEC group_avg 3241,@x OUT
SELECT @x
GO

-- Формирование статистики во временной таблице (для каждого факультета: 
-- название факультета, количество групп)

CREATE PROCEDURE faculty_stat
AS 
BEGIN
	CREATE TABLE #Statistics (faculty VARCHAR(50),group_count INT)
	INSERT INTO #Statistics (faculty,group_count)
	SELECT faculty, COUNT(DISTINCT group_id)
	FROM uni_group
	GROUP BY faculty
	SELECT * FROM #Statistics
END
GO

faculty_stat
GO

-- Пакетные задания (создание, заполнение и выборку из таблицы)

CREATE TABLE #Statistics (faculty VARCHAR(50),group_count INT)
INSERT INTO #Statistics (faculty,group_count)
SELECT faculty, COUNT(DISTINCT group_id)
FROM uni_group
GROUP BY faculty
IF EXISTS (
	SELECT * FROM #Statistics
	WHERE group_count < 4)
BEGIN 
	PRINT 'Существуют факультеты с кол-вом групп меньше 4'
END

ELSE 
BEGIN
	PRINT 'Не существуют факультеты с кол-вом групп меньше 4'
END
