
-- UPDATING/ADDING PRIMARY AND FOERIGN KEYS USING ERD DIAGRAM

-- add primary key in customers table
ALTER TABLE stg_customers 
ADD PRIMARY KEY (customer_id);

select * from stg_customers limit 5;


-- add primary key in drivers table
ALTER TABLE stg_drivers 
ADD PRIMARY KEY (driver_id);


-- add primary key in loads table
ALTER TABLE stg_loads 
ADD PRIMARY KEY(load_id);


-- add primary key in trailers table
alter table stg_trailers 
add primary key(trailer_id);



-- foreign key attributes in loads table
ALTER TABLE stg_loads
ADD CONSTRAINT fk_load_customer
FOREIGN KEY (customer_id)
REFERENCES stg_customers (customer_id)
ON DELETE RESTRICT,
ADD CONSTRAINT fk_load_route
FOREIGN KEY (route_id)
REFERENCES stg_routes (route_id)
ON DELETE RESTRICT;

-- check fk constraints present or not 
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM 
    pg_constraint 
WHERE 
    contype = 'f' 
    AND conrelid = 'public.stg_loads'::regclass;
-- FOREIGN KEY (customer_id) REFERENCES stg_customers(customer_id) ON DELETE RESTRICT
-- FOREIGN KEY (route_id) REFERENCES stg_routes(route_id) ON DELETE RESTRICT



-- add all foreign keys (4 keys) in trips table
alter table stg_trips
add constraint fk_trips_loads 
foreign key (load_id) 
references stg_loads (load_id)
on delete restrict,

add constraint fk_trips_driver 
foreign key (driver_id) 
references stg_drivers (driver_id)
on delete restrict,

add constraint fk_trips_truck 
foreign key (truck_id) 
references stg_trucks (truck_id) 
on delete restrict,

add constraint fk_trips_trailer 
foreign key (trailer_id) 
references stg_trailers (trailer_id) 
on delete restrict;




-- add 3 foreign keys in fuel_purchase table
alter table stg_fuel_purchases
add constraint fk_fuelp_trip 
foreign key (trip_id) 
references stg_trips (trip_id) 
on delete restrict,

add constraint fk_fuelp_truck 
foreign key (truck_id) 
references stg_trucks (truck_id) 
on delete restrict,

add constraint fk_fuelp_drivre 
foreign key (driver_id) 
references stg_drivers (driver_id) 
on delete restrict;



-- add foreign key in maintenance_records table
alter table stg_maintenance_records
add constraint fk_maintr_truck foreign key (truck_id) references stg_trucks(truck_id) 
on delete restrict;



-- add 3 foreign keys in delivery_events table
alter table stg_delivery_events
add constraint fk_dele_load foreign key (load_id) references stg_loads (load_id) 
on delete restrict,
add constraint fk_dele_trip foreign key (trip_id) references stg_trips (trip_id) 
on delete restrict,
add constraint fk_dele_facility foreign key (facility_id) references stg_facilities (facility_id) 
on delete restrict;


-- add 3 foreign keys in safety_incidents table
alter table stg_safety_incidents
add constraint fk_safetyi_trip foreign key (trip_id) references stg_trips (trip_id) 
on delete restrict,
add constraint fk_safetyi_truck foreign key (truck_id) references stg_trucks (truck_id) 
on delete restrict,
add constraint fk_safetyi_driver foreign key (driver_id) references stg_drivers (driver_id) 
on delete restrict;


-- catalog query
select
    conrelid::regclass AS source_table, 
    conname AS foreign_key_name, 
    confrelid::regclass AS target_table,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint 
WHERE contype = 'f' 
ORDER BY source_table, foreign_key_name;
