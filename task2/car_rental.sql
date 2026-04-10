CREATE SCHEMA IF NOT EXISTS car_rental;
CREATE TABLE IF NOT EXISTS RentalLocation (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS Customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    license_number VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Service (
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS Vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    location_id INT REFERENCES RentalLocation(location_id) ON DELETE SET NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT CHECK (year > 1900),
    vin_code VARCHAR(17) UNIQUE,
    status VARCHAR(20) DEFAULT 'available',
    daily_rate DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS Staff (
    staff_id SERIAL PRIMARY KEY,
    location_id INT REFERENCES RentalLocation(location_id),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    position VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Condition_Report (
    report_id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES Vehicle(vehicle_id) ON DELETE CASCADE,
    report_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    condition_status VARCHAR(50),
    description TEXT
);

CREATE TABLE IF NOT EXISTS Maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES Vehicle(vehicle_id) ON DELETE CASCADE,
    maintenance_type VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    cost DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS Reservation (
    reservation_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customer(customer_id),
    vehicle_id INT REFERENCES Vehicle(vehicle_id),
    staff_id INT REFERENCES Staff(staff_id),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    total_price DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'pending',
    CHECK (end_date > start_date)
);

CREATE TABLE IF NOT EXISTS Payment (
    payment_id SERIAL PRIMARY KEY,
    reservation_id INT REFERENCES Reservation(reservation_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) 
);

CREATE TABLE IF NOT EXISTS Return_Log (
    return_id SERIAL PRIMARY KEY,
    reservation_id INT REFERENCES Reservation(reservation_id),
    return_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fuel_level VARCHAR(20),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS Reservation_Service (
    reservation_id INT REFERENCES Reservation(reservation_id) ON DELETE CASCADE,
    service_id INT REFERENCES Service(service_id) ON DELETE CASCADE,
    quantity INT DEFAULT 1,
    PRIMARY KEY (reservation_id, service_id)
);

INSERT INTO RentalLocation (name, address, phone)
VALUES 
    ('Main Airport Terminal', '123 Sky Way, Atyrau', '+77122001122'),
    ('City Center Office', '45 Satpayev St, Atyrau', '+77122003344')
ON CONFLICT DO NOTHING;

INSERT INTO Customer (first_name, last_name, phone, email, license_number)
VALUES 
    ('Ivan', 'Ivanov', '+77011112233', 'ivan@example.kz', 'AB123456'),
    ('Elena', 'Petrova', '+77022223344', 'elena@example.kz', 'CD789012')
ON CONFLICT (phone) DO NOTHING;

INSERT INTO Service (service_name, price)
VALUES 
    ('GPS Navigation', 15.00),
    ('Child Seat', 10.00),
    ('Full Insurance', 50.00)
ON CONFLICT DO NOTHING;

INSERT INTO Vehicle (location_id, brand, model, year, vin_code, status, daily_rate)
VALUES 
    (1, 'Toyota', 'Camry', 2024, 'VIN1234567890ABC1', 'available', 150.00),
    (2, 'Hyundai', 'Tucson', 2023, 'VIN9876543210XYZ2', 'available', 120.00)
ON CONFLICT (vin_code) DO NOTHING;

INSERT INTO Staff (location_id, first_name, last_name, position)
VALUES 
    (1, 'Alex', 'Smith', 'Manager'),
    (2, 'Maria', 'Garcia', 'Rental Agent')
ON CONFLICT DO NOTHING;

INSERT INTO Condition_Report (vehicle_id, condition_status, description)
VALUES 
    (1, 'Excellent', 'New car, no scratches'),
    (2, 'Good', 'Minor scratch on rear bumper')
ON CONFLICT DO NOTHING;

INSERT INTO Maintenance (vehicle_id, maintenance_type, start_date, end_date, cost)
VALUES 
    (1, 'Oil Change', '2026-01-10', '2026-01-10', 80.00)
ON CONFLICT DO NOTHING;

INSERT INTO Reservation (customer_id, vehicle_id, staff_id, start_date, end_date, total_price, status)
VALUES 
    (1, 1, 1, '2026-05-01 10:00:00', '2026-05-05 10:00:00', 600.00, 'confirmed'),
    (2, 2, 2, '2026-06-10 12:00:00', '2026-06-12 12:00:00', 240.00, 'pending')
ON CONFLICT DO NOTHING;

INSERT INTO Payment (reservation_id, amount, payment_date, payment_method)
VALUES 
    (1, 600.00, '2026-04-10 14:00:00', 'Credit Card')
ON CONFLICT DO NOTHING;

INSERT INTO Return_Log (reservation_id, return_date, fuel_level, notes)
VALUES 
    (1, '2026-05-05 09:30:00', 'Full', 'Clean interior, no issues')
ON CONFLICT DO NOTHING;

INSERT INTO Reservation_Service (reservation_id, service_id, quantity)
VALUES 
    (1, 1, 1),
    (1, 3, 1)
ON CONFLICT DO NOTHING;
