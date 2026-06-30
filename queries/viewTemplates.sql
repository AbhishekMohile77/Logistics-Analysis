-- QUERIES + CREATING VIEWS TO PLUG IN GRAFANA

-- TOTAL REVENUE
select round( sum( round( (revenue - fuel_surcharge)::numeric,2) )/1000000 ::numeric,2) from stg_loads ;


-- TOTAL LOADS
select count(load_id) from stg_loads;

-- VIEW FOR ACTIVE DRIVERS
select count(*) as total_drivers from stg_drivers;


-- VIEW FOR ACTIVE TRUCKS
select count(truck_id) as total_trucks from stg_trucks;

-- TOTAL ACTIVE CUSTOMERS
select count(*) from stg_customers where account_status='Active';



-- year-month wise load series
create or replace view vw_year_month_loads as
select EXTRACT(year from load_date) as year,
EXTRACT(month from load_date) as month,
count(EXTRACT(month from load_date)) as total 
from stg_loads
group by EXTRACT(year from load_date), EXTRACT(month from load_date)
ORDER BY year, month;

select * from vw_year_month_loads;




-- create view for total revenue across 3 years brand operation
create or replace view vw_total_revenue as 
with actual_rev as (
select ROUND((revenue - fuel_surcharge)::numeric,1) as actual 
from stg_loads
)
select round(sum(actual)/1000000 ::numeric,3) as Total_Revenue_Mils from actual_rev;


-- VIEW YEAR-MONTH WISE REVENUES
create or replace view vw_yearmonth_revenues as
select EXTRACT(year from load_date) as load_year,
EXTRACT(month from load_date) as load_month, 
round((sum(revenue - fuel_surcharge)/1000000)::numeric,2) as revenue_millions 
from stg_loads
group by load_year,load_month
order by load_year,load_month;



-- day wise revenue (grafana time-series test)
create or replace view vw_daywise_revenues as
select load_date, round((sum(revenue - fuel_surcharge)/1000)::numeric,2) as day_revenue_Ks
from stg_loads
group by load_date
order by load_date;




-- VIEW FOR TRIP DISTANCE
create view vw_distance_info as 
select min(actual_distance_miles) as minimum_miles, 
round(avg(actual_distance_miles)::numeric,2) as average_miles, 
max(actual_distance_miles) as maximum_miles
from stg_trips;



-- VIEW FOR TOP 10 CUSTOMERS
create or replace view vw_top_customers as 
select customer_name, round((sum(annual_revenue_potential)/1000000)::numeric,2) as customer_revenue_millions
from stg_customers
group by customer_name
order by sum(annual_revenue_potential) desc
limit 10;

select * from vw_top_customers;

----------------------------------

-- QUERIES FOR DASHBOARD TAB2 FLEET PERFORMANCE

select * from stg_trucks;

-- truck status
select status, count(status) as truck_count 
from stg_trucks
where status is not null
group by status
order by truck_count;


-- maintenance records
select * from stg_maintenance_records;
-- total maint cost by type of service
select service_description, round(sum(total_cost)::numeric,2) as total_cost
from stg_maintenance_records
group by service_description
order by total_cost desc;

-- total maint cost
select round((sum(total_cost)/1000000)::numeric,4) as maintenance_costs_millions
from stg_maintenance_records;



-- stg truck utils
select * from stg_truck_utilization;

-- average mpg + utilzn every trip
select round(avg(average_mpg)::numeric,2) as avg_mileage_mpg,
round(avg(utilization_rate)::numeric,2) as utilization_rate
from stg_truck_utilization;


select round((sum(total_cost)/1000000)::numeric,2) as total_cost_millions FROM STG_FUEL_PURCHASES; 
select * from stg_fuel_purchases limit 25;
select * from stg_trucks;


select * from stg_trips limit 10;
select * from stg_trucks limit 10;

select * from stg_maintenance_records;

select maintenance_type, count(maintenance_type) as maint_count
from stg_maintenance_records 
group by maintenance_type
order by maint_count;


-- downtime hours top 5 + avg
select avg(downtime_hours) from stg_truck_utilization;

select 
	truck_id, avg(downtime_hours) as dt_hrs
from 
	stg_truck_utilization
group by truck_id
order by dt_hrs limit 3;



select T.truck_brand as brand, avg(TU.downtime_hours) as dt_hrs 
from 
	stg_trucks as T
join 
	stg_truck_utilization as TU
on 
	T.truck_id = TU.truck_id
group by T.truck_brand
order by dt_hrs;



----------------------------------

-- QUERIES FOR DASHBOARD TAB3 DRIVERS/TRIPS

-- DRIVER STATUS 
select employment_status, count(employment_status) 
from stg_drivers
where employment_status is not null
group by employment_status;


-- AVG DRIVER EXPERIENCE
select round(avg(years_experience)::numeric,2) from stg_drivers;


-- HIGHEST PERFORMING/TRIPS PER DRIVER
select driver_id, sum(trips_completed) as total_trips
from stg_driver_monthly_metrics
group by driver_id
order by total_trips desc;


-- HIHEST PERFM DRIVER WITH NAMES
with driver_agg as (
	select driver_id, sum(trips_completed) as total_trips, 
	round(avg(average_idle_hours)::numeric,2) as avg_idle
	from stg_driver_monthly_metrics
	group by driver_id
	order by total_trips desc
)
select AG.driver_id, concat(SDR.first_name,' ',SDR.last_name) as driver_name, AG.total_trips
from driver_agg AG
join stg_drivers SDR
on AG.driver_id = SDR.driver_id;



select round(avg(years_experience)::numeric,2) as avg_experience, 
avg(total_revenue) as average_revenue,
avg(average_idle_hours) as idle_avg,
avg(total_miles) as avg_distance
from stg_drivers
join stg_driver_monthly_metrics 
on stg_drivers.driver_id = stg_driver_monthly_metrics.driver_id ;


select * from stg_routes;
select origin_state,destination_state from stg_routes;


select facility_name, city, state from stg_facilities;
