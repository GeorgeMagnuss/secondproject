-- Create Roles Table
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(10) UNIQUE NOT NULL CHECK(role_name IN ('admin', 'user'))
);

-- Create Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE
);

-- Create Countries Table
CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL
);

-- Create Vacations Table
CREATE TABLE vacations (
    id SERIAL PRIMARY KEY,
    country_id INTEGER REFERENCES countries(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    start_date DATE NOT NULL CHECK(start_date >= CURRENT_DATE),
    end_date DATE NOT NULL CHECK(end_date > start_date),
    price NUMERIC(10,2) CHECK(price >= 0 AND price <= 10000),
    image_file VARCHAR(255) NOT NULL
);

-- Create Likes Table (Tracks which users like which vacations)
CREATE TABLE likes (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    vacation_id INTEGER REFERENCES vacations(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, vacation_id)
);

-- Insert predefined roles
INSERT INTO roles (role_name) VALUES ('admin'), ('user');

-- Insert at least 2 users (one admin, one regular user)
INSERT INTO users (first_name, last_name, email, password, role_id)
VALUES 
('Admin', 'User', 'admin@example.com', 'adminpass', 1),
('Regular', 'User', 'user@example.com', 'userpass', 2);

-- Insert at least 12 countries (United States included)
INSERT INTO countries (country_name)
VALUES 
('Israel'),        -- 1
('Spain'),         -- 2
('Italy'),         -- 3
('France'),        -- 4
('Germany'),       -- 5
('Japan'),         -- 6
('Brazil'),        -- 7
('Argentina'),     -- 8
('United States'), -- 9
('Australia'),     -- 10
('Colombia');      -- 11

-- Insert at least 12 vacations with the correct country IDs
INSERT INTO vacations (country_id, description, start_date, end_date, price, image_file)
VALUES 
(1, 'Tel Aviv', '2025-06-01', '2025-06-10', 1500, 'telaviv.jpg'),  -- Israel
(2, 'Madrid', '2025-07-05', '2025-07-15', 1200, 'madrid.jpg'),     -- Spain
(3, 'Rome', '2025-08-01', '2025-08-10', 1800, 'rome.jpg'),         -- Italy
(4, 'Paris', '2025-09-01', '2025-09-07', 2000, 'paris.jpg'),       -- France
(5, 'Berlin', '2025-10-10', '2025-10-17', 1400, 'berlin.jpg'),     -- Germany
(6, 'Tokyo', '2025-11-01', '2025-11-14', 2500, 'tokyo.jpg'),       -- Japan
(7, 'Rio', '2025-05-20', '2025-05-28', 2200, 'rio.jpg'),           -- Brazil
(8, 'Buenos Aires', '2025-06-10', '2025-06-17', 1900, 'buenosaires.jpg'), -- Argentina
(9, 'New York City', '2025-07-10', '2025-07-20', 1600, 'nyc.jpg'), -- United States
(10, 'Sydney', '2025-08-05', '2025-08-15', 2300, 'sydney.jpg'),    -- Australia
(11, 'Medellin', '2025-06-20', '2025-06-27', 2100, 'medellin.jpg'), -- Colombia
(9, 'Los Angeles', '2025-09-01', '2025-09-10', 1800, 'losangeles.jpg'); -- United States (Los Angeles)
