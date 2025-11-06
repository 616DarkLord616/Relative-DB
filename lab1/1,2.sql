CREATE TABLE membership_plan (
    plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    description TEXT,
    duration_days NUMERIC NOT NULL CHECK (duration_days > 0),
    price MONEY NOT NULL CHECK (price > 0::MONEY),
    max_sessions_per_week NUMERIC,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE member (
    member_id SERIAL PRIMARY KEY,
    plan_id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    membership_start_date DATE NOT NULL,
    membership_end_date DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'expired', 'cancelled'))
);

CREATE TABLE trainer (
    trainer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    specialization VARCHAR(100),
    experience_years NUMERIC CHECK (experience_years >= 0),
    hourly_rate MONEY NOT NULL CHECK (hourly_rate > 0::MONEY),
    hire_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE trainer_qualification (
    qualification_id SERIAL PRIMARY KEY,
    trainer_id INTEGER NOT NULL,
    qualification_name VARCHAR(100) NOT NULL,
    issuing_organization VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    certificate_number VARCHAR(50)
);

CREATE TABLE training_program (
    program_id SERIAL PRIMARY KEY,
    program_name VARCHAR(100) NOT NULL,
    description TEXT,
    program_type VARCHAR(20) NOT NULL CHECK (program_type IN ('group', 'individual')),
    difficulty_level VARCHAR(20) NOT NULL CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    duration_minutes NUMERIC NOT NULL CHECK (duration_minutes > 0),
    max_participants NUMERIC,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE program_enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL,
    program_id INTEGER NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    UNIQUE(member_id, program_id)
);

CREATE TABLE session (
    session_id SERIAL PRIMARY KEY,
    program_id INTEGER NOT NULL,
    trainer_id INTEGER NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(50),
    current_participants NUMERIC DEFAULT 0 CHECK (current_participants >= 0),
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled'))
);

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    check_out_time TIMESTAMP,
    notes TEXT,
    UNIQUE(session_id, member_id)
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL,
    plan_id INTEGER NOT NULL,
    amount MONEY NOT NULL CHECK (amount > 0::MONEY),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    payment_method VARCHAR(20) CHECK (payment_method IN ('credit_card', 'debit_card', 'cash', 'bank_transfer', 'online')),
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    transaction_id VARCHAR(50) UNIQUE,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL
);

-- Member foreign keys
ALTER TABLE member 
ADD CONSTRAINT fk_member_plan 
FOREIGN KEY (plan_id) REFERENCES membership_plan(plan_id);

-- Trainer qualification foreign keys
ALTER TABLE trainer_qualification 
ADD CONSTRAINT fk_qualification_trainer 
FOREIGN KEY (trainer_id) REFERENCES trainer(trainer_id);

-- Program enrollment foreign keys
ALTER TABLE program_enrollment 
ADD CONSTRAINT fk_enrollment_member 
FOREIGN KEY (member_id) REFERENCES member(member_id);

ALTER TABLE program_enrollment 
ADD CONSTRAINT fk_enrollment_program 
FOREIGN KEY (program_id) REFERENCES training_program(program_id);

-- Session foreign keys
ALTER TABLE session 
ADD CONSTRAINT fk_session_program 
FOREIGN KEY (program_id) REFERENCES training_program(program_id);

ALTER TABLE session 
ADD CONSTRAINT fk_session_trainer 
FOREIGN KEY (trainer_id) REFERENCES trainer(trainer_id);

-- Attendance foreign keys
ALTER TABLE attendance 
ADD CONSTRAINT fk_attendance_session 
FOREIGN KEY (session_id) REFERENCES session(session_id);

ALTER TABLE attendance 
ADD CONSTRAINT fk_attendance_member 
FOREIGN KEY (member_id) REFERENCES member(member_id);

-- Payment foreign keys
ALTER TABLE payment 
ADD CONSTRAINT fk_payment_member 
FOREIGN KEY (member_id) REFERENCES member(member_id);

ALTER TABLE payment 
ADD CONSTRAINT fk_payment_plan 
FOREIGN KEY (plan_id) REFERENCES membership_plan(plan_id);
