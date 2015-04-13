-- Лабораторная №5.
-- Вариант №15 по дисциплине "Базы данных".
-- СПБ ГУАП 2015.

-- Группы, у которых количество занятий во вторник превышает семь пар;

SELECT n_group, day_of_week
FROM class
GROUP BY n_group, day_of_week
HAVING (Count(day_of_week) > 1) AND (day_of_week = 'вт');

-- Среднее количество пар для заданной группы;

SELECT AVG(count_d) FROM (
	SELECT Count(id) AS count_d
	FROM class
	GROUP BY n_group, day_of_week
	HAVING (n_group = 3241)) A
	

-- Аудитории, в которых занимается максимальное количество групп;

SELECT audience
FROM class
GROUP BY audience
HAVING (Count(audience) =
	(SELECT Max(A.count_d) as maxim
	FROM 
		(SELECT Count(audience) AS count_d
			FROM class 
			GROUP BY audience
		) AS A
	))
	
-- intersect 

SELECT *
FROM class
WHERE audience = 32

INTERSECT 

SELECT *
FROM class
WHERE n_group = 4231

-- except 

SELECT *
FROM class
WHERE audience = 32

EXCEPT

SELECT *
FROM class
WHERE n_group = 4231

-- union 

SELECT *
FROM class
WHERE audience = 32

UNION

SELECT *
FROM class
WHERE n_group = 4231
