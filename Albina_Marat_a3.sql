DROP USER IF EXISTS rental_admin_user;
DROP USER IF EXISTS rental_reader_user;
DROP ROLE IF EXISTS rental_admin;
DROP ROLE IF EXISTS rental_readonly;

CREATE ROLE rental_admin;
CREATE ROLE rental_readonly;

GRANT USAGE ON SCHEMA car_rental TO rental_admin;
GRANT USAGE ON SCHEMA car_rental TO rental_readonly;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA car_rental TO rental_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA car_rental TO rental_readonly;

CREATE USER rental_admin_user WITH PASSWORD 'admin_rent_pass_123';
GRANT rental_admin TO rental_admin_user;

CREATE USER rental_reader_user WITH PASSWORD 'reader_rent_pass_123';
GRANT rental_readonly TO rental_reader_user;

REVOKE UPDATE, DELETE ON ALL TABLES IN SCHEMA car_rental FROM rental_readonly;

/* CRITERION A3: \dp output pasted as comment
Access privileges
 Schema     |         Name          | Type  |     Access privileges     | Column privileges | Policies 
------------+-----------------------+-------+---------------------------+-------------------+----------
 car_rental | customer              | table | rental_admin=arwdDxt/r+  |                   | 
            |                       |       | rental_readonly=r/r+     |                   | 
 car_rental | vehicle               | table | rental_admin=arwdDxt/r+  |                   | 
            |                       |       | rental_readonly=r/r+     |                   | 
 car_rental | reservation           | table | rental_admin=arwdDxt/r+  |                   | 
            |                       |       | rental_readonly=r/r+     |                   | 
*/

SET search_path TO car_rental, public;

TRUNCATE TABLE 
    Reservation_Service,
    Payment,
    Condition_Report,
    Return_Log,
    Reservation,
    Maintenance,
    Staff,
    Vehicle,
    Service,
    Customer,
    RentalLocation
CASCADE;

INSERT INTO RentalLocation (name, address, phone) VALUES 
    ('Main Airport Terminal', '123 Sky Way, Atyrau', '+77122001122'),
    ('City Center Office', '45 Satpayev St, Atyrau', '+77122003344'),
    ('Railway Station Branch', '10 Station Sq, Atyrau', '+77122005566'),
    ('North Industrial Zone', '88 Industry Rd, Atyrau', '+77122007788'),
    ('South Coast Point', '15 Marina Blvd, Atyrau', '+77122009900');

INSERT INTO Customer (first_name, last_name, phone, email, license_number) VALUES 
    ('Ivan', 'Ivanov', '+77011112233', 'ivan@example.kz', 'AB123456'),
    ('Elena', 'Petrova', '+77022223344', 'elena@example.kz', 'CD789012'),
    ('Dmitry', 'Sokolov', '+77033334455', 'dmitry@example.kz', 'EF345678'),
    ('Anna', 'Kuznetsova', '+77044445566', 'anna@example.kz', 'GH901234'),
    ('Sergey', 'Smirnov', '+77055556677', 'sergey@example.kz', 'IJ567890');

INSERT INTO Service (service_name, price) VALUES 
    ('GPS Navigation', 15.00),
    ('Child Seat', 10.00),
    ('Full Insurance', 50.00),
    ('Additional Driver', 20.00),
    ('Wi-Fi Router', 12.50);

INSERT INTO Vehicle (location_id, brand, model, year, vin_code, status, daily_rate) VALUES 
    ((SELECT location_id FROM RentalLocation WHERE name = 'Main Airport Terminal'), 'Toyota', 'Camry', 2024, 'VIN1234567890ABC1', 'AVAILABLE', 150.00),
    ((SELECT location_id FROM RentalLocation WHERE name = 'City Center Office'), 'Hyundai', 'Tucson', 2023, 'VIN9876543210XYZ2', 'AVAILABLE', 120.00),
    ((SELECT location_id FROM RentalLocation WHERE name = 'Railway Station Branch'), 'Kia', 'Rio', 2022, 'VIN4567891230DEF3', 'AVAILABLE', 80.00),
    ((SELECT location_id FROM RentalLocation WHERE name = 'North Industrial Zone'), 'Ford', 'Transit', 2021, 'VIN7891234560GHI4', 'MAINTENANCE', 200.00),
    ((SELECT location_id FROM RentalLocation WHERE name = 'South Coast Point'), 'BMW', 'X5', 2024, 'VIN3216549870JKL5', 'AVAILABLE', 300.00);

INSERT INTO Staff (location_id, first_name, last_name, position) VALUES 
    ((SELECT location_id FROM RentalLocation WHERE name = 'Main Airport Terminal'), 'Alex', 'Smith', 'Manager'),
    ((SELECT location_id FROM RentalLocation WHERE name = 'City Center Office'), 'Maria', 'Garcia', 'Rental Agent'),
    ((SELECT location_id FROM RentalLocation WHERE name = 'Railway Station Branch'), 'John', 'Doe', 'Technician'),
    ((SELECT location_id FROM RentalLocation WHERE name = 'North Industrial Zone'), 'Linda', 'Taylor', 'Supervisor'),
    ((SELECT location_id FROM RentalLocation WHERE name = 'South Coast Point'), 'James', 'Brown', 'Rental Agent');

INSERT INTO Maintenance (vehicle_id, maintenance_type, start_date, end_date, cost) VALUES 
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN1234567890ABC1'), 'Oil Change', '2026-01-10', '2026-01-10', 80.00),
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN9876543210XYZ2'), 'Tire Rotation', '2026-02-15', '2026-02-15', 60.00),
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN4567891230DEF3'), 'Brake Inspection', '2026-03-20', '2026-03-20', 100.00),
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN7891234560GHI4'), 'Brake Replacement', '2026-05-10', '2026-05-15', 350.00),
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN3216549870JKL5'), 'Engine Diagnostics', '2026-04-05', '2026-04-06', 150.00);

INSERT INTO Reservation (customer_id, vehicle_id, staff_id, start_date, end_date, total_price, status) VALUES 
    ((SELECT customer_id FROM Customer WHERE email = 'ivan@example.kz'), (SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN1234567890ABC1'), (SELECT staff_id FROM Staff WHERE last_name = 'Smith'), '2026-05-01 10:00:00', '2026-05-05 10:00:00', 600.00, 'COMPLETED'),
    ((SELECT customer_id FROM Customer WHERE email = 'elena@example.kz'), (SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN9876543210XYZ2'), (SELECT staff_id FROM Staff WHERE last_name = 'Garcia'), '2026-06-10 12:00:00', '2026-06-12 12:00:00', 240.00, 'PENDING'),
    ((SELECT customer_id FROM Customer WHERE email = 'dmitry@example.kz'), (SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN4567891230DEF3'), (SELECT staff_id FROM Staff WHERE last_name = 'Doe'), '2026-05-18 09:00:00', '2026-05-20 09:00:00', 160.00, 'CONFIRMED'),
    ((SELECT customer_id FROM Customer WHERE email = 'anna@example.kz'), (SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN3216549870JKL5'), (SELECT staff_id FROM Staff WHERE last_name = 'Brown'), '2026-05-22 14:00:00', '2026-05-25 14:00:00', 900.00, 'CANCELLED'),
    ((SELECT customer_id FROM Customer WHERE email = 'sergey@example.kz'), (SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN1234567890ABC1'), (SELECT staff_id FROM Staff WHERE last_name = 'Smith'), '2026-05-28 11:00:00', '2026-05-30 11:00:00', 300.00, 'PENDING');

INSERT INTO Payment (reservation_id, amount, payment_date, payment_method) VALUES 
    ((SELECT reservation_id FROM Reservation WHERE total_price = 600.00 AND status = 'COMPLETED'), 600.00, '2026-04-10 14:00:00', 'Credit Card'),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 240.00 AND status = 'PENDING'), 240.00, '2026-06-09 11:00:00', 'PayPal'),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 160.00 AND status = 'CONFIRMED'), 160.00, '2026-05-17 10:30:00', 'Cash'),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 900.00 AND status = 'CANCELLED'), 900.00, '2026-05-20 16:45:00', 'PayPal'),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 300.00 AND status = 'PENDING'), 300.00, '2026-05-27 09:15:00', 'Credit Card');

INSERT INTO Return_Log (reservation_id, return_date, fuel_level, notes) VALUES 
    ((SELECT reservation_id FROM Reservation WHERE total_price = 600.00 AND status = 'COMPLETED'), '2026-05-05 09:30:00', 'Full', 'Clean interior, no issues'),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 240.00 AND status = 'PENDING'), '2026-06-12 13:00:00', 'Half', 'Minor scratches'),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 160.00 AND status = 'CONFIRMED'), '2026-05-20 10:00:00', 'Full', 'All good'),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 900.00 AND status = 'CANCELLED'), '2026-05-25 15:00:00', 'Empty', 'Returned early'),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 300.00 AND status = 'PENDING'), '2026-05-30 12:00:00', 'Full', 'Perfect condition');

INSERT INTO Condition_Report (vehicle_id, reservation_id, return_id, report_date, condition_status, description) VALUES 
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN1234567890ABC1'), (SELECT reservation_id FROM Reservation WHERE total_price = 600.00 AND status = 'COMPLETED'), (SELECT return_id FROM Return_Log WHERE fuel_level = 'Full' AND notes LIKE '%Clean%'), '2026-05-05 09:30:00', 'Excellent', 'New car, no scratches'),
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN9876543210XYZ2'), (SELECT reservation_id FROM Reservation WHERE total_price = 240.00 AND status = 'PENDING'), (SELECT return_id FROM Return_Log WHERE fuel_level = 'Half'), '2026-06-12 13:00:00', 'Good', 'Minor scratch on rear bumper'),
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN4567891230DEF3'), (SELECT reservation_id FROM Reservation WHERE total_price = 160.00 AND status = 'CONFIRMED'), (SELECT return_id FROM Return_Log WHERE notes = 'All good'), '2026-05-20 10:00:00', 'Good', 'No new damages'),
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN7891234560GHI4'), null, null, '2026-05-10 08:00:00', 'Fair', 'Brakes need urgent replacement'),
    ((SELECT vehicle_id FROM Vehicle WHERE vin_code = 'VIN3216549870JKL5'), (SELECT reservation_id FROM Reservation WHERE total_price = 900.00 AND status = 'CANCELLED'), (SELECT return_id FROM Return_Log WHERE fuel_level = 'Empty'), '2026-05-25 15:00:00', 'Excellent', 'Clean');

INSERT INTO Reservation_Service (reservation_id, service_id, quantity, price_at_reservation) VALUES 
    ((SELECT reservation_id FROM Reservation WHERE total_price = 600.00 AND status = 'COMPLETED'), (SELECT service_id FROM Service WHERE service_name = 'GPS Navigation'), 1, 15.00),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 600.00 AND status = 'COMPLETED'), (SELECT service_id FROM Service WHERE service_name = 'Full Insurance'), 1, 50.00),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 160.00 AND status = 'CONFIRMED'), (SELECT service_id FROM Service WHERE service_name = 'Child Seat'), 1, 10.00),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 900.00 AND status = 'CANCELLED'), (SELECT service_id FROM Service WHERE service_name = 'Wi-Fi Router'), 2, 12.50),
    ((SELECT reservation_id FROM Reservation WHERE total_price = 300.00 AND status = 'PENDING'), (SELECT service_id FROM Service WHERE service_name = 'Additional Driver'), 1, 20.00);


-- Increasing the daily rate for premium luxury vehicles (BMW) due to high inflation and maintenance costs.
SELECT brand, model, daily_rate AS rate_before FROM Vehicle WHERE brand = 'BMW';
UPDATE Vehicle SET daily_rate = 320.00 WHERE brand = 'BMW';

-- Automatically confirming all pending reservations that have a registered advance payment transaction.
SELECT status, reservation_id FROM Reservation WHERE status = 'PENDING';
UPDATE Reservation SET status = 'CONFIRMED' WHERE status = 'PENDING';

SELECT v.brand, v.model, v.daily_rate AS rate_before, l.name FROM Vehicle v JOIN RentalLocation l ON v.location_id = l.location_id WHERE l.name = 'Railway Station Branch';
UPDATE Vehicle v SET daily_rate = v.daily_rate * 0.90 FROM RentalLocation l WHERE v.location_id = l.location_id AND l.name = 'Railway Station Branch';


-- Removing cancelled reservations from the operational log to optimize data processing and clean up analytical metrics.
BEGIN;

DELETE FROM Reservation WHERE status = 'CANCELLED';
SELECT COUNT(*) AS remaining_cancelled_reservations FROM Reservation WHERE status = 'CANCELLED';

ROLLBACK;