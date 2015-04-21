-- Лабораторная №8.
-- Вариант №15 по дисциплине "Базы данных".
-- СПБ ГУАП 2015.

-- instead of insert

CREATE TRIGGER inst_class
		ON class
		INSTEAD OF INSERT
AS
IF EXISTS (SELECT class.n_group	FROM class
		WHERE class.n_group IN (SELECT n_group FROM inserted)
		GROUP BY class.n_group
		HAVING COUNT( n_group ) >= 4)
PRINT 'Слишком много занятий'
ELSE
INSERT INTO class (audience, day_of_week, n_group, type_of_class) 
SELECT audience, day_of_week, n_group, type_of_class FROM inserted

GO
INSERT INTO class (audience, day_of_week, n_group, type_of_class) VALUES(31, 'вт', 3221, 'лаб')
GO

-- for insert 

CREATE TRIGGER for_class
		ON class
		FOR INSERT
AS
SELECT n_group, COUNT ( audience ) AS 'Количество аудиторий' 
FROM class
GROUP BY n_group
GO


INSERT INTO class (audience, day_of_week, n_group, type_of_class) VALUES (21, 'вт', 2211, 'лаб')
GO

-- instead of delete

CREATE TRIGGER del_group
		ON uni_group 
		INSTEAD OF DELETE
AS
    IF EXISTS( SELECT group_id FROM deleted WHERE group_id in (SELECT n_group FROM class))
		PRINT 'Невозможно удалить группу';
	ELSE 
		DELETE FROM uni_group WHERE group_id in (SELECT group_id FROM deleted)
GO

DELETE FROM uni_group WHERE group_id = 3231

GO

-- instead of update

CREATE TRIGGER corps_update
		ON corps 
		INSTEAD OF UPDATE
AS
BEGIN
	IF UPDATE(corps)
		BEGIN
			IF  EXISTS (
				SELECT corps 
				FROM inserted  
				WHERE corps IN (SELECT corps FROM corps ))
		
					UPDATE corps SET corps = inserted.corps  
					FROM corps, inserted 
					WHERE corps.corps = inserted.corps

			ELSE

					PRINT 'Невозможно изменить значение на неизвестное корпус'

		END
END

GO

UPDATE corps 
SET
corps = 5555
GO

-- after delete

CREATE TRIGGER dell_after
		ON class
		AFTER DELETE
AS
DELETE audience
WHERE audience IN (SELECT audience FROM deleted 
		      WHERE audience NOT IN (SELECT audience FROM class))
GO

DELETE FROM class where audience=32

-- after  update 

CREATE TRIGGER after_update 
		ON corps 
		AFTER UPDATE
AS
IF UPDATE(corps)
BEGIN
	SELECT corps, COUNT(corps) 
	FROM audience 
	WHERE corps IN (SELECT corps FROM inserted )
	GROUP BY corps 
END

ELSE ROLLBACK TRANSACTION

GO

UPDATE corps
SET corps = 2 where corps = 7

