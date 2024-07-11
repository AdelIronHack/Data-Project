select * from accidents;

select Weather_Condition, count(*) from usaccidents.accidents
group by 1;

-- WEATHER CONDITION
-- create a new dimension table for the weather condition dimension
create table if not exists usaccidents.weather_condition (
weather_condition_id int auto_increment,
weather_condition varchar(30),
primary key (weather_condition_id));

-- check the table was created...
select * from employees_mod.my_gender;

-- lets populate the table by inserting the unique values for that dimension
insert into usaccidents.weather_condition(weather_condition)
select distinct Weather_Condition from usaccidents.accidents;

-- check it has correctly populated
select * from usaccidents.weather_condition;

-- now lets adjust the original table so we will use this table
alter table usaccidents.accidents add column weather_condition_id int after Weather_Condition;

-- lets set up the foreign key reference
alter table usaccidents.accident ADD CONSTRAINT weather_condition_fk2
FOREIGN KEY (weather_condition_id) 
REFERENCES usaccidents.weather_condition (weather_condition_id);

-- check the extra column has appeared
select * from usaccidents.accidents limit 10;

-- populate the column using the dimension table we created
update usaccidents.accidents a, usaccidents.weather_condition w
set a.weather_condition_id = w.weather_condition_id
where a.weather_condition = w.weather_condition;

-- check it is populated
select * from usaccidents.weather_condition limit 10;

-- lets drop the original column now
alter table usaccidents.accidents drop column Weather_Condition;

-- check everything is as expected
select * from employees_mod.employee_yearly_overview limit 10;
select g.gender, count(*) from employees_mod.employee_yearly_overview e
inner join employees_mod.my_gender g on e.gender_id = g.gender_id
group by 1;


-- CITY
-- create a new dimension table for the city dimension
drop table city;
create table if not exists usaccidents.city (
city_id int auto_increment,
city varchar(40),
county varchar(60),
state varchar(5),
primary key (city_id));

-- check the table was created...
select * from usaccidents.city;

-- lets populate the table by inserting the unique values for that dimension
insert into usaccidents.city(city,county,state)
select distinct City, County, State from usaccidents.accidents;

-- check it has correctly populated
select * from usaccidents.city;

-- now lets adjust the original table so we will use this table
alter table usaccidents.accidents add column city_id int after City;

-- lets set up the foreign key reference
alter table usaccidents.accident ADD CONSTRAINT city_fk2 FOREIGN KEY (city_id) REFERENCES usaccidents.city (city_id);

-- check the extra column has appeared
select * from usaccidents.accidents limit 10;

-- populate the column using the dimension table we created
update usaccidents.accidents a, usaccidents.city c
set a.city_id = c.city_id
where a.city = c.city;

drop table accident;

CREATE TABLE accident AS
SELECT 
    a.ID, 
    a.Source, 
    a.Severity, 
    a.Start_Time, 
    a.End_Time, 
    a.`Distance(mi)`, 
    a.Description, 
    a.Country, 
    a.Timezone, 
    a.Airport_Code, 
    a.Weather_Timestamp, 
    a.`Temperature(F)`, 
    a.`Wind_Chill(F)`, 
    a.`Humidity(%)`, 
    a.`Pressure(in)`, 
    a.`Visibility(mi)`, 
    a.Wind_Direction, 
    a.`Wind_Speed(mph)`, 
    a.`Precipitation(in)`, 
    a.Weather_Condition, 
    a.weather_condition_id, 
    a.Amenity, 
    a.Bump, 
    a.Crossing, 
    a.Give_Way, 
    a.Junction, 
    a.No_Exit, 
    a.Railway, 
    a.Roundabout, 
    a.Station, 
    a.Stop, 
    a.Traffic_Calming, 
    a.Traffic_Signal, 
    a.Turning_Loop, 
    a.Sunrise_Sunset, 
    a.Civil_Twilight, 
    a.Nautical_Twilight, 
    a.Astronomical_Twilight,
    c.city_id
FROM 
    usaccidents.accidents a
INNER JOIN 
    usaccidents.city c USING (city);


-- check it is populated
select * from usaccidents.city limit 10;

-- TO DO LATER : lets drop the original column now
alter table usaccidents.accident drop column Weather_Condition;
alter table usaccidents.accidents drop foreign key city_fk;
alter table usaccidents.accidents drop column city_id;


ALTER TABLE usaccidents.accidents MODIFY ID VARCHAR(10);

create table location as
select ID, Start_Lat, End_Lat, Start_Lng, End_Lng, Street, Zipcode, city_id 
from usaccidents.accidents a
join usaccidents.city c
on a.city=c.city;

-- set up the primary key reference
ALTER TABLE usaccidents.accidents
ADD CONSTRAINT location_pk PRIMARY KEY (ID);

-- set up the foreign key reference
alter table usaccidents.location ADD CONSTRAINT city_id_fk FOREIGN KEY (city_id) 
REFERENCES usaccidents.city (city_id);

-- drop unnecessary columns
ALTER TABLE usaccidents.accidents DROP COLUMN Start_Lat;
ALTER TABLE usaccidents.accidents DROP COLUMN End_Lat;
ALTER TABLE usaccidents.accidents DROP COLUMN Start_Lng;
ALTER TABLE usaccidents.accidents DROP COLUMN End_Lng;
ALTER TABLE usaccidents.accidents DROP COLUMN Street;
ALTER TABLE usaccidents.accidents DROP COLUMN Zipcode;
ALTER TABLE usaccidents.accidents DROP COLUMN County;
ALTER TABLE usaccidents.accidents DROP COLUMN State;

-- join two tables
SELECT count(*) as total_accidents 
FROM accidents a 
join city c on a.city_id=c.city_id 
WHERE state='CA';

-- display average road length affected by an accident
select avg(`Distance(mi)`) from accident;

-- display accidents with the highest amount of rain
select `Precipitation(in)` from accidents
order by `Precipitation(in)` desc
limit 10;

-- display the number of every weather condition possible
SELECT COUNT(DISTINCT Weather_Condition) FROM accidents;

-- clean null values from a column
DELETE FROM accidents 
WHERE Weather_Condition IS NULL;

-- display every single wearher condition
SELECT distinct Weather_Condition
FROM accidents
GROUP BY Weather_Condition;