CREATE OR REPLACE PROCEDURE submit_request(
    customer_id INTEGER, 
    evaluator_id INTEGER, 
    pickup_addr TEXT, 
    pickup_postal TEXT, 
    recipient_name TEXT, 
    recipient_addr TEXT, 
    recipient_postal TEXT, 
    submission_time TIMESTAMP, 
    package_num INTEGER, 
    reported_height INTEGER[], 
    reported_width INTEGER[], 
    reported_depth INTEGER[], 
    reported_weight INTEGER[], 
    content TEXT[], 
    estimated_value NUMERIC[]
)
AS $$
DECLARE 
    request_id INTEGER;
BEGIN
    -- Insert the new delivery request
    INSERT INTO delivery_requests(
        customer_id, 
        evaluater_id, 
        pickup_addr, 
        pickup_postal, 
        recipient_name, 
        recipient_addr, 
        recipient_postal, 
        submission_time,
        status,
        pickup_date,
	    num_days_needed,
	    price
    ) VALUES (
        customer_id, 
        evaluator_id, 
        pickup_addr, 
        pickup_postal, 
        recipient_name, 
        recipient_addr, 
        recipient_postal, 
        submission_time,
        'submitted',
        NULL,
        NULL,
        NULL
    ) RETURNING id INTO request_id;
    
    -- Insert packages with the new request_id
    FOR i IN 1..package_num LOOP
        INSERT INTO packages(
            request_id,
            package_id,
            reported_height, 
            reported_width, 
            reported_depth, 
            reported_weight, 
            content, 
            estimated_value,
            actual_height,
	        actual_width,
	        actual_depth,
	        actual_weight
        ) VALUES (
            request_id,
            i,
            reported_height[i], 
            reported_width[i], 
            reported_depth[i], 
            reported_weight[i], 
            content[i], 
            estimated_value[i], 
            NULL,
            NULL,
            NULL,
            NULL
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE resubmit_request(
    request_id INTEGER,
    evaluator_id INTEGER,
    submission_time TIMESTAMP,
    reported_height INTEGER[],
    reported_width INTEGER[],
    reported_depth INTEGER[],
    reported_weight INTEGER[]
) AS
$$
DECLARE
    old_customer_id INTEGER;
    old_pickup_addr TEXT;
    old_pickup_postal TEXT; 
    old_recipient_name TEXT; 
    old_recipient_addr TEXT; 
    old_recipient_postal TEXT;
    old_package_num INTEGER;
    old_content TEXT[];
    old_estimated_value NUMERIC[];
BEGIN
    SELECT dr.customer_id, dr.pickup_addr, dr.pickup_postal, dr.recipient_name, dr.recipient_addr, dr.recipient_postal 
        INTO old_customer_id, old_pickup_addr, old_pickup_postal, old_recipient_name, 
                old_recipient_addr, old_recipient_postal
    FROM delivery_requests dr
    WHERE dr.id = request_id;

    SELECT COUNT(*) INTO old_package_num
    FROM packages p
    WHERE p.request_id = $1;

    old_content := ARRAY(
        SELECT p.content
        FROM packages p
        WHERE p.request_id = $1
        ORDER BY p.package_id ASC
    );

    old_estimated_value := ARRAY(
        SELECT p.estimated_value
        FROM packages p
        WHERE p.request_id = $1
        ORDER BY p.package_id ASC
    );

    CALL submit_request(old_customer_id, evaluator_id, old_pickup_addr, old_pickup_postal,
                old_recipient_name, old_recipient_addr, old_recipient_postal, submission_time,
                old_package_num, reported_height, reported_width, reported_depth, reported_weight,
                old_content, old_estimated_value);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_leg(
    request_id INTEGER,
    handler_id INTEGER,
    start_time TIMESTAMP,
    destination_facility INTEGER
) 
AS $$
DECLARE 
	leg_id INTEGER;
BEGIN
	SELECT (COUNT(*) + 1) INTO leg_id
	FROM legs l
	WHERE l.request_id = $1;

	INSERT INTO legs
    VALUES
        (request_id, leg_id, handler_id, start_time, NULL, destination_facility);
END;
$$ LANGUAGE plpgsql;
