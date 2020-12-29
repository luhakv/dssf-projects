/* ---------------------------------------
	Задание 4.1

	База данных содержит список аэропортов практически всех крупных городов России. 
	В большинстве городов есть только один аэропорт. 
	Исключение составляет:
	
------------------------------------------ */

select a.city
from dst_project.airports a
group by a.city
having count(distinct a.airport_code) > 1;


/* ---------------------------------------
	Задание 4.2

------------------------------------------ */

-- Вопрос 1. Таблица рейсов содержит всю информацию о прошлых, текущих и запланированных рейсах. Сколько всего статусов для рейсов определено в таблице?
 


select count(distinct f.status)
from dst_project.flights f;



-- Вопрос 2. Какое количество самолетов находятся в воздухе на момент среза в базе (статус рейса «самолёт уже вылетел и находится в воздухе»).


select count(distinct f.flight_id)
from dst_project.flights f
where f.status = 'Departed';



-- Вопрос 3. Места определяют схему салона каждой модели. Сколько мест имеет самолет модели  (Boeing 777-300)?


select count(distinct s.seat_no)
from dst_project.seats s
where s.aircraft_code = 773::text;



-- Вопрос 4. Сколько состоявшихся (фактических) рейсов было совершено 
-- между 1 апреля 2017 года и 1 сентября 2017 года?
-- | состоявшийся рейс означает, что он не отменён, и самолёт прибыл в пункт назначения



select 
	count(f.flight_id)
from dst_project.flights f 
where status = 'Arrived'
	and (date_trunc('day', actual_departure) between '2017-04-01' and '2017-09-01'
		or date_trunc('day', actual_arrival) between '2017-04-01' and '2017-09-01')

		


/* ---------------------------------------
	Задание 4.3 
------------------------------------------ */
	
-- Вопрос 1. Сколько всего рейсов было отменено по данным базы?

	
select count(distinct f.flight_id)
from dst_project.flights f
where f.status = 'Cancelled';
	
	
-- Вопрос 2. Сколько самолетов моделей типа: Boeing, Sukhoi Superjet, Airbus 
-- находится в базе авиаперевозок?


select split_part(a.model, ' ', 1) model,
       count(*)
from dst_project.aircrafts a
where a.model like 'Boeing%'
       or a.model like 'Sukhoi Superjet%'
       or a.model like 'Airbus%'
group by 1
order by 1




-- Вопрос 3. В какой части (частях) света находится больше аэропортов?

select split_part(a.timezone, '/', 1) world_part,
       count(*)
from dst_project.airports a
group by 1



-- Вопрос 4. У какого рейса была самая большая задержка прибытия за все время сбора данных? Введите id рейса (flight_id)


select f.flight_id
from dst_project.flights f
where f.actual_arrival is not NULL
group by f.flight_id
order by (f.actual_arrival - f.scheduled_arrival) desc
limit 1;


/* ---------------------------------------
	Задание 4.4 
------------------------------------------ */


-- Вопрос 1. Когда был запланирован самый первый вылет, сохраненный в базе данных?


select f.scheduled_departure
from dst_project.flights f
order by f.scheduled_departure
limit 1;



-- Вопрос 2. Сколько минут составляет запланированное время полета в самом длительном рейсе?
-- Используем CTE


with mfd(duration) as (
	select
		 max(f.scheduled_arrival - f.scheduled_departure)
	from dst_project.flights f 
		group by f.flight_no
		order by 1 desc
		limit 1
	) 
select
	date_part('hour', duration) * 60 + date_part('minute', duration) as duration_mm
from mfd 



-- Вопрос 3. Между какими аэропортами пролегает самый длительный по времени запланированный рейс?

select f.departure_airport,
       f.arrival_airport, 
       (f.scheduled_arrival - f.scheduled_departure)
from dst_project.flights f
group by f.departure_airport,
          f.arrival_airport,
          f.scheduled_arrival - f.scheduled_departure
order by f.scheduled_arrival - f.scheduled_departure desc
limit 4;


-- Вопрос 4. Сколько составляет средняя дальность полета среди всех самолетов в минутах? 
-- Секунды округляются в меньшую сторону (отбрасываются до минут).


select 60*DATE_PART('hour', AVG(f.scheduled_arrival - f.scheduled_departure))+DATE_PART('minute', AVG(f.scheduled_arrival - f.scheduled_departure))
from dst_project.flights f;




/* ---------------------------------------
	Задание 4.5 
------------------------------------------ */


-- Вопрос 1. Мест какого класса у SU9 больше всего?


select fare_conditions,
       count(seat_no)
from dst_project.seats s
where s.aircraft_code = 'SU9'
group by 1
order by 2 desc
limit 1;

-- Решение 2 (с помощью join)

select
	s.fare_conditions,
	count(*)
from dst_project.aircrafts a 
join dst_project.seats s on s.aircraft_code = a.aircraft_code 
where a.aircraft_code = 'SU9'
group by 1
order by 2 desc
limit 1



-- Вопрос 2. Какую самую минимальную стоимость составило бронирование за всю историю?


select min(b.total_amount)
from dst_project.bookings b



-- Вопрос 3. Какой номер места был у пассажира с id = '4313 788533'?


select bp.seat_no
from dst_project.boarding_passes bp
where bp.ticket_no in
    (select t.ticket_no
     from dst_project.tickets t
     where t.passenger_id = '4313 788533');







/* -----------------------------------------------------------------------------------
	
	5. Предварительный анализ 

-------------------------------------------------------------------------------------- */

-- Посмотрим предвариетльно на некоторые пункты перелетов из Анапы

select 
	airport_code,
	airport_name, 
	timezone 
from dst_project.airports
where city = 'Anapa'


-- Вопрос 1. Анапа — курортный город на юге России. Сколько рейсов прибыло в Анапу за 2017 год?


select
	2017 as year,
	count(*) as flight_count
from dst_project.flights f 
where 
	f.arrival_airport = 'AAQ'
	and f.status = 'Arrived'
	and date_part('year', f.actual_arrival) = 2017


	

--  Вопрос 2. Сколько рейсов из Анапы вылетело зимой 2017 года?



select count(distinct f.flight_id)
from dst_project.flights f
where f.departure_airport = 'AAQ'
  and (date_trunc('month', f.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
  and f.status != 'Cancelled'



-- Вопрос 3. Посчитайте количество отмененных рейсов из Анапы за все время


select
	count(*) as flight_count
from flights f 
where 
	f.departure_airport = 'AAQ'
	and f.status = 'Cancelled'



-- Вопрос 4. Сколько рейсов из Анапы не летают в Москву?


select count(distinct f.flight_id)
from dst_project.flights f
where f.departure_airport = 'AAQ'
  and f.arrival_airport not in
    (select a.airport_code
     from dst_project.airports a
     where a.city = 'Moscow');



-- Вопрос 5. Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?


select a.model, count(distinct s.seat_no)
from dst_project.aircrafts a
join dst_project.seats s on a.aircraft_code=s.aircraft_code
join dst_project.flights f on a.aircraft_code = f.aircraft_code
where f.departure_airport = 'AAQ'
group by a.model
order by count(s.seat_no) desc
limit 1





/* -----------------------------------------------------------------------------------
	6. Переходим к реальной аналитике 
--------------------------------------------------------------------------------------*/
	
-- Выгрузим данные для анализа



with ticket_sold (flight_id, fare_conditions, ticket_count, amount_sold) as (
	select
		tf.flight_id,
		tf.fare_conditions ,
		count(tf.ticket_no) as ticket_count,
		sum(tf.amount) as amount_sold
	from dst_project.ticket_flights tf 
	join dst_project.flights fl on tf.flight_id = fl.flight_id
	where 
		fl.departure_airport = 'AAQ'
		and (date_trunc('month', fl.scheduled_departure) in ('2017-01-01', '2017-02-01', '2017-12-01'))
		and fl.status not in ('Cancelled')
	group by tf.flight_id, tf.fare_conditions 
), 
flight_ticket_sold (flight_id, class2, ticket_count2, amount_sold2, avg_price_class2, class1, ticket_count1, amount_sold1, avg_price_class1) as (
	select 
		t1.flight_id
		, t1.fare_conditions as class2
		, t1.ticket_count
		, t1.amount_sold::int
		, (t1.amount_sold / t1.ticket_count)::int as avg_price_class2
		, t2.fare_conditions as class1
		, t2.ticket_count
		, t2.amount_sold::int
		,  (t2.amount_sold / t2.ticket_count)::int as avg_price_class1
	from ticket_sold t1
	join ticket_sold t2 on t2.flight_id = t1.flight_id 
		and t1.fare_conditions != t2.fare_conditions
		and t1.fare_conditions = 'Economy'
) --select * from flight_ticket_sold
select
	f.flight_id, 	
	date_part('year', f.scheduled_departure)::int as sched_year,
	date_part('month', f.scheduled_departure)::int as sched_month,
	date_part('day', f.scheduled_departure)::int as sched_day,
	f.departure_airport,
	f.flight_no,
	f.arrival_airport,
	f.scheduled_departure,
	f.scheduled_arrival,
	f.actual_departure - f.scheduled_departure as delay_departure,
	f.status,
	f.actual_arrival - f.actual_departure as flight_duration,
	a2.city,
	a2.timezone,
	f.actual_departure,
	f.actual_arrival,
	f.actual_arrival - f.scheduled_arrival as delay_arrival,
	f.aircraft_code,
	split_part(a.model, ' ', 1) as manufacturer,
	split_part(a.model, ' ', 2) as board_model, 
	a."range" as flights_range_km,
	--a.model as full_model,
	fts.class2, 
	fts.ticket_count2, 
	fts.amount_sold2, 
	fts.avg_price_class2, 
	fts.class1, 
	fts.ticket_count1, 
	fts.amount_sold1, 
	fts.avg_price_class1,
	(fts.amount_sold2 + fts.amount_sold1)::int as total_amount
from
	dst_project.flights as f
join dst_project.aircrafts a on a.aircraft_code = f.aircraft_code
join dst_project.airports a2 on a2.airport_code = f.arrival_airport 
left join flight_ticket_sold fts on f.flight_id = fts.flight_id
where
	f.departure_airport = 'AAQ'
	and (date_trunc('month', f.scheduled_departure) in ('2017-01-01', '2017-02-01', '2017-12-01'))
	and f.status not in ('Cancelled')
order by f.scheduled_departure 







