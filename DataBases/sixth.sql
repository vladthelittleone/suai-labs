-- Лабораторная №6.
-- Вариант №15 по дисциплине "Базы данных".
-- СПБ ГУАП 2015.

-- Группы, у которых во вторник все пары проходят в одном корпусе

SELECT g
FROM (
	SELECT DISTINCT n_group AS g, corp
	FROM class, 
		(
		SELECT corps AS corp, audience.audience AS aud
		FROM audience
		) AS a
	WHERE day_of_week = 'вт' AND class.audience = a.aud
) AS b
GROUP BY g
HAVING COUNT(corp) = 1

-- Аудитории, в которых никогда не занимаются студенты четвертого факультета

SELECT audience 
FROM audience
WHERE audience NOT IN (
	SELECT audience
	FROM uni_group, class
	WHERE uni_group.faculty = 4 AND uni_group.group_id = class.n_group
)

-- Группы, у которых нет занятий по субботам

SELECT DISTINCT n_group 
FROM class
WHERE n_group NOT IN (
	SELECT n_group 
	FROM class
	WHERE day_of_week='сб'
)

-- exists

SELECT DISTINCT uni_group.group_id 
FROM uni_group
WHERE EXISTS (
	SELECT *
	FROM class
	WHERE day_of_week='вт' 
	AND uni_group.group_id = class.n_group 
	AND uni_group.faculty = 4
)


