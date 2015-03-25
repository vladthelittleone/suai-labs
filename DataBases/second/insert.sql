-- Лабораторная №2.
-- Вариант №15 по дисциплине "Базы данных".
-- Примеры использования insert для корректных данных.
-- СПБ ГУАП 2015.

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
