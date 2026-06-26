select current_database();

-- CREATE STAGING TABLES
select * from stg_drivers limit 20;

-- STAGE DRIVER 
CREATE TABLE stg_drivers(
	driver_id varchar(12),
	first_name varchar(25),
	last_name varchar(25),
	hire_date date,
	termination_date date,
	license_number varchar(50),
	license_state char(2),
	date_of_birth date,
	home_terminal varchar(30),
	employement_statys varchar(20)
);

-- load data from s3 to rds database_table
SELECT aws_s3.table_import_from_s3(
	'stg_drivers',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/drivers.csv',
		'ap-south-1'
	)
)


-- STAGING TABLES(DATASET) ALPHABETICALLY
-- STAGE CUSTOMERS
CREATE TABLE stg_customers(
	customer_id varchar(15),
	customer_name varchar(75),
	customer_type varchar(15),
	credit_term_days int,
	primary_freight_type varchar(25),
	account_status varchar(10),
	contract_start date,
	annual_revenue_potential float
);

SELECT aws_s3.table_import_from_s3(
	'stg_customers',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/customers.csv',
		'ap-south-1'
	)
);

SELECT * from stg_customers LIMIT 15;



-- STAGE DELIVERY EVENTS
CREATE TABLE stg_delivery_events(
	event_id varchar(15),
	load_id varchar(15),
	trip_id varchar(15),
	event_type varchar(12),
	facility_id varchar(10),
	scheduled_datetime timestamp,
	detention_mins int,
	on_time_flag boolean,
	location_city varchar(25),
	location_state char(2)
)

SELECT aws_s3.table_import_from_s3(
	'stg_delivery_events',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/delivery_events.csv',
		'ap-south-1'
	)
)

select table_name from information_schema.tables
where table_schema='public';
-- stg_customers, stg_drivers, stg_delivery_events

select * from stg_customers; -- 200 rows
select * from stg_drivers; -- 150 rows
select * from stg_delivery_events; -- 170820 rows



-- STAGE FACILITIES
CREATE TABLE stg_facilities(
	facility_id varchar(12) primary key,
	facility_name varchar(50),
	facility_type varchar(20),
	city varchar(20),
	state char(2),
	latitude numeric(7,4),
	longitude numeric(7,4),
	dock_doors int,
	operating_hours varchar(12)
);

SELECT aws_s3.table_import_from_s3(
	'stg_facilities',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/facilities.csv',
		'ap-south-1'
	)
); 
-- 50 rows imported into relation "stg_facilities" from file 
--logisticsSQLGrafana/facilities.csv of 4323 bytes
select * from stg_facilities;



-- STAGE FUEL_PURCHASES
create table stg_fuel_purchases(
	fuel_purchase_id varchar(15) primary key,
	trip_id varchar(15),
	truck_id varchar(10),
	driver_id varchar(10),
	purchase_date timestamp,
	location_city varchar(20),
	location_state char(2),
	gallons float,
	price_per_gallon float,
	total_cost float,
	fuel_card_number varchar(10)
);

SELECT aws_s3.table_import_from_s3(
	'stg_fuel_purchases',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/fuel_purchases.csv',
		'ap-south-1'
	)
); 
-- 196442 rows imported into relation "stg_fuel_purchases" from 
-- file logisticsSQLGrafana/fuel_purchases.csv of 20377087 bytes

-- sample queires
select * from stg_fuel_purchases limit 20;
select location_state, count(location_state) from stg_fuel_purchases
group by location_state;



-- STAGE LOADS
CREATE TABLE stg_loads(
	load_id varchar(13),
	customer_id varchar(10),
	route_id varchar(8),
	load_date date,
	load_type varchar(15),
	weight_lbs float,
	pieces int,
	revenue float,
	fuel_surcharge float,
	accesorial_charge int,
	load_status varchar(10),
	booking_type varchar(10)
);

SELECT aws_s3.table_import_from_s3(
	'stg_loads',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/loads.csv',
		'ap-south-1'
	)
); 
-- 85410 rows imported into relation "stg_loads" from 
-- file logisticsSQLGrafana/loads.csv of 8384050 bytes



-- STAGE MAINTENANCE RECORDS
create table stg_maintenance_records(
	maintenance_id varchar(15) primary key,
	truck_id varchar(8),
	maintenance_date date,
	maintenance_type varchar(15),
	odometer_reading int,
	labor_hours float,
	labor_cost float,
	parts_cost float,
	total_cost float,
	facility_location varchar(15),
	downtime_hours float,
	service_description varchar(25)
);

SELECT aws_s3.table_import_from_s3(
	'stg_maintenance_records',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/maintenance_records.csv',
		'ap-south-1'
	)
); 
-- 2920 rows imported into relation "stg_maintenance_records" from 
-- file logisticsSQLGrafana/maintenance_records.csv of 314754 bytes
select * from stg_maintenance_records where total_cost>3500;



-- STAGING ROUTES
create table stg_routes(
	route_id varchar(10) primary key,
	origin_city varchar(20),
	origin_state char(2),
	destination_city varchar(20),
	destination_state char(2),
	typical_distance_miles int,
	base_rate_per_mile float,
	fuel_surcharge_rate float,
	transit_days int
);

SELECT aws_s3.table_import_from_s3(
	'stg_routes',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/routes.csv',
		'ap-south-1'
	)
); 
-- 58 rows imported into relation "stg_routes"
-- from file logisticsSQLGrafana/routes.csv of 3075 bytes



-- STAGING SAFETY INCIDENTS
create table stg_safety_incidents(
	incident_id varchar(12) primary key,
	trip_id varchar(12),
	truck_id varchar(8),
	driver_id varchar(8),
	incident_date timestamp,
	incident_type varchar(50),
	location_city varchar(20),
	location_state char(2),
	at_fault_flag boolean,
	injury_flag boolean,
	vehicle_damage_cost float,
	cargo_damage_cost float,
	claim_amount float,
	preventable_flag boolean,
	description varchar(50)
);

SELECT aws_s3.table_import_from_s3(
	'stg_safety_incidents',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/safety_incidents.csv',
		'ap-south-1'
	)
); 
-- 170 rows imported into relation "stg_safety_incidents" from file logisticsSQLGrafana/safety_incidents.csv of 28008 bytes



-- STAGING TRAILERS
create table stg_trailers(
	trailer_id varchar(8),
	trailer_number int,
	trailer_type varchar(12),
	length_feet int,
	model_year int,
	vin varchar(30),
	acquisition_date date,
	status varchar(10),
	current_location varchar(20)
);

SELECT aws_s3.table_import_from_s3(
	'stg_trailers',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/trailers.csv',
		'ap-south-1'
	)
);
-- 180 rows imported into relation "stg_trailers" from file logisticsSQLGrafana/trailers.csv of 14367 bytes
select * from stg_trailers limit 10;


-- STAGING TRIPS
create table stg_trips(
	trip_id varchar(12) primary key,
	load_id varchar(12),
	driver_id varchar(8),
	truck_id varchar(8),
	trailer_id varchar(8),
	dispatch_date date,
	actual_distance_miles int,
	actual_duration_hours float,
	fuels_gallons_used float,
	average_mpg float,
	idle_time_hours float,
	trip_status varchar(12)
);

SELECT aws_s3.table_import_from_s3(
	'stg_trips',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/trips.csv',
		'ap-south-1'
	)
);
-- 85410 rows imported into relation "stg_trips" from file logisticsSQLGrafana/trips.csv of 8362306 bytes
select * from stg_trips limit 10;



-- STAGING TRUCK UTILIZATION METRICS
create table stg_truck_utilization(
	truck_id varchar(8),
	month_operation date,
	primary key(truck_id, month_operation),
	trips_completed int,
	total_miles int,
	total_revenue float,
	average_mpg float,
	maintenance_events int,
	maintenance_cost float,
	downtime_hours float,
	utilization_rate float
);

SELECT aws_s3.table_import_from_s3(
	'stg_truck_utilization',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/truck_utilization_metrics.csv',
		'ap-south-1'
	)
);
-- 3312 rows imported into relation "stg_truck_utilization" from file logisticsSQLGrafana/truck_utilization_metrics.csv of 201613 bytes
select * from stg_truck_utilization limit 10;



-- STAGING TRUCKS
create table stg_trucks(
	truck_id varchar(8) primary key,
	unit_number int,
	truck_brand varchar(20),
	model_year int,
	vin varchar(30),
	acquisition_date date,
	acquisition_mileage int,
	fuel_type varchar(8),
	tank_capacity_gallons int,
	status varchar(12),
	home_terminal varchar(20)
);

SELECT aws_s3.table_import_from_s3(
	'stg_trucks',
	'',
	'(FORMAT csv, HEADER true)',
	aws_commons.create_s3_uri(
		'chariot-dts',
		'logisticsSQLGrafana/trucks.csv',
		'ap-south-1'
	)
);

-- 120 rows imported into relation "stg_trucks" from file logisticsSQLGrafana/trucks.csv of 11213 bytes
select * from stg_trucks limit 10;