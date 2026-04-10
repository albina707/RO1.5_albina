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
