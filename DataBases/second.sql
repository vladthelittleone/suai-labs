-- Лабораторная №2.
-- Вариант №15 по дисциплине "Базы данных".
-- СПБ ГУАП 2015.

-- Примеры использования insert для корректных данных.
insert into faculty values ('1')
insert into faculty values ('2')
insert into faculty values ('3')
insert into faculty values ('4')

insert into uni_group values (1211, '1')
insert into uni_group values (1221, '1')
insert into uni_group values (1231, '1')
insert into uni_group values (1241, '1')

insert into uni_group values (2211, '2')
insert into uni_group values (2221, '2')
insert into uni_group values (2231, '2')
insert into uni_group values (2241, '2')

insert into uni_group values (3211, '3')
insert into uni_group values (3221, '3')
insert into uni_group values (3231, '3')
insert into uni_group values (3241, '3')

insert into uni_group values (4211, '4')
insert into uni_group values (4221, '4')
insert into uni_group values (4231, '4')
insert into uni_group values (4241, '4')

insert into corps values (1)
insert into corps values (2)
insert into corps values (3)

insert into audience values (11, 1)
insert into audience values (12, 1)

insert into audience values (21, 2)
insert into audience values (22, 2)
insert into audience values (23, 2)

insert into audience values (31, 3)
insert into audience values (32, 3)

insert into class values('лекц', 'пн', 12, 1221)
insert into class values('лаб', 'пн', 11, 1211)
insert into class values('лекц', 'пн', 31, 4211)
insert into class values('лекц', 'пн', 22, 3231)
insert into class values('курс', 'пн', 21, 4231)

insert into class values('лаб', 'вт', 32, 4231)
insert into class values('лаб', 'вт', 22, 4241)
insert into class values('лекц', 'вт', 31, 1211)
insert into class values('лаб', 'вт', 21, 3221)
insert into class values('курс', 'вт', 11, 3211)

insert into class values('лекц', 'ср', 22, 4241)
insert into class values('лаб', 'ср', 31, 1241)
insert into class values('лаб', 'ср', 32, 3241)
insert into class values('лаб', 'ср', 21, 3221)
insert into class values('лекц', 'ср', 11, 3221)

insert into class values('лекц', 'чт', 31, 4241)
insert into class values('лаб', 'чт', 31, 4231)
insert into class values('лаб', 'чт', 22, 2241)
insert into class values('лаб', 'чт', 21, 1221)
insert into class values('лекц', 'чт', 21, 1231)

insert into class values('лекц', 'пт', 12, 1221)
insert into class values('лаб', 'пт', 11, 1211)
insert into class values('лекц', 'пт', 31, 4211)
insert into class values('лекц', 'пт', 22, 3221)
insert into class values('курс', 'пт', 21, 4231)

-- Вывод набора данных, содержащихся в таблицах БД.
select * from audience
select * from corps
select * from class
select * from faculty
select * from uni_group
go

-- Примеры использования insert  для некорректных данных (нарушающих ограничения и ссылочную целостность): 
insert into audience values (11, 10)
go

insert into faculty values ('10')
go

insert into uni_group values (1211, '1')
go

-- Примеры использования update для некорректных данных (нарушающих ограничения и ссылочную целостность): 
update audience set corps = 10 where id = 1
go

-- Примеры использования delete для корректных данных: 
delete from class where  id = 2
go

-- Пример delete, вызывающий каскадные изменения и удаление данных:
delete from audience where id = 1
go

-- Примеры использования alter table для корректировки структуры таблиц:
alter table audience add duty varchar(50)
go
alter table audience drop column duty 
go
