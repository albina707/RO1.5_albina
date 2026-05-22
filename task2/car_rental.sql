CREATE SCHEMA IF NOT EXISTS car_rental;
SET search_path TO car_rental, public;

CREATE TABLE IF NOT EXISTS RentalLocation (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT NOT NULL,
    phone VARCHAR(20) UNIQUE
);

CREATE TABLE IF NOT EXISTS Customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    license_number VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Service (
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS Vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    location_id INT REFERENCES RentalLocation(location_id) ON DELETE SET NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT CHECK (year > 1900),
    vin_code VARCHAR(17) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'RENTED', 'MAINTENANCE', 'DAMAGED')),
    daily_rate DECIMAL(10, 2) NOT NULL CHECK (daily_rate > 0)
);

CREATE TABLE IF NOT EXISTS Staff (
    staff_id SERIAL PRIMARY KEY,
    location_id INT REFERENCES RentalLocation(location_id) ON DELETE SET NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    CONSTRAINT uq_staff_name UNIQUE (first_name, last_name)
);

CREATE TABLE IF NOT EXISTS Maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES Vehicle(vehicle_id) ON DELETE CASCADE,
    maintenance_type VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    cost DECIMAL(10, 2) CHECK (cost >= 0),
    CONSTRAINT chk_maint_dates CHECK (end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS Reservation (
    reservation_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customer(customer_id),
    vehicle_id INT NOT NULL REFERENCES Vehicle(vehicle_id),
    staff_id INT REFERENCES Staff(staff_id) ON DELETE SET NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (total_price >= 0),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED')),
    CONSTRAINT chk_dates CHECK (end_date > start_date)
);

CREATE TABLE IF NOT EXISTS Return_Log (
    return_id SERIAL PRIMARY KEY,
    reservation_id INT NOT NULL UNIQUE REFERENCES Reservation(reservation_id) ON DELETE CASCADE,
    return_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fuel_level VARCHAR(20) NOT NULL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS Condition_Report (
    report_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL REFERENCES Vehicle(vehicle_id) ON DELETE CASCADE,
    reservation_id INT REFERENCES Reservation(reservation_id) ON DELETE SET NULL,
    return_id INT REFERENCES Return_Log(return_id) ON DELETE SET NULL,
    report_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    condition_status VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS Payment (
    payment_id SERIAL PRIMARY KEY,
    reservation_id INT NOT NULL REFERENCES Reservation(reservation_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Reservation_Service (
    reservation_id INT REFERENCES Reservation(reservation_id) ON DELETE CASCADE,
    service_id INT REFERENCES Service(service_id) ON DELETE CASCADE,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    price_at_reservation DECIMAL(10, 2) NOT NULL CHECK (price_at_reservation >= 0),
    row_total DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * price_at_reservation) STORED,
    PRIMARY KEY (reservation_id, service_id)
);

INSERT INTO RentalLocation (name, address, phone)
VALUES 
    ('Main Airport Terminal', '123 Sky Way, Atyrau', '+77122001122'),
    ('City Center Office', '45 Satpayev St, Atyrau', '+77122003344')
ON CONFLICT (name) DO NOTHING;

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
ON CONFLICT (service_name) DO NOTHING;

INSERT INTO Vehicle (location_id, brand, model, year, vin_code, status, daily_rate)
VALUES 
    (1, 'Toyota', 'Camry', 2024, 'VIN1234567890ABC1', 'AVAILABLE', 150.00),
    (2, 'Hyundai', 'Tucson', 2023, 'VIN9876543210XYZ2', 'AVAILABLE', 120.00)
ON CONFLICT (vin_code) DO NOTHING;

INSERT INTO Staff (location_id, first_name, last_name, position)
VALUES 
    (1, 'Alex', 'Smith', 'Manager'),
    (2, 'Maria', 'Garcia', 'Rental Agent')
ON CONFLICT (first_name, last_name) DO NOTHING;

INSERT INTO Maintenance (vehicle_id, maintenance_type, start_date, end_date, cost)
VALUES 
    (1, 'Oil Change', '2026-01-10', '2026-01-10', 80.00)
ON CONFLICT DO NOTHING;

INSERT INTO Reservation (customer_id, vehicle_id, staff_id, start_date, end_date, total_price, status)
VALUES 
    (1, 1, 1, '2026-05-01 10:00:00', '2026-05-05 10:00:00', 600.00, 'CONFIRMED'),
    (2, 2, 2, '2026-06-10 12:00:00', '2026-06-12 12:00:00', 240.00, 'PENDING')
ON CONFLICT DO NOTHING;

INSERT INTO Payment (reservation_id, amount, payment_date, payment_method)
VALUES 
    (1, 600.00, '2026-04-10 14:00:00', 'Credit Card')
ON CONFLICT DO NOTHING;

INSERT INTO Return_Log (reservation_id, return_date, fuel_level, notes)
VALUES 
    (1, '2026-05-05 09:30:00', 'Full', 'Clean interior, no issues')
ON CONFLICT (reservation_id) DO NOTHING;

INSERT INTO Condition_Report (vehicle_id, reservation_id, return_id, condition_status, description)
VALUES 
    (1, 1, 1, 'Excellent', 'New car, no scratches')
ON CONFLICT DO NOTHING;

INSERT INTO Reservation_Service (reservation_id, service_id, quantity, price_at_reservation)
VALUES 
    (1, 1, 1, 15.00),
    (1, 3, 1, 50.00)
ON CONFLICT (reservation_id, service_id) DO NOTHING;
