-- RDS Database Data Profiling

/*
-- get all table row count from internal system catalog = pg_class

select
    relname as table_name, 
    reltuples AS estimated_row_count
from 
    pg_class 
join 
    pg_namespace ON pg_namespace.oid = pg_class.relnamespace
where 
    relkind = 'r' 
    and nspname = 'public' -- my specific schema = public
ORDER BY 
    reltuples DESC;
*/


-- create function for every table row count --
create or replace function actual_row_count()
returns table(table_name text, total_rows_intable int) as
$$
declare 
	t_name text;
	r_count int;
begin
	for t_name in
		select information_schema.tables.table_name
		from information_schema.tables
		where table_schema = 'public' and table_type = 'BASE TABLE'
	loop
		execute format('select count(*) from %I', t_name) into r_count;
		table_name := t_name;
		total_rows_intable := r_count;
		return next;
	end loop;
end;
$$
language plpgsql;

select * from actual_row_count();




-- create function to count null values in every column of every table
create or replace function check_nulls_tables()
returns table(t_name text, c_name text, null_count int) as
$$
declare r record; v_count int;
begin
	for r in
		select table_name, column_name
		from information_schema.columns
		where table_schema = 'public'
	loop 
		execute format('select count(*) from %I where %I is null', r.table_name, r.column_name)
		into v_count;

		if v_count > 0 then
			t_name := r.table_name;
			c_name := r.column_name;
			null_count := v_count;
			return next;
		end if;
	end loop;
end;
$$
language plpgsql;

select * from check_nulls_tables(); 
/*
8 tables with null values are presnet in database
"stg_drivers"			"termination_date"	124
"stg_fuel_purchases"	"driver_id"			3988
"stg_trips"				"driver_id"			1714
"stg_trips"				"truck_id"			1672
"stg_trips"				"trailer_id"		1680
"stg_safety_incidents"	"truck_id"			1
"stg_safety_incidents"	"driver_id"			1
"stg_fuel_purchases"	"truck_id"			3880
*/



-- termination date is null which means the driver is still under workforce
select * from stg_drivers 
where termination_date is null;


-- recorded trips with driver_id null can indicate driver is not registered yet with a unique id
select * from stg_fuel_purchases 
where driver_id is null;


-- FOR STG_TRIPS
-- we cannot delete null value rows as they contain valuable data : so we update them to 'unknown'
-- to indicate some unforeseen circumstances hence we retain the business data 

-- creating a dummy row in stg_drivers to link null driver_id in stg_trips
insert into stg_drivers(driver_id, first_name, last_name) values('unknown','unknown','unknown');
update stg_trips set driver_id='unknown' where driver_id is null;


-- same process for truck_id
insert into stg_trucks(truck_id) values('unknown') on conflict (truck_id) do nothing;
update stg_trips set truck_id='unknown' where truck_id is null;


-- same process for trailer_id
insert into stg_trailers(trailer_id) values('unknown') on conflict (trailer_id) do nothing;
update stg_trips set trailer_id='unknown' where trailer_id is null;



-- FOR STG_SAFETY_INCIDENTS
select * from stg_safety_incidents where driver_id is null or truck_id is null;

update stg_safety_incidents set truck_id='unknown' where truck_id is null;
update stg_safety_incidents set driver_id='unknown' where driver_id is null;

select * from stg_safety_incidents where driver_id='unknown' or truck_id='unknown';


-- FOR STG_FUEL_PURCHASES
UPDATE stg_fuel_purchases set truck_id='unknown' where truck_id is null;
UPDATE stg_fuel_purchases set driver_id='unknown' where driver_id is null;


-- running null check function again after adding 'unknown' value
select * from check_nulls_tables();

/*

"stg_trucks"	"unit_number"			1
"stg_trucks"	"model_year"			1
"stg_trucks"	"acquisition_date"		1
"stg_trucks"	"acquisition_mileage"	1
"stg_trucks"	"tank_capacity_gallons"	1
"stg_trailers"	"trailer_number"		1
"stg_trailers"	"length_feet"			1
"stg_trailers"	"model_year"			1
"stg_trailers"	"acquisition_date"		1
"stg_drivers"	"hire_date"				1
"stg_drivers"	"termination_date"		125
"stg_drivers"	"date_of_birth"			1
"stg_drivers"	"years_experience"		1
"stg_drivers"	"license_number"		1
"stg_drivers"	"license_state"			1
"stg_drivers"	"home_terminal"			1
"stg_drivers"	"employment_status"		1
"stg_drivers"	"cdl_class"				1
"stg_trucks"	"truck_brand"			1
"stg_trucks"	"vin"					1
"stg_trucks"	"fuel_type"				1
"stg_trucks"	"status"				1
"stg_trucks"	"home_terminal"			1
"stg_trailers"	"trailer_type"			1
"stg_trailers"	"vin"					1
"stg_trailers"	"status"				1
"stg_trailers"	"current_location"		1

*/

-- the 1 in null values are with respect to the dummy row we added to overcome 
-- the foreign key restraint while countering null values in child tables
