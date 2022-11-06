-- /* Везде, где необходимо данные придумать самостоятельно. */
--Для каждого задания (кроме 4-го) можете использовать конструкцию
-------------------------
-- начать транзакцию
begin transaction
-- проверка до изменений
SELECT * FROM EXAM_MARKS
-- изменения
-- insert into SUBJECTS (ID,NAME,HOURS,SEMESTER) values (25,'Этика',58,2),(26,'Астрономия',34,1)
-- insert into EXAM_MARKS ...
-- delete from EXAM_MARKS where SUBJ_ID in (...)
-- проверка после изменений
SELECT * FROM EXAM_MARKS --WHERE STUDENT_ID > 120
-- отменить транзакцию
rollback


-- 1. Необходимо добавить двух новых студентов для нового учебного 
--    заведения "Винницкий Медицинский Университет".
begin transaction

insert into UNIVERSITIES (ID, NAME, RATING, CITY)
values (16, 'ВМУ', 500, 'Винница')

insert into STUDENTS (ID, SURNAME, NAME, GENDER, STIPEND, COURSE, CITY, UNIV_ID)
values (46, 'Колесник', 'Евгений', 'm', 500, 2, 'Винница', 16)

insert into STUDENTS (ID, SURNAME, NAME, GENDER, STIPEND, COURSE, CITY, UNIV_ID)
values (47, 'Шевченко', 'Александр', 'm', 500, 2, 'Винница', 16)

rollback

-- 2. Добавить еще один институт для города Ивано-Франковск, 
--    1-2 преподавателей, преподающих в нем, 1-2 студента,
--    а так же внести новые данные в экзаменационную таблицу.
begin transaction
insert into UNIVERSITIES (ID, NAME, RATING, CITY)
values (16, 'ПНУ', 500, 'Ивано-Франковск')

select * from UNIVERSITIES
select * from LECTURERS
select * from STUDENTS
select * from exam_marks

insert into LECTURERS (ID, SURNAME, NAME, CITY, UNIV_ID)
values (26, 'Ксендзик', 'НВ', 'Ивано-Франковск', 16)

insert into STUDENTS (ID, SURNAME, NAME, GENDER, STIPEND, COURSE, CITY, UNIV_ID)
values (46, 'Горецька', 'Юлія', 'f', 600, 1, 'Ивано-Франковск', 16)

insert into EXAM_MARKS (ID, STUDENT_ID, SUBJ_ID, MARK, EXAM_DATE)
values (121, 46, 1, 4.000, '2012-06-12 00:00:00.000')
-- Cannot insert explicit value for identity column in table 'EXAM_MARKS' when IDENTITY_INSERT is set to OFF.

rollback


-- 3. Известно, что студенты Павленко и Пименчук перевелись в ОНПУ. 
--    Модифицируйте соответствующие таблицы и поля.
begin transaction

UPDATE STUDENTS
set UNIV_ID = (select u.id from UNIVERSITIES u where name = 'ОНПУ')
where SURNAME = 'Павленко'

UPDATE STUDENTS
set UNIV_ID = (select u.id from UNIVERSITIES u where name = 'ОНПУ')
where SURNAME = 'Пименчук'

rollback





-- 4. Студентам со средним балом 4.75 начислить 12.5% к стипендии,
--    со средним балом 5 добавить 200 грн.
--    Выполните соответствующие изменения в БД.
begin transaction

UPDATE STUDENTS
set stipend = stipend*1.125
where ID = (select em.STUDENT_ID from EXAM_MARKS em
				where students.id=em.STUDENT_ID
				group by STUDENT_ID
				having avg(em.mark) = 4.75)
UPDATE STUDENTS
set stipend = stipend+200
where ID = (select em.STUDENT_ID from EXAM_MARKS em
				where students.id=em.STUDENT_ID
				group by STUDENT_ID
				having avg(em.mark) = 5)

rollback




-- 5. Лектор 3 ушел на пенсию, необходимо корректно удалить о нем данные.
begin transaction

delete from subj_lect
where LECTURER_ID = 3
 
delete from LECTURERS
where id = 3

rollback
