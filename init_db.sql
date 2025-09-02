-- Create Roles Table
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(10) UNIQUE NOT NULL CHECK(role_name IN ('admin', 'user'))
);

-- Create Users Table (Django-compatible)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login TIMESTAMP,
    is_superuser BOOLEAN DEFAULT FALSE,
    first_name VARCHAR(150) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    is_staff BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    date_joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    is_admin BOOLEAN DEFAULT FALSE
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
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK(end_date > start_date),
    price NUMERIC(10,2) CHECK(price >= 0 AND price <= 10000),
    image_file VARCHAR(255) NOT NULL
);

-- Create Likes Table (Tracks which users like which vacations)
CREATE TABLE likes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    vacation_id INTEGER REFERENCES vacations(id) ON DELETE CASCADE,
    UNIQUE(user_id, vacation_id)
);

-- Create Django Session Table
CREATE TABLE django_session (
    session_key VARCHAR(40) PRIMARY KEY,
    session_data TEXT NOT NULL,
    expire_date TIMESTAMP NOT NULL
);

-- Create Django Content Types Table
CREATE TABLE django_content_type (
    id SERIAL PRIMARY KEY,
    app_label VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    UNIQUE(app_label, model)
);

-- Create Django Migrations Table
CREATE TABLE django_migrations (
    id SERIAL PRIMARY KEY,
    app VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert predefined roles
INSERT INTO roles (role_name) VALUES ('admin'), ('user');

-- Insert at least 2 users (one admin, one regular user) with hashed passwords
INSERT INTO users (first_name, last_name, email, password, role_id, is_admin, is_active, is_staff, is_superuser)
VALUES 
('Admin', 'User', 'admin@example.com', 'pbkdf2_sha256$1000000$xuMOp48JFFzacYPyJ4HN0a$N6F6nBrKQoL9y8rCP1dqHvGQHzZ9iYcuyztjjDiDz90=', 1, TRUE, TRUE, TRUE, TRUE),
('Regular', 'User', 'user@example.com', 'pbkdf2_sha256$1000000$Yqb7rbbgpuBXszKJVA5pNl$T+KOnfPMjY75Z8XW+AX+cWm8aA72QGgll/UoFdPfbco=', 2, FALSE, TRUE, FALSE, FALSE);

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
(1, 'Tel Aviv', '2025-10-01', '2025-10-10', 1500, 'telaviv.jpg'),  -- Israel (Fixed: was default.jpg)
(2, 'Madrid', '2025-11-05', '2025-11-15', 1200, 'madrid.jpg'),     -- Spain
(3, 'Rome', '2025-12-01', '2025-12-10', 1800, 'rome.jpg'),         -- Italy
(4, 'Paris', '2026-01-01', '2026-01-07', 2000, 'paris.jpg'),       -- France
(5, 'Berlin', '2026-02-10', '2026-02-17', 1400, 'berlin.jpg'),     -- Germany
(6, 'Tokyo', '2026-03-01', '2026-03-14', 2500, 'tokyo.jpg'),       -- Japan (Fixed: only one Japan entry with correct tokyo.jpg)
(7, 'Rio', '2025-12-20', '2025-12-28', 2200, 'rio.jpg'),           -- Brazil
(8, 'Buenos Aires', '2026-01-10', '2026-01-17', 1900, 'buenosaires.jpg'), -- Argentina
(9, 'New York City', '2026-02-10', '2026-02-20', 1600, 'nyc.jpg'), -- United States
(10, 'Sydney', '2026-03-05', '2026-03-15', 2300, 'sydney.jpg'),    -- Australia
(11, 'Medellin', '2025-11-20', '2025-11-27', 2100, 'medellin.jpg'), -- Colombia
(9, 'Los Angeles', '2026-04-01', '2026-04-10', 1800, 'losangeles.jpg'); -- United States (Los Angeles)
