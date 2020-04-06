-- total number of trips for 2016
select count(*)
from trips
where year(start_date)=2016;

-- total number of trips for 2017
select count(*)
from trips
where year(start_date)=2017;

-- total number of trips for 2016 broken down by month
select 
	month(start_date) as month, 
    count(*) as trips
from trips
where year(start_date)=2016
group by month
order by month;

-- total number of trips for 2017 broken down by month
select 
	month(start_date) as month, 
    count(*) as trips
from trips
where year(start_date)=2017
group by month
order by month;

-- average number of trips per day for each year-month combination
select 
	year(start_date) as year, 
    month(start_date) as month, 
    count(id)/count(distinct day(start_date)) as avgTrips
from trips
group by year, month;

-- table created for average number of trips per day for each year-month combination
drop table if exists avg_trips_per_day;
create table avg_trips_per_day as 
select 
	year(start_date) as year, 
    month(start_date) as month, 
    count(id)/count(distinct day(start_date)) as trip_per_day
from trips 
group by year, month;

-- number of trips in 2017 broken down by membership status
select 
	is_member as membership, 
    count(*) as trips
from trips
where year(start_date)=2017
group by membership;

-- fraction of member trips to total trips for 2017 broken down by month
select month(start_date), avg(is_member)
from trips
where year(start_date)=2017
group by month(start_date);

-- top 5 most popular starting stations identified by direct join
select 
	stations.name as station_name, 
    count(start_station_code) as numTrips
from trips 
join stations on trips.start_station_code=stations.code 
group by station_name
order by numTrips desc
limit 5;

-- top 5 most popular starting stations identified by subqueries to save computation
select stations.name
from stations 
join 
	(select start_station_code, count(start_station_code) as num
	from trips
	group by start_station_code
	order by num desc
	limit 5) as top_code 
on stations.code=top_code.start_station_code; 

-- distribution of number of starts and ends throughout the day
select case
       when hour(start_date) between 7 and 11 then "morning"
       when hour(start_date) between 12 and 16 then "afternoon"
       when hour(start_date) between 17 and 21 then "evening"
       else "night"
       end as "time_of_day", count(day(start_date))
from trips 
join stations on trips.start_station_code=stations.code
where stations.name='Mackay / de Maisonneuve'
group by time_of_day
order by time_of_day;

select case
       when hour(end_date) between 7 and 11 then "morning"
       when hour(end_date) between 12 and 16 then "afternoon"
       when hour(end_date) between 17 and 21 then "evening"
       else "night"
       end as "time_of_day", count(day(end_date))
from trips 
join stations on trips.end_station_code=stations.code
where stations.name='Mackay / de Maisonneuve'
group by time_of_day
order by time_of_day;


-- total number of starting trips for each station 
select 
	stations.name as station_name, 
    count(trips.start_station_code) as numTotal
from trips 
join stations on trips.start_station_code=stations.code
group by station_name;

-- number of roundtrips for each station 
select 
	stations.name as station_name, 
    count(trips.start_station_code) as numRound
from trips 
join stations on trips.start_station_code=stations.code
where trips.start_station_code=trips.end_station_code
group by station_name;

-- fraction of round trips to total trips starting from each station
select 
	totaltrip.station_name, 
    roundtrip.numRound/totaltrip.numTotal as fracRoundTrip
from 
	(select stations.name as station_name, count(trips.start_station_code) as numTotal
	from trips join stations on trips.start_station_code=stations.code
	group by station_name) as totaltrip
join 
	(select stations.name as station_name, count(trips.start_station_code) as numRound
	from trips join stations on trips.start_station_code=stations.code
	where trips.start_station_code=trips.end_station_code
	group by station_name) as roundtrip
on totaltrip.station_name=roundtrip.station_name
order by fracRoundTrip desc;

-- filter to stations with at least 500 starting from them and 10% fraction
select 
	totaltrip.station_name, 
    roundtrip.numRound/totaltrip.numTotal as fracRoundTrip
from 
	(select stations.name as station_name, count(trips.start_station_code) as numTotal
	from trips join stations on trips.start_station_code=stations.code
	group by station_name
	having numTotal>=500) as totaltrip
join 
	(select stations.name as station_name, count(trips.start_station_code) as numRound
	from trips join stations on trips.start_station_code=stations.code
	where trips.start_station_code=trips.end_station_code
	group by station_name) as roundtrip
on totaltrip.station_name=roundtrip.station_name
where roundtrip.numRound/totaltrip.numTotal>=.1
order by fracRoundTrip desc;