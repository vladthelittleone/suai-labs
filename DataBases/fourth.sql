-- Лабораторная №3.
-- Вариант №15 по дисциплине "Базы данных".
-- СПБ ГУАП 2015.

-- Перечень занятий для заданной группы на завтра

SELECT type_of_class, day_of_week, n_group
FROM class
WHERE (((day_of_week)='пн') AND ((n_group)=4231));
GO

-- Списки аудиторий по корпусам

SELECT audience, corps
FROM audience;
GO

-- Группы, у которых в один день есть и лабораторные и курсовое проектирование

SELECT DISTINCT uni_group.group_id, class1.day_of_week
FROM class AS class1, class 
INNER JOIN uni_group 
	ON class.n_group = uni_group.group_id
WHERE (((class.type_of_class)='курс') 
	AND ((class1.type_of_class)='лаб') 
	AND ((class.day_of_week)=class1.day_of_week) 
	AND ((class.n_group)=class1.n_group));
GO

-- [not]  in

SELECT DISTINCT *
FROM class 
WHERE n_group 
	NOT IN (4231, 4232, 4241, 1211, 1221, 1231, 1241, 3211, 3221);
GO

-- [not] like

SELECT DISTINCT *
FROM class 
WHERE n_group 
	LIKE '421%';
GO

-- [43]

SELECT DISTINCT *
FROM class 
WHERE n_group 
	LIKE '[43]%';
GO

-- ^

SELECT DISTINCT *
FROM class 
WHERE n_group 
	LIKE '[^4]%';
GO

-- BEETWEEN <> AND <> 

SELECT DISTINCT *
FROM class 
WHERE n_group 
	BEETWEEN 1000 AND 2000;
GO


