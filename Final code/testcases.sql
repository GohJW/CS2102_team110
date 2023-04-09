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
-- TEST FOR TRIGGER 6 CANCELLED REQUESTS RELATED
-- dbfiddle: https://dbfiddle.uk/7LpnjFrI

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
    --negative test case before submission
    (2, '2023-03-27');
END;

INSERT INTO cancelled_requests(id, cancel_time)
VALUES
    --negative test case same as submission
    (2, '2023-04-01');
END;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TESTCASE TRIGGER 13
-- SETUP
INSERT INTO customers (id, name, gender, mobile) 
VALUES (1, 'John Doe', 'male', '1234567890');

INSERT INTO employees (id, name, gender, dob, title, salary) 
VALUES (1, 'Jane Smith', 'female', '1990-01-01', 'Manager', 50000);

INSERT INTO delivery_staff (id) 
VALUES (1);

INSERT INTO facilities (id, address, postal) 
VALUES (1, '123 Main St', '12345');

BEGIN TRANSACTION;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) 
VALUES (1, 1, 1, 'submitted', '123 Main St', '12345', 'Janet Smith', '456 Oak St', '67890', '2021-01-01 00:00:00', '2021-01-02', 3, 50.00); 

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value) 
VALUES (1, 1, 10.0, 10.0, 10.0, 10.0, 'books', 20.00);
END;

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) 
VALUES (1, '1234567890123456', '2021-01-02 00:00:00', 1); 

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) 
VALUES (1, 1, 1, '2021-01-03 00:00:00', '2021-01-04 00:00:00', 1);

INSERT INTO cancelled_requests
VALUES (1, '2021-01-04 12:00:00');

INSERT INTO cancelled_or_unsuccessful_requests
VALUES (1);

-- For the positive test case, 
-- we can insert three unsuccessful return deliveries with the same request_id:
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, source_facility, end_time) 
VALUES (1, 1, 1, '2021-01-05 00:00:00', 1, '2021-01-06 00:00:00');

INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) 
VALUES (1, 1, 'Wrong address', '2021-01-05 12:00:00');

INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, source_facility, end_time) 
VALUES (1, 2, 1, '2021-01-07 00:00:00', 1, '2021-01-08 00:00:00');

INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) 
VALUES (1, 2, 'Recipient not available', '2021-01-07 12:00:00');

INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, source_facility, end_time) 
VALUES (1, 3, 1, '2021-01-09 00:00:00', 1, '2021-01-10 00:00:00');

INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) 
VALUES (1, 3, 'Refused delivery', '2021-01-09 12:00:00');

-- For the negative test case, 
-- we can try to insert a fourth unsuccessful return delivery with the same request_id:
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, source_facility, end_time) 
VALUES (1, 4, 1, '2021-01-11 00:00:00', 1, '2021-01-12 00:00:00');

INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) 
VALUES (1, 4, 'Gone bruh', '2021-01-10 12:00:00');
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TESTCASE TRIGGER 14
-- SETUP
BEGIN TRANSACTION;
-- Inserting customers data 
INSERT INTO customers (id, name, gender, mobile) 
VALUES
  (1, 'John', 'male', '98765432'),
  (2, 'Sarah', 'female', '91234567');

-- Inserting employees data 
INSERT INTO employees (id, name, gender, dob, title, salary) 
VALUES 
  (1, 'Bob', 'male', '1980-01-01', 'Manager', 5000),
  (2, 'Alice', 'female', '1990-02-02', 'Clerk', 3000),
  (3, 'Mark', 'male', '1985-03-03', 'Delivery Staff', 2000);

-- Inserting delivery_staff data 
INSERT INTO delivery_staff (id) 
VALUES (3);

-- Inserting facilities data 
INSERT INTO facilities (id, address, postal) 
VALUES 
  (1, '123 Main St', '123456'),
  (2, '456 Broad St', '789012');

-- Inserting delivery_requests data 
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) 
VALUES 
  (1, 1, 2, 'submitted', '1 Orchard Rd', '345678', 'Mary', '2 Broadway', '456789', '2021-01-01 00:00:00', '2021-01-02', 1, 10),
  (2, 2, 2, 'submitted', '3 Maple St', '901234', 'Peter', '4 Elm St', '567890', '2021-02-01 00:00:00', '2021-02-02', 2, 20);

-- Inserting packages data 
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight)
VALUES 
  (1, 1, 10, 10, 10, 5, 'Book', 50, NULL, NULL, NULL, NULL),
  (2, 1, 20, 20, 20, 10, 'Frying Pan', 100, NULL, NULL, NULL, NULL);

-- Inserting accepted_requests data 
INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) 
VALUES 
  (1, '1234567890', '2021-01-01 00:00:00', 3),
  (2, '0987654321', '2021-02-01 00:00:00', 3);

-- Inserting legs data 
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) 
VALUES 
  (1, 1, 3, '2021-01-02 00:00:00', '2021-01-02 12:00:00', 1),
  (2, 1, 3, '2021-02-02 00:00:00', '2021-02-02 12:00:00', 2);

-- Cancel requests
INSERT INTO cancelled_requests
VALUES 
  (1, '2021-01-03 12:00:00'),
  (2, '2021-02-03 12:00:00');

INSERT INTO cancelled_or_unsuccessful_requests
VALUES 
  (1), (2);

END;

-- Positive test case
-- Inserting unsuccessful_return_deliveries data (positive test case)
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, source_facility, end_time) 
VALUES (1, 1, 3, '2021-01-04 00:00:00', 1, '2021-01-05 00:00:00');

INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) 
VALUES (1, 1, 'Wrong address', '2021-01-04 12:00:00');

-- Negative test case (before return leg start)
BEGIN TRANSACTION;
-- Inserting unsuccessful_return_deliveries data (negative test case)
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, source_facility, end_time) 
VALUES (1, 2, 3, '2021-01-06 00:00:00', 1, '2021-01-07 00:00:00');

INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) 
VALUES (1, 2, 'Recipient not available', '2021-01-05 12:00:00');
END;

-- Negative test case (same time as return leg start)
BEGIN TRANSACTION;
-- Inserting unsuccessful_return_deliveries data (negative test case)
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, source_facility, end_time) 
VALUES (2, 1, 3, '2021-02-04 00:00:00', 1, '2021-01-05 00:00:00');

INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) 
VALUES (2, 1, 'Delivery refused', '2021-01-04 00:00:00');
END;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TESTCASE PROCEDURE 1
-- SETUP
BEGIN TRANSACTION;
-- Inserting customers data 
INSERT INTO customers (id, name, gender, mobile) 
VALUES
  (1, 'John', 'male', '98765432'),
  (2, 'Sarah', 'female', '91234567');

-- Inserting employees data 
INSERT INTO employees (id, name, gender, dob, title, salary) 
VALUES 
  (1, 'Bob', 'male', '1980-01-01', 'Manager', 5000),
  (2, 'Alice', 'female', '1990-02-02', 'Clerk', 3000),
  (3, 'Mark', 'male', '1985-03-03', 'Delivery Staff', 2000);

END;

-- Test case 1: Submit a delivery request with a single package 
CALL submit_request(1, 1, '1 Main St', '123456', 'Linda', '2 Broad St', '789012', '2022-01-01 10:00:00', 1, ARRAY[10], ARRAY[5], ARRAY[15], ARRAY[20], ARRAY['Book'], ARRAY[50]);

SELECT * FROM delivery_requests;
SELECT * FROM packages;

-- Test case 2: Submit a delivery request with multiple packages 
CALL submit_request(2, 2, '3 Main St', '345678', 'Mike', '4 Broad St', '901234', '2022-02-02 14:00:00', 2, ARRAY[20, 30], ARRAY[10, 12], ARRAY[8, 10], ARRAY[25, 30], ARRAY['Shoes', 'Clothes'], ARRAY[120, 80]);

SELECT * FROM delivery_requests;
SELECT * FROM packages;

-- Test case 3: Submit a delivery request with no packages (negative testcase)
CALL submit_request(1, 2, '5 Main St', '567890', 'Tom', '6 Broad St', '345678', '2022-03-03 16:00:00', 0, '{}', '{}', '{}', '{}', '{}', '{}');

SELECT * FROM delivery_requests;
SELECT * FROM packages;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TESTCASE PROCEDURE 2
-- SETUP
BEGIN TRANSACTION;
-- Inserting customers data 
INSERT INTO customers (id, name, gender, mobile) 
VALUES
  (1, 'John', 'male', '98765432'),
  (2, 'Sarah', 'female', '91234567');

-- Inserting employees data 
INSERT INTO employees (id, name, gender, dob, title, salary) 
VALUES 
  (1, 'Bob', 'male', '1980-01-01', 'Manager', 5000),
  (2, 'Alice', 'female', '1990-02-02', 'Clerk', 3000),
  (3, 'Mark', 'male', '1985-03-03', 'Delivery Staff', 2000);

-- Inserting delivery_staff data 
INSERT INTO delivery_staff (id) 
VALUES (3);

-- Inserting facilities data 
INSERT INTO facilities (id, address, postal) 
VALUES 
  (1, '123 Main St', '123456'),
  (2, '456 Broad St', '789012');

-- Inserting delivery requests and packages
CALL submit_request(1, 1, '1 Main St', '123456', 'Linda', '2 Broad St', '789012', '2021-01-01 10:00:00', 1, ARRAY[10], ARRAY[5], ARRAY[15], ARRAY[20], ARRAY['Book'], ARRAY[50]);

CALL submit_request(2, 2, '3 Main St', '345678', 'Mike', '4 Broad St', '901234', '2021-02-01 14:00:00', 2, ARRAY[20, 30], ARRAY[10, 12], ARRAY[8, 10], ARRAY[25, 30], ARRAY['Shoes', 'Clothes'], ARRAY[120, 80]);
END;

-- Resubmitted delivery request details
CALL resubmit_request(2, 1, '2021-02-03 00:00:00', ARRAY[69,69], ARRAY[69,69], ARRAY[420,420], ARRAY[420,420]);

-- Verify the new delivery request details
SELECT * FROM delivery_requests;

-- Verify the new package details
SELECT * FROM packages;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TESTCASE PROCEDURE 3
-- SETUP
BEGIN TRANSACTION;
-- Inserting customers data 
INSERT INTO customers (id, name, gender, mobile) 
VALUES
  (1, 'John', 'male', '98765432'),
  (2, 'Sarah', 'female', '91234567');

-- Inserting employees data 
INSERT INTO employees (id, name, gender, dob, title, salary) 
VALUES 
  (1, 'Bob', 'male', '1980-01-01', 'Manager', 5000),
  (2, 'Alice', 'female', '1990-02-02', 'Clerk', 3000),
  (3, 'Mark', 'male', '1985-03-03', 'Delivery Staff', 2000);

-- Inserting delivery_staff data 
INSERT INTO delivery_staff (id) 
VALUES (3);

-- Inserting facilities data 
INSERT INTO facilities (id, address, postal) 
VALUES 
  (1, '123 Main St', '123456'),
  (2, '456 Broad St', '789012');

-- Inserting delivery requests and packages
CALL submit_request(1, 1, '1 Main St', '123456', 'Linda', '2 Broad St', '789012', '2021-01-01 10:00:00', 1, ARRAY[10], ARRAY[5], ARRAY[15], ARRAY[20], ARRAY['Book'], ARRAY[50]);

CALL submit_request(2, 2, '3 Main St', '345678', 'Mike', '4 Broad St', '901234', '2021-02-01 14:00:00', 2, ARRAY[20, 30], ARRAY[10, 12], ARRAY[8, 10], ARRAY[25, 30], ARRAY['Shoes', 'Clothes'], ARRAY[120, 80]);

-- Inserting accepted_requests data 
INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) 
VALUES 
  (1, '1234567890', '2021-01-02 00:00:00', 3),
  (2, '0987654321', '2021-02-02 00:00:00', 3);

END;

-- Positive testcases
CALL insert_leg(1, 3, '2021-01-02 12:00:00', 1);
CALL insert_leg(2, 3, '2021-02-02 12:00:00', 2);

-- Verify the new delivery request details
SELECT * FROM delivery_requests;

-- Verify the new package details
SELECT * FROM packages;

-- Verify the new leg details
SELECT * FROM legs;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR TRIGGER 7 RETURN LEGS RELATED
--dbfiddle: https://dbfiddle.uk/63-9Ql4O

BEGIN TRANSACTION;
--insert the delivery requests
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', NOW(), NOW() + interval '1 day', 3, 100),
    (2, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100);

--insert the packages
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0),
    (2, 1, 10, 20, 30, 15, 'Clothes', 50.0);

END;
--accept the request
INSERT INTO accepted_requests(id, card_number, payment_time, monitor_id)
VALUES 
    (1, '1234567890123456', NOW() + interval '2 hours', 1),
    (2, '1234567890123456', '2023-04-01 10:30:00', 1);

INSERT INTO cancelled_requests(id, cancel_time) --one request is cancelled
VALUES
    (1, NOW() + interval '3 hours');

INSERT INTO cancelled_or_unsuccessful_requests(id) 
-- (1) is cancelled (2) is unsuccessful (return_legs request_id references cancelled_or_unsuccessful_requests table)
VALUES
    (1),(2);

INSERT INTO legs(request_id, leg_id, handler_id, start_time, end_time, destination_facility)
VALUES
-- needs to have a start leg first (related to trigger 8)
    (1, 1, 1, NOW() + interval '1 hour', NOW() + interval '2 hours', 1),
    (2, 1, 1, '2023-03-01 10:31:00', '2023-03-01 10:31:00', 1);



INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES  
    --positive test case
    (1, 1, 1, NOW() + interval '4 hours', 1, NOW() + interval '5 hours'),
    (1, 2, 1, NOW() + interval '6 hours', 1, NOW() + interval '7 hours'),
    (2, 1, 1, '2023-04-01 10:31:00', 1 , '2023-04-01 10:32:00'),
    (2, 2, 1, '2023-04-02 10:31:00', 1 , '2023-04-02 10:32:00');
END;

--negative test cases
INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES  --for cancelled request
    (1, 1, 1, NOW() + interval '4 hours', 1, NOW() + interval '5 hours'),
    (1, 3, 1, NOW() + interval '6 hours', 1, NOW() + interval '7 hours');
END;

INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES  --for unsuccessful request
    (2, 1, 1, '2023-04-01 10:31:00', 1 , '2023-04-01 10:32:00'),
    (2, 4, 1, '2023-04-02 10:31:00', 1 , '2023-04-02 10:32:00');
END;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR TRIGGER 8 RETURN LEGS RELATED
-- dbfiddle: https://dbfiddle.uk/ShknBmVX

BEGIN TRANSACTION;
--insert the delivery requests
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-02-01 10:31:00', '2023-03-01 10:31:00', 3, 100),
    (2, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-04-01', '2023-04-02', 3, 100),
    (3, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', '2023-03-01 12:30:00', '2023-03-01 12:30:00', 3, 100);


--insert the packages
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0),
    (2, 1, 10, 20, 30, 15, 'Clothes', 50.0),
    (3, 1, 10, 20, 30, 15, 'Clothes', 50.0);

END;
--accept the request
INSERT INTO accepted_requests(id, card_number, payment_time, monitor_id)
VALUES 
    (1, '1234567890123456', '2023-03-01 11:30:00', 1),
    (2, '1234567890123456', '2023-04-01 10:30:00', 1),
    (3, '1234567890123456', '2023-03-01 12:31:00', 1);


INSERT INTO cancelled_requests(id, cancel_time) --one request is cancelled
VALUES
    (1, '2023-03-01 11:25:00'),
    (3, '2023-03-01 16:30:00');

INSERT INTO cancelled_or_unsuccessful_requests(id) 
-- (1) is cancelled (2) is unsuccessful (return_legs request_id references cancelled_or_unsuccessful_requests table)
VALUES
    (1),(2),(3);

INSERT INTO legs(request_id, leg_id, handler_id, start_time, end_time, destination_facility)
VALUES
-- first delivery request has a first leg, the second does not
    (1, 1, 1, '2023-03-01 11:31:00', '2023-03-01 11:32:00', 1),
    (3, 1, 1, '2023-03-01 12:32:00', '2023-03-01 12:33:00', 1);    
END;
 
 
INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES
    -- test for (i), no existing first leg should not pass
    (2, 1, 1, '2023-03-01 10:31:00', 1, '2023-03-01 10:31:00');
END;

INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES
    --test for (ii), return leg start time before end time of last leg
    (1, 1, 1, '2023-03-01 10:30:00', 1, '2023-03-01 11:30:00');
END;

INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES
    --test for (ii), return leg start time same as end time of last leg
    (1, 1, 1, '2023-03-01 11:32:00', 1, '2023-03-01 11:33:00');
END;

INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES
    --test for return leg start time before cancel request
    (3, 1, 1, '2023-03-01 12:34:00', 1, '2023-03-01 12:35:00');
END;

INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES
    --test for return leg start time same as cancel request
    (3, 1, 1, '2023-03-01 16:30:00', 1, '2023-03-01 16:31:00');
END;

INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES
    --positive test case
    (3, 1, 1, '2023-03-01 16:31:00', 1, '2023-03-01 16:32:00');
END;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST FOR FUNCTION 3
-- dbfiddle: https://dbfiddle.uk/r5_Cvy3O

BEGIN TRANSACTION;
--insert the delivery requests
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
VALUES
    (1, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', NOW(), NOW() + interval '1 hour', 3, 100),
    (2, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', NOW(), NOW() + interval '1 hour', 3, 100),
    (3, 1, 1, 'submitted', '10 Main Street', '123456', 'Mary Smith', '5 Second Road', '234567', NOW(), NOW() + interval '1 hour', 3, 100);



--insert the packages
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
VALUES
    (1, 1, 10, 20, 30, 15, 'Clothes', 50.0),
    (2, 1, 10, 20, 30, 15, 'Clothes', 50.0),
    (3, 1, 10, 20, 30, 15, 'Clothes', 50.0);


END;
--accept the request
INSERT INTO accepted_requests(id, card_number, payment_time, monitor_id)
VALUES 
    (1, '1234567890123456', NOW() + interval '2 hours', 1),
    (2, '1234567890123456', NOW() + interval '2 hours', 1),
    (3, '1234567890123456', NOW() + interval '2 hours', 1);


INSERT INTO cancelled_requests(id, cancel_time) --one request is cancelled
VALUES
    (2, NOW() + interval '5 hours');

INSERT INTO cancelled_or_unsuccessful_requests(id) 
VALUES -- (2) is cancelled to test for return legs
    (2);

INSERT INTO legs(request_id, leg_id, handler_id, start_time, end_time, destination_facility)
VALUES
    (1, 1, 1, NOW() + interval '2 hours 15 minutes', NOW() + interval '3 hours', 1), -- NULL, 1
    (1, 2, 1, NOW() + interval '3 hours 15 minutes', NOW() + interval '4 hours', 2), -- 1,2
    (1, 3, 1, NOW() + interval '4 hours 15 minutes', NOW() + interval '5 hours', 3), -- 2,3
    (1, 4, 1, NOW() + interval '5 hours 15 minutes', NOW() + interval '6 hours', NULL), -- 3, NULL
    (1, 5, 1, NOW() + interval '6 hours 15 minutes', NOW() + interval '7 hours', NULL), -- 3, NULL
    (2, 1, 1, NOW() + interval '2 hours 15 minutes', NOW() + interval '3 hours', 1),  -- NULL, 1
    (2, 2, 1, NOW() + interval '3 hours 15 minutes', NOW() + interval '4 hours', 2), -- 1, 2
    (2, 3, 1, NOW() + interval '4 hours 15 minutes', NOW() + interval '5 hours', 3), -- 2, 3
    (3, 1, 1, NOW() + interval '2 hours 15 minutes', NOW() + interval '3 hours', 1), -- NULL, 1
    (3, 2, 1, NOW() + interval '3 hours 15 minutes', NOW() + interval '4 hours', 2); -- 1, 2

INSERT INTO return_legs(request_id, leg_id, handler_id, start_time, source_facility, end_time)
VALUES
    (2, 1, 1, NOW() + interval '6 hours', 3, NOW() + interval '7 hours'), -- 3, 2
    (2, 2, 1, NOW() + interval '6 hours', 2, NOW() + interval '7 hours'), -- 2, 1
    (2, 3, 1, NOW() + interval '6 hours', 1, NOW() + interval '7 hours'), -- 1, 1
    (2, 4, 1, NOW() + interval '7 hours', 1, NOW() + interval '8 hours'), -- 1, 1
    (2, 5, 1, NOW() + interval '8 hours', 1, NOW() + interval '9 hours'); -- 1, NULL assuming successfull

INSERT INTO unsuccessful_return_deliveries(request_id, leg_id, reason, attempt_time)
VALUES
    (2, 3, 'who knows', NOW() + interval '6 hours 30 minutes'),
    (2, 4, 'who knows', NOW() + interval '7 hours 30 minutes');
    --Assuming the last return leg does not fail


SELECT * FROM get_top_connections(5);

INSERT INTO unsuccessful_return_deliveries(request_id, leg_id, reason, attempt_time)
VALUES
-- If last leg fails the order will change since the connection (1, NULL) becomes (1, 1)
    (2, 5, 'who knows', NOW() + interval '8 hours 30 minutes'); 

SELECT * FROM get_top_connections(5);
END;
