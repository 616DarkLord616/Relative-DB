CREATE TABLE car_model ( 
    model_id SERIAL PRIMARY KEY,
    brand VARCHAR(50) NOT NULL,
    model_name VARCHAR(50) NOT NULL,
    category VARCHAR(20) NOT NULL CHECK (category IN ('Economy', 'Compact', 'Mid-size', 'Full-size', 'SUV', 'Luxury', 'Minivan')),
    seats NUMERIC NOT NULL CHECK (seats BETWEEN 2 AND 9),
    fuel_type VARCHAR(20) NOT NULL CHECK (fuel_type IN ('Petrol', 'Diesel', 'Electric', 'Hybrid')),
    daily_rate MONEY NOT NULL CHECK (daily_rate > 0::MONEY),
    UNIQUE(brand, model_name)
);

CREATE TABLE branch (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    branch_id INTEGER NOT NULL,  
    manager_id INTEGER,          
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(30) NOT NULL CHECK (position IN ('Manager', 'Sales Agent', 'Mechanic', 'Customer Service')),
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    salary MONEY CHECK (salary > 0::MONEY),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(50),
    driver_license_number VARCHAR(30) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE,
    is_verified BOOLEAN DEFAULT FALSE
);

CREATE TABLE car (
    car_id SERIAL PRIMARY KEY,
    model_id INTEGER NOT NULL,    
    branch_id INTEGER NOT NULL,   
    registration_number VARCHAR(20) UNIQUE NOT NULL,
    vin VARCHAR(17) UNIQUE NOT NULL,
    color VARCHAR(30),
    manufacturing_year NUMERIC NOT NULL CHECK (manufacturing_year >= 2010),
    current_mileage NUMERIC DEFAULT 0 CHECK (current_mileage >= 0),
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'rented', 'maintenance', 'out_of_service')),
    last_maintenance_date DATE,
    next_maintenance_mileage NUMERIC
);

CREATE TABLE rental (
    rental_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,      
    car_id INTEGER NOT NULL,           
    employee_id INTEGER NOT NULL,      
    pickup_branch_id INTEGER NOT NULL, 
    return_branch_id INTEGER NOT NULL, 
    rental_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    scheduled_return_date TIMESTAMP NOT NULL,
    actual_return_date TIMESTAMP,
    pickup_odometer NUMERIC NOT NULL,
    return_odometer NUMERIC CHECK (return_odometer >= pickup_odometer OR return_odometer IS NULL),
    daily_rate MONEY NOT NULL CHECK (daily_rate > 0::MONEY),
    total_rental_days NUMERIC,
    total_amount MONEY CHECK (total_amount >= 0::MONEY OR total_amount IS NULL),
    late_fee MONEY DEFAULT 0::MONEY,
    insurance_fee MONEY DEFAULT 0::MONEY,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('reserved', 'active', 'completed', 'cancelled'))
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    rental_id INTEGER NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount MONEY NOT NULL CHECK (amount > 0::MONEY),
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('credit_card', 'debit_card', 'cash', 'bank_transfer')),
    transaction_id VARCHAR(50) UNIQUE,
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    card_last_four VARCHAR(4)
);

-- Employee foreign keys
ALTER TABLE employee 
ADD CONSTRAINT fk_employee_branch 
FOREIGN KEY (branch_id) REFERENCES branch(branch_id);

ALTER TABLE employee 
ADD CONSTRAINT fk_employee_manager 
FOREIGN KEY (manager_id) REFERENCES employee(employee_id);

-- Car foreign keys
ALTER TABLE car 
ADD CONSTRAINT fk_car_model 
FOREIGN KEY (model_id) REFERENCES car_model(model_id);

ALTER TABLE car 
ADD CONSTRAINT fk_car_branch 
FOREIGN KEY (branch_id) REFERENCES branch(branch_id);

-- Rental foreign keys
ALTER TABLE rental 
ADD CONSTRAINT fk_rental_customer 
FOREIGN KEY (customer_id) REFERENCES customer(customer_id);

ALTER TABLE rental 
ADD CONSTRAINT fk_rental_car 
FOREIGN KEY (car_id) REFERENCES car(car_id);

ALTER TABLE rental 
ADD CONSTRAINT fk_rental_employee 
FOREIGN KEY (employee_id) REFERENCES employee(employee_id);

ALTER TABLE rental 
ADD CONSTRAINT fk_rental_pickup_branch 
FOREIGN KEY (pickup_branch_id) REFERENCES branch(branch_id);

ALTER TABLE rental 
ADD CONSTRAINT fk_rental_return_branch 
FOREIGN KEY (return_branch_id) REFERENCES branch(branch_id);

-- Payment foreign key
ALTER TABLE payment 
ADD CONSTRAINT fk_payment_rental 
FOREIGN KEY (rental_id) REFERENCES rental(rental_id);

-- Check constraint for rental dates
ALTER TABLE rental 
ADD CONSTRAINT chk_rental_dates 
CHECK (scheduled_return_date > rental_date AND 
       (actual_return_date IS NULL OR actual_return_date >= rental_date));
