-- Inserting sample customers
INSERT INTO customers (name, gender, mobile)
VALUES
    ('Alice', 'female', '5551234'),
    ('John Doe', 'male', '1234567890'),
    ('Jane Doe', 'female', '0987654321');

-- Inserting sample employees
INSERT INTO employees (name, gender, dob, title, salary)
VALUES
    ('David Lee', 'male', '1990-01-01', 'Manager', 5000),
    ('Maggie Chen', 'female', '1995-02-01', 'Assistant Manager', 3000),
    ('Tommy Tan', 'male', '1998-03-01', 'Delivery Staff', 2000);
    
-- Inserting sample delivery staff
INSERT INTO delivery_staff (id)
VALUES
    (1), (2), (3);
    
-- Inserting sample facilities
INSERT INTO facilities (address, postal)
VALUES
    ('1 Facility Road', '123456'),
    ('2 Facility Road', '234567'),
    ('Facility 1, 100 Market St', '10001'),
    ('Facility 2, 200 Market St', '10002');

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR TRIGGER 1: Each delivery request has at least one package.
-- Positive testcase (at least one package for a delivery request):
BEGIN TRANSACTION;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0);
END;

-- Negative testcase (no package for a delivery request)
BEGIN TRANSACTION;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (2, 2, 1, 'submitted', '20 Main Street', '123456', 'Peter Tan', '6 Third Road', '234567', NOW(), '2021-11-01', 2, 80);
END;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR TRIGGER 2: Each delivery request has a valid pickup date.

-- Inserting sample customers
INSERT INTO customers (name, gender, mobile)
VALUES
    ('Alice', 'female', '5551234'),
    ('John Doe', 'male', '1234567890'),
    ('Jane Doe', 'female', '0987654321');

-- Inserting sample employees
INSERT INTO employees (name, gender, dob, title, salary)
VALUES
    ('David Lee', 'male', '1990-01-01', 'Manager', 5000),
    ('Maggie Chen', 'female', '1995-02-01', 'Assistant Manager', 3000),
    ('Tommy Tan', 'male', '1998-03-01', 'Delivery Staff', 2000);
    
-- Inserting sample delivery staff
INSERT INTO delivery_staff (id)
VALUES
    (1), (2), (3);
    
-- Inserting sample facilities
INSERT INTO facilities (address, postal)
VALUES
    ('1 Facility Road', '123456'),
    ('2 Facility Road', '234567'),
    ('Facility 1, 100 Market St', '10001'),
    ('Facility 2, 200 Market St', '10002');

-- Insert sample data into the employees table
INSERT INTO employees (name, gender, dob, title, salary)
VALUES ('Bob', 'male', '1990-01-01', 'Delivery Manager', 60000),
       ('Charlie', 'male', '1992-02-02', 'Assistant Delivery Manager', 50000);

-- TEST FOR TRIGGER 2


-- a g example
BEGIN TRANSACTION;
INSERT INTO delivery_requests (customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100);
    
-- Inserting a package for the above delivery request
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0),
  (1, 2, 20, 10, 30, 13, 'slaves', 5.0);
END;

-- not g
BEGIN TRANSACTION;
INSERT INTO delivery_requests (customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100);
    
-- Inserting a package for the above delivery request
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0),
  (1, 3, 20, 10, 30, 13, 'slaves', 5.0);
END;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR TRIGGER 3
-- Inserting sample customers
INSERT INTO customers (name, gender, mobile)
VALUES
    ('Alice', 'female', '5551234'),
    ('John Doe', 'male', '1234567890'),
    ('Jane Doe', 'female', '0987654321');

-- Inserting sample employees
INSERT INTO employees (name, gender, dob, title, salary)
VALUES
    ('David Lee', 'male', '1990-01-01', 'Manager', 5000),
    ('Maggie Chen', 'female', '1995-02-01', 'Assistant Manager', 3000),
    ('Tommy Tan', 'male', '1998-03-01', 'Delivery Staff', 2000);
    
-- Inserting sample delivery staff
INSERT INTO delivery_staff (id)
VALUES
    (1), (2), (3);
    
-- Inserting sample facilities
INSERT INTO facilities (address, postal)
VALUES
    ('1 Facility Road', '123456'),
    ('2 Facility Road', '234567'),
    ('Facility 1, 100 Market St', '10001'),
    ('Facility 2, 200 Market St', '10002');

-- Insert sample data into the employees table
INSERT INTO employees (name, gender, dob, title, salary)
VALUES ('Bob', 'male', '1990-01-01', 'Delivery Manager', 60000),
       ('Charlie', 'male', '1992-02-02', 'Assistant Delivery Manager', 50000);

-- from testcase 2
BEGIN TRANSACTION;
INSERT INTO delivery_requests (customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100);
    
-- Inserting a package for the above delivery request
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0),
  (1, 2, 20, 10, 30, 13, 'slaves', 5.0);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id)
  VALUES
  (1, '1234567812345678', '2023-04-01 10:05:00', 1);
END;

--G
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason)
  VALUES
  (1, 1, 1, NOW(), 'UR MOM'),
  (1, 2, 1, NOW(), 'ur dad');
END;

-- not g


BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason)
  VALUES
  (1, 2, 1, NOW(), 'UR MOM');
END;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR TRIGGER 4
--SETUP
--Thomas (https://dbfiddle.uk/SN6utk7O)
-- Inserting sample customers
INSERT INTO customers (name, gender, mobile)
VALUES
    ('Alice', 'female', '5551234'),
    ('John Doe', 'male', '1234567890'),
    ('Jane Doe', 'female', '0987654321');

-- Inserting sample employees
INSERT INTO employees (name, gender, dob, title, salary)
VALUES
    ('David Lee', 'male', '1990-01-01', 'Manager', 5000),
    ('Maggie Chen', 'female', '1995-02-01', 'Assistant Manager', 3000),
    ('Tommy Tan', 'male', '1998-03-01', 'Delivery Staff', 2000);
    
-- Inserting sample delivery staff
INSERT INTO delivery_staff (id)
VALUES
    (1), (2), (3);
    
-- Inserting sample facilities
INSERT INTO facilities (address, postal)
VALUES
    ('1 Facility Road', '123456'),
    ('2 Facility Road', '234567'),
    ('Facility 1, 100 Market St', '10001'),
    ('Facility 2, 200 Market St', '10002');

-- Insert sample data into the employees table
INSERT INTO employees (name, gender, dob, title, salary)
VALUES ('Bob', 'male', '1990-01-01', 'Delivery Manager', 60000),
       ('Charlie', 'male', '1992-02-02', 'Assistant Delivery Manager', 50000);

-- TEST FOR TRIGGER 2: Each delivery request has at least one package.


-- a g example
BEGIN TRANSACTION;
INSERT INTO delivery_requests (customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100),
    (2, 2, 'submitted', '9 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-02 10:30:00', '2023-04-02', 3, 100);
    
-- Inserting a package for the above delivery request
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0),
  (1, 2, 20, 10, 30, 13, 'slaves', 5.0),
(2, 1, 10, 20, 30, 15, 'Clothes', 50.0),
  (2, 2, 20, 10, 30, 13, 'slaves', 5.0);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id)
  VALUES
  (1, '1234567812345678', '2023-04-01 10:05:00', 1),
(2, '1234567812345678', '2023-04-01 10:05:00', 1);
END;

--G
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason)
  VALUES
  (1, 1, 1, '2023-04-01 10:30:00', 'UR MOM'),
  (1, 2, 1, '2023-04-01 10:30:01', 'ur dad');
END;

--not g
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason)
  VALUES
  (2, 1, 1, '2023-04-01 10:30:00', 'UR MOM'),
  (2, 2, 1, '2023-04-01 10:29:01', 'ur dad');
END;

-- 2nd not g
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason)
  VALUES
  (2, 1, 1, '2023-04-02 10:30:00', 'UR MOM'),
  (2, 2, 1, '2023-04-02 10:29:01', 'ur dad');
END;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR TRIGGER 1 LEGS RELATED
--SETUP
INSERT INTO customers (name, gender, mobile)
VALUES
    ('Alice', 'female', '5551234'),
    ('John Doe', 'male', '1234567890'),
    ('Jane Doe', 'female', '0987654321');

-- Inserting sample employees
INSERT INTO employees (name, gender, dob, title, salary)
VALUES
    ('David Lee', 'male', '1990-01-01', 'Manager', 5000),
    ('Maggie Chen', 'female', '1995-02-01', 'Assistant Manager', 3000),
    ('Tommy Tan', 'male', '1998-03-01', 'Delivery Staff', 2000);
    
-- Inserting sample delivery staff
INSERT INTO delivery_staff (id)
VALUES
    (1), (2), (3);
    
-- Inserting sample facilities
INSERT INTO facilities (address, postal)
VALUES
    ('1 Facility Road', '123456'),
    ('2 Facility Road', '234567'),
    ('Facility 1, 100 Market St', '10001'),
    ('Facility 2, 200 Market St', '10002');

-- Insert sample data into the employees table
INSERT INTO employees (name, gender, dob, title, salary)
VALUES ('Bob', 'male', '1990-01-01', 'Delivery Manager', 60000),
       ('Charlie', 'male', '1992-02-02', 'Assistant Delivery Manager', 50000);

--good example
BEGIN TRANSACTION;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES (1,1,1,'submitted','10 Main Street','123456','Mary Smith','5 Second Road','234567','2023-04-01','2023-04-02',3,100),
    (2,1,1,'submitted', '9 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-02 10:30:00', '2023-04-02', 3, 100);
END;

--bad example
BEGIN TRANSACTION;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES (1,1,1,'submitted','10 Main Street','123456','Mary Smith','5 Second Road','234567','2023-04-01','2023-04-02',3,100),
    (3,1,1,'submitted', '9 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-02 10:30:00', '2023-04-02', 3, 100);
END;




------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR TRIGGER 2 LEGS RELATED
--SETUP

BEGIN TRANSACTION;
--positive test
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100);

END;



------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FRO TRIGGER 6 CANCELLED REQUESTS RELATED

BEGIN TRANSACTION;
--insert the delivery request
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', NOW(), NOW() + interval '1 day', 3, 100),
    (2, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100);


INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0),
    (2, 1, 10, 20, 30, 15, 'Clothes', 50.0);

END;

INSERT INTO accepted_requests(id, card_number, payment_time, monitor_id)
VALUES 
    (1, '1234567890123456', NOW() + interval '2 hours', 1),
    (2, '1234567890123456', '2023-04-01 10:30:00', 1);

--insert the cancellation request
INSERT INTO cancelled_requests(id, cancel_time)
VALUES
    --positive test case
    (1, NOW() + interval '2 days'); 
END;

INSERT INTO cancelled_requests(id, cancel_time)
VALUES
    --negative test case
    (2, '2023-03-27');
END;


