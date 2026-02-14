# Vehicle Rental Management System - PostgreSQL

A relational database project for managing a vehicle rental service, built with PostgreSQL. This project demonstrates core SQL concepts including table design with custom ENUM types, foreign key relationships, and advanced querying techniques.

> **Assignment:** Programming Hero - Level 2, Batch 6

---

## Table of Contents

- [Database Schema](#database-schema)
- [Tables Overview](#tables-overview)
- [Query Explanations](#query-explanations)
- [How to Run](#how-to-run)

---

## Database Schema

The database consists of **three** tables connected through foreign key relationships:

```
users (1) ──────< bookings >────── (1) vehicles
```

- A **user** can have many **bookings**.
- A **vehicle** can appear in many **bookings**.
- Deleting a user or vehicle cascades to remove related bookings.

---

## Tables Overview

### 1. `users`

Stores customer and admin information.

| Column    | Type                           | Constraints              |
| --------- | ------------------------------ | ------------------------ |
| `user_id` | `SERIAL`                       | Primary Key              |
| `name`    | `VARCHAR(100)`                 | NOT NULL                 |
| `email`   | `VARCHAR(100)`                 | UNIQUE, NOT NULL         |
| `phone`   | `VARCHAR(100)`                 | -                        |
| `role`    | `ENUM('Admin', 'Customer')`    | NOT NULL, DEFAULT 'Customer' |

### 2. `vehicles`

Stores vehicle inventory with type, pricing, and availability status.

| Column                | Type                                       | Constraints |
| --------------------- | ------------------------------------------ | ----------- |
| `vehicle_id`          | `SERIAL`                                   | Primary Key |
| `name`                | `VARCHAR(100)`                             | NOT NULL    |
| `type`                | `ENUM('car', 'bike', 'truck')`             | -           |
| `model`               | `INT`                                      | -           |
| `registration_number` | `VARCHAR(100)`                             | UNIQUE      |
| `rental_price`        | `INT`                                      | -           |
| `status`              | `ENUM('available', 'rented', 'maintenance')` | -         |

### 3. `bookings`

Tracks rental bookings linking users to vehicles with date ranges and cost.

| Column       | Type                                                  | Constraints                            |
| ------------ | ----------------------------------------------------- | -------------------------------------- |
| `booking_id` | `SERIAL`                                              | Primary Key                            |
| `user_id`    | `INT`                                                 | FK -> `users(user_id)` ON DELETE CASCADE |
| `vehicle_id` | `INT`                                                 | FK -> `vehicles(vehicle_id)` ON DELETE CASCADE |
| `start_date` | `DATE`                                                | -                                      |
| `end_date`   | `DATE`                                                | -                                      |
| `status`     | `ENUM('completed', 'confirmed', 'pending', 'cancelled')` | -                                  |
| `total_cost` | `INT`                                                 | -                                      |

---

## Query Explanations

### Query 1 -- Retrieve All Bookings with Customer and Vehicle Details (JOIN)

```sql
SELECT booking_id, u.name AS customer_name, v.name AS vehicle_name,
       b.start_date, b.end_date, b.status
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN vehicles v ON b.vehicle_id = v.vehicle_id;
```

**Purpose:** Fetches a complete booking report by joining all three tables. Each row shows the booking ID, who booked it, which vehicle was booked, the rental period, and the booking status. Uses `INNER JOIN` so only bookings with valid user and vehicle references are included.

---

### Query 2 -- Find Vehicles That Have Never Been Booked (EXISTS)

```sql
SELECT * FROM vehicles v
WHERE NOT EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.vehicle_id = v.vehicle_id
);
```

**Purpose:** Identifies vehicles in the inventory that have **zero** booking records. The `NOT EXISTS` subquery checks whether any booking references each vehicle -- if none does, the vehicle is returned. This is useful for spotting underutilized or newly added vehicles.

---

### Query 3 -- Filter Available Cars (WHERE)

```sql
SELECT * FROM vehicles
WHERE status = 'available' AND type = 'car';
```

**Purpose:** Retrieves all vehicles that are both currently **available** for rent and of type **car**. A straightforward filtered query useful for customers searching for a specific vehicle category that is ready to book.

---

### Query 4 -- Vehicles with More Than Two Bookings (GROUP BY & HAVING)

```sql
SELECT v.name, COUNT(*) AS total_bookings
FROM bookings b
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
GROUP BY v.name
HAVING COUNT(*) > 2;
```

**Purpose:** Aggregates booking counts per vehicle and filters to show only those with **more than two** bookings. `GROUP BY` groups all bookings by vehicle name, and `HAVING` applies the condition on the aggregated count. This helps identify the most popular/in-demand vehicles in the fleet.

---

## How to Run

1. Ensure **PostgreSQL** is installed and running.
2. Create a new database:(Inside postgres command line-psql)
   ```bash
   CREATE DATABASE vehicle_rental;
   ```
3. Execute the SQL file in Bash/Command Line:(Change username after -U if different)
   ```bash
   psql -U postgres -d vehicle_rental -f queries.sql
   ```
4. The script will create all tables, insert sample data, and run the queries.

---

## Technologies

- **PostgreSQL** -- Relational database engine
- **SQL** -- Data definition & querying
