-- 0. Отобразите для каждого из курсов количество парней и девушек.
select COURSE, GENDER, count(*) cnt_stud
from STUDENTS
group by course, gender
--done

-- 1. Напишите запрос для таблицы EXAM_MARKS, выбирающий даты, для которых средний балл
--    находиться в диапазоне от 4.22 до 4.77. Формат даты для вывода на экран:
--    день месяц, например, 05 Jun
select format(EXAM_DATE, 'dd MMM') date --,avg(MARK) mark
from EXAM_MARKS
group by exam_date --mark  - це була помилка
having avg(MARK) between 4.22 and 4.77

-- 2. Напишите запрос, выбирающий из таблицы EXAM_MARKS следующую информацию по каждому ИД студента:
--    - кол-во календарных дней, потраченных студентом на сессию.
--        Например, если первый экзамен был сдан 01.06, а последний 10.06, то потрачено 10 дней
--    - кол-во попыток сдачи экзаменов
--    - максимальную и минимальную оценки.
--    Примечание: функция DAY() для решения не подходит!
select STUDENT_ID, 
case when datediff(day, min(cast(exam_date as datetime)),
max(cast(exam_date as datetime))) = 0 then 1 else
datediff(day, min(cast(exam_date as datetime)), 
max(cast(exam_date as datetime))) end as spent_days, 
count(SUBJ_ID) as exam_try, -- тут не уверена
max(MARK) as max_mark, min(MARK) as min_mark
from EXAM_MARKS
group by STUDENT_ID 

--new_upd
select student_id
, cast(max(exam_date) - min(exam_date) as int) + 1 as datediff
, count(*) cnt
, max(mark) max_mark
, min(mark) min_mark
from exam_marks
group by STUDENT_ID
--поправила, але не впевнена, чи це не костиль
-- 3. Покажите список идентификаторов студентов, которые имеют пересдачи.
--    Примечание: под пересдачей понимается ситуация, когда у одного и того же студента
--    по одному и тому же предмету есть более одной оценки
select STUDENT_ID as retest
from EXAM_MARKS
group by STUDENT_ID
having count(subj_id) <> count(distinct SUBJ_ID)

--or

select student_id, subj_id, count(*)
from exam_marks
group by student_id, subj_id
having count(*) > 1
--done
-- 4. Напишите запрос, отображающий список предметов обучения, вычитываемых за самый короткий
--    промежуток времени, отсортированный в порядке убывания семестров. Поле семестра в
--    выходных данных должно быть первым, за ним должны следовать наименование и
--    идентификатор предмета обучения.
select Semester, Name, Id
from SUBJECTS
where hours = (select min(hours) 
				from SUBJECTS)
order by semester desc

-- вийшло
-- 5. Напишите запрос с подзапросом для получения данных обо всех положительных оценках(4, 5) Марины
--    Шуст (предположим, что ее персональный номер неизвестен), идентификаторов предметов и дат
--    их сдачи.
select MARK from exam_marks
where STUDENT_ID in (select ID from students
					where surname = 'Шуст' and name = 'Марина')
group by MARK
having min(mark) >= 4
--done

-- 6. Покажите сумму баллов для каждой даты сдачи экзаменов, когда средний балл не равен
--    среднему арифметическому между максимальной и минимальной оценкой. Данные расчитать только
--    для студенток. Результат выведите в порядке убывания сумм баллов, а дату в формате dd/mm/yyyy.
select format(exam_date, 'dd-MM-yyyy'), sum(mark)
from exam_marks
where student_id in 
			(select id from students
			where gender = 'f')
group by exam_date
having avg(mark) <> (max(mark) + min(mark))/2
order by avg(mark) desc
--поправила

-- 7. Покажите имена и фамилии всех студентов, у которых средний балл по предметам
--    с идентификаторами 1 и 2 превышает средний балл этого же студента
--    по всем остальным предметам. Используйте конструкцию AVG(case...), либо коррелирующий подзапрос.
--    Примечание: может так оказаться, что по "остальным" предметам (не 1ый и не 2ой) не было
--    получено ни одной оценки, в таком случае принять средний бал за 0 - для этого можно
--    использовать функцию ISNULL().
select student_id, avg(mark) from exam_marks
--where cast(student_id as varchar) in (select surname from students) - без цього працює, а з цим пусто.
group by student_id
having avg(case when subj_id = 1 or subj_id = 2 
then mark else null end)>avg(mark)

--right
select surname, name from students
where id in (
select student_id
from exam_marks
group by student_id
having avg(case when subj_id in (1,2) then mark end) 
> isnull(avg(case when subj_id not in (1,2) then mark end), 0)

-- 8. Напишите запрос, выполняющий вывод общего суммарного и среднего баллов каждого
--    экзаменованого второкурсника, его идентификатор и кол-во полученных оценок при условии,
--    что он успешно сдал 3 и более предметов.
select sum(mark) as sum_mark, avg(mark) as avg_mark, 
STUDENT_ID, count(mark) as count_mark
from EXAM_MARKS
where STUDENT_ID in (select id
					from students
					where course = 2)
group by STUDENT_ID
having count(case when mark >2 then 1 end) >= 3
--поправила

select student_id, sum(mark) sum_mark, avg(mark) avg_mark
from exam_marks
where STUDENT_ID in (select id
					from students
					where course = 2)
group by student_id
having count(distinct case when mark>2 then subj_id end) >=3
-- 9. Вывести названия всех предметов, средний балл которых превышает средний балл, полученный
--    студентами, обучающимися в университетах г. Днепр
--    Примечание: Используйте вложенные подзапросы.
select subj_id, avg(mark) from exam_marks
group by subj_id
having avg(mark) > (select avg(mark) from exam_marks
where student_id in
 (select id from students
where univ_id in
	(select id from UNIVERSITIES
	where city = 'Днепр')))
-- поправила
-- upd
select name from subjects where id in (
select subj_id
from exam_marks
group by subj_id
having avg(mark) > (select avg(mark) from exam_marks
where student_id in (
						select
						id from students where univ_id in (select id
														from UNIVERSITIES
														where city = 'Днепр'))))

