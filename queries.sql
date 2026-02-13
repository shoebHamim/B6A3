-- CREATING THE TABLES AND POPULATING

--1. users table
CREATE TYPE user_role AS ENUM ('Admin', 'Customer');
create table users(
user_id serial PRIMARY key,
name varchar(100) not null,
email VARCHAR(100) UNIQUE not null,
phone VARCHAR(100),
role user_role not null DEFAULT 'Customer');

INSERT INTO users (user_id, name, email, phone, role)
VALUES
(1, 'Alice', 'alice@example.com', '1234567890', 'Customer'),
(2, 'Bob', 'bob@example.com', '0987654321', 'Admin'),
(3, 'Charlie', 'charlie@example.com', '1122334455', 'Customer');

--2.vehicles table
create type vehicle_type as ENUM('car','bike','truck');

create type vehicle_status as ENUM('available','rented','maintenance');

CREATE TABLE vehicles(
vehicle_id serial PRIMARY key,
name varchar(100) not null,
type vehicle_type,
model int,
registration_number VARCHAR(100) unique,
rental_price int,
status vehicle_status);

INSERT INTO vehicles (vehicle_id, name, type, model, registration_number, rental_price, status)
VALUES
(1, 'Toyota Corolla', 'car', 2022, 'ABC-123', 50, 'available'),
(2, 'Honda Civic', 'car', 2021, 'DEF-456', 60, 'rented'),
(3, 'Yamaha R15', 'bike', 2023, 'GHI-789', 30, 'available'),
(4, 'Ford F-150', 'truck', 2020, 'JKL-012', 100, 'maintenance');

-- 3. bookings table
create type booking_type as enum('completed','confirmed','pending','cancelled');
CREATE TABLE bookings(
booking_id serial PRIMARY key,
user_id int REFERENCES users(user_id) ON DELETE CASCADE,
vehicle_id int REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
start_date DATE,
end_date DATE,
status booking_type,
total_cost int);

INSERT INTO bookings (booking_id, user_id, vehicle_id, start_date, end_date, status, total_cost)
VALUES
(1, 1, 2, '2023-10-01', '2023-10-05', 'completed', 240),
(2, 1, 2, '2023-11-01', '2023-11-03', 'completed', 120),
(3, 3, 2, '2023-12-01', '2023-12-02', 'confirmed', 60),
(4, 1, 1, '2023-12-10', '2023-12-12', 'pending', 100);



-- MAIN QUERIES
-- Query 1: JOIN

SELECT booking_id,u.name as customer_name,v.name as vehicle_name,b.start_date,b.end_date,b.status FROM bookings b
INNER JOIN users u
on b.user_id=u.user_id
INNER join vehicles v
on b.vehicle_id=v.vehicle_id;

-- Query 2: EXISTS
SELECT * from vehicles v
WHERE NOT EXISTS(
SELECT 1 FROM bookings b
WHERE b.vehicle_id=v.vehicle_id
);

-- Query 3: WHERE
SELECT * FROM vehicles where status='available' and type='car';


-- Query 4: GROUP BY and HAVING
SELECT v.name, count(*) as total_bookings FROM bookings b
JOIN vehicles v
on b.vehicle_id=v.vehicle_id
GROUP BY(v.name)
HAVING(count(*)>2);
