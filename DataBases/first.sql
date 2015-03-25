create table corps 
(
	id int identity primary key,
	corps int NOT NULL UNIQUE
)

create table audience
(
	id int identity primary key,
	audience int NOT NULL UNIQUE, 
	corps int NOT NULL, 
	foreign key (corps) references corps (corps)
	on delete no action 
	on update cascade
)

create table faculty 
(
	id int identity primary key,
	faculty char NOT NULL UNIQUE CHECK (faculty in ('1', '2', '3', '4'))
)

create table uni_group
(
	id int identity primary key,
	group_id int NOT NULL UNIQUE,
	faculty char NOT NULL,
	foreign key (faculty) references faculty (faculty)
	on delete no action 
	on update cascade
)

create table class
(
	id int identity primary key,
	type_of_class varchar(4) NOT NULL CHECK (type_of_class in ('лаб', 'лекц', 'курс')),
	day_of_week varchar(2) NOT NULL CHECK (day_of_week in ('пн', 'вт', 'ср', 'чт', 'пт', 'сб')),
	audience int NOT NULL,
	n_group int NOT NULL,
	foreign key (audience) references audience (audience)
	on delete no action 
	on update cascade,
	foreign key (n_group) references uni_group (group_id)
	on delete no action 
	on update cascade
)

go
