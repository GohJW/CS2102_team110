/** Triggers **/
/* 1 */
CREATE OR REPLACE FUNCTION check_package_exists()
RETURNS TRIGGER AS $$
DECLARE
    package_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO package_count FROM packages WHERE request_id = NEW.id;
    IF package_count = 0 THEN
        RAISE EXCEPTION 'A delivery request must have at least one package associated.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER ensure_package_exists
AFTER INSERT ON delivery_requests
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION check_package_exists();

/* 2 */
CREATE OR REPLACE FUNCTION check_consecutive_package_id() RETURNS TRIGGER AS $$
DECLARE
    max_package_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(package_id), 0) INTO max_package_id FROM packages WHERE request_id = NEW.request_id;
    IF max_package_id + 1 <> NEW.package_id  THEN
        RAISE EXCEPTION 'New package_id is not consecutive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_consecutive_package_id
BEFORE INSERT ON packages
FOR EACH ROW
EXECUTE FUNCTION check_consecutive_package_id();

/* 3  check if we should forcefully change the id or dun allow insertion*/
CREATE OR REPLACE FUNCTION check_consecutive_pickup_id() RETURNS TRIGGER AS $$
DECLARE
    max_pickup_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(pickup_id), 0) INTO max_pickup_id FROM unsuccessful_pickups WHERE request_id = NEW.request_id;
    IF max_pickup_id + 1 <> NEW.pickup_id  THEN
        RAISE EXCEPTION 'New unsuccessful pickup_id for request is not consecutive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_consecutive_pickup_id
BEFORE INSERT ON unsuccessful_pickups
FOR EACH ROW
EXECUTE FUNCTION check_consecutive_pickup_id();

/* 4 */
CREATE OR REPLACE FUNCTION check_unsuccessful_pickup_timestamp() RETURNS TRIGGER AS $$
DECLARE
    submission_time TIMESTAMP;
    previous_unsuccessful_pickup_time TIMESTAMP;
BEGIN
    -- If first unsuccessful pickup
    IF NOT EXISTS (SELECT 1 FROM unsuccessful_pickups WHERE request_id = NEW.request_id) THEN
        -- Get submission time
        SELECT d.submission_time INTO submission_time
        FROM delivery_requests d
        WHERE d.id = NEW.request_id;

        -- Check if the NEW unsuccessful pickup's timestamp is after the delivery request's submission time
        IF NEW.pickup_time <= submission_time THEN
            RAISE EXCEPTION 'The first unsuccessful pickup timestamp should be after the submission time of the delivery request.';
        END IF;
    END IF;

    -- Get previous unsuccessful pickup's timestamp
    SELECT MAX(pickup_time) INTO previous_unsuccessful_pickup_time
    FROM unsuccessful_pickups
    WHERE request_id = NEW.request_id;

    -- Check if the NEW unsuccessful pickup's timestamp is after the previous unsuccessful pickup's timestamp
    IF NEW.pickup_time <= previous_unsuccessful_pickup_time THEN
        RAISE EXCEPTION 'Subsequent unsuccessful pickup timestamp should be after the previous unsuccessful pickup timestamp.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_unsuccessful_pickup_timestamp
BEFORE INSERT ON unsuccessful_pickups
FOR EACH ROW
EXECUTE FUNCTION check_unsuccessful_pickup_timestamp();

/* Legs related check same as other consecutive id question*/
/* 1 */
CREATE OR REPLACE FUNCTION check_consecutive_leg_id() RETURNS TRIGGER AS $$
DECLARE
    max_leg_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(leg_id), 0) INTO max_leg_id FROM legs WHERE request_id = NEW.request_id;
    IF max_leg_id + 1 <> NEW.leg_id  THEN
        RAISE EXCEPTION 'New leg_id is not consecutive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_consecutive_leg_id
BEFORE INSERT ON legs
FOR EACH ROW
EXECUTE FUNCTION check_consecutive_leg_id();

/* 2 */
CREATE OR REPLACE FUNCTION enforce_first_leg_start_time_func() RETURNS TRIGGER AS $$
DECLARE 
    count INTEGER;
    submission_time TIMESTAMP;
    last_unsuccessful_pickup_time TIMESTAMP;
BEGIN
	SELECT COUNT(*) INTO count 
	FROM legs 
	WHERE request_id = NEW.request_id;

	SELECT dr.submission_time INTO submission_time
	FROM delivery_requests dr
	WHERE dr.id = NEW.request_id;

	SELECT pickup_time INTO last_unsuccessful_pickup_time
	FROM unsuccessful_pickups
	WHERE request_id = NEW.request_id
	ORDER BY pickup_id DESC
	LIMIT 1;

	IF (count = 0) THEN 
		IF (NEW.start_time <= submission_time) THEN
			RAISE EXCEPTION 'Start time of the first leg should be after the submission_time of the its delivery request';
		ELSIF (last_unsuccessful_pickup_time IS NOT NULL AND NEW.start_time <= last_unsuccessful_pickup_time) THEN
			RAISE EXCEPTION 'Start time of the first leg should be after the timestamp of the last unsuccessful pickup';
		END IF;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_first_leg_start_time_trigger
BEFORE INSERT ON legs
FOR EACH ROW EXECUTE FUNCTION enforce_first_leg_start_time_func();

/* 3 */
CREATE OR REPLACE FUNCTION enforce_leg_time_func() RETURNS trigger AS $$
DECLARE count NUMERIC;
DECLARE previous_end_time TIMESTAMP;
BEGIN
	SELECT COUNT(*) INTO count
	FROM legs
	WHERE request_id = NEW.request_id;

	IF (COUNT > 0) THEN
		SELECT end_time INTO previous_end_time
		FROM legs
		WHERE request_id = NEW.request_id
		AND leg_id = count
		LIMIT 1;

		IF (previous_end_time IS NULL OR NEW.start_time < previous_end_time) THEN
			RAISE EXCEPTION 'New leg cannot be inserted if its start_time is before the end_time of the previous leg';
		END IF;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_leg_time_trigger
BEFORE INSERT ON legs
FOR EACH ROW EXECUTE FUNCTION enforce_leg_time_func();


/*4 Check */

CREATE OR REPLACE FUNCTION unsuccessful_deliveries_timestamp_after_func() RETURNS TRIGGER AS $$
DECLARE
    start TIMESTAMP;
BEGIN
    SELECT start_time INTO start
    FROM legs
    WHERE request_id = NEW.request_id AND leg_id = NEW.leg_id;
    IF (start >= NEW.attempt_time) THEN
        RAISE EXCEPTION 'Attempt time should be before leg start time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unsuccessful_deliveries_timestamp_after_trigger
BEFORE INSERT ON unsuccessful_deliveries
FOR EACH ROW EXECUTE FUNCTION unsuccessful_deliveries_timestamp_after_func();

/* 5 */
CREATE OR REPLACE FUNCTION check_three_unsuccessful_deliveries()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM unsuccessful_deliveries WHERE request_id = NEW.request_id) = 3 THEN
        RAISE EXCEPTION 'For each delivery request, there can be at most three unsuccessful_deliveries.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_three_unsuccessful_deliveries
BEFORE INSERT ON legs
FOR EACH ROW
EXECUTE FUNCTION check_three_unsuccessful_deliveries();

/* 6 */
CREATE OR REPLACE FUNCTION cancelled_request_after_submission_func() RETURNS TRIGGER AS $$
DECLARE
    delivery_request_submission_time TIMESTAMP;
BEGIN
    SELECT submission_time into delivery_request_submission_time
    FROM delivery_requests
    WHERE id = NEW.id;
    IF(delivery_request_submission_time >= NEW.cancel_time) THEN
        RAISE EXCEPTION 'Cancel time of a cancelled request should be after the submission_time of the corresponding delivery request';
    END IF;
    RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER cancelled_request_after_submission_trigger
BEFORE INSERT ON cancelled_requests
FOR EACH ROW EXECUTE FUNCTION cancelled_request_after_submission_func();


/* 7 */
CREATE OR REPLACE FUNCTION check_consecutive_return_leg_id() 
RETURNS TRIGGER AS $$
DECLARE
    max_return_leg_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(leg_id), 0) INTO max_return_leg_id FROM return_legs WHERE request_id = NEW.request_id;
    IF max_return_leg_id + 1 <> NEW.leg_id  THEN
        RAISE EXCEPTION 'New return leg_id is not consecutive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_consecutive_return_leg_id
BEFORE INSERT ON return_legs
FOR EACH ROW
EXECUTE FUNCTION check_consecutive_return_leg_id();

/* 8 */
CREATE OR REPLACE FUNCTION first_return_leg_not_exist_or_after_func() RETURNS TRIGGER AS $$
DECLARE
    existing_leg_count NUMERIC; --(i)The number of legs/leg_id of the last leg
    last_leg_end_time TIMESTAMP; --(ii) Last leg end time
    delivery_request_cancellation_time TIMESTAMP; --(ii) Canclled time of request (if any)
BEGIN
    SELECT COUNT(*) INTO existing_leg_count
    FROM legs
    WHERE request_id = NEW.request_id;
    IF(existing_leg_count = 0) THEN
        RAISE EXCEPTION 'Delivery request has no existing legs';
    END IF;
    SELECT end_time INTO last_leg_end_time
    FROM legs
    WHERE request_id = NEW.request_id AND  existing_leg_count = NEW.leg_id; -- existing_leg_count = NEW.leg_id selects the latest leg
    IF(last_leg_end_time >= NEW.start_time) THEN
        RAISE EXCEPTION 'Return leg start time is before last leg end time';
    END IF;
    SELECT cancel_time INTO delivery_request_cancellation_time --May be null if no cancel request is made
    FROM cancelled_requests
    WHERE id = NEW.request_id;
    IF(delivery_request_cancellation_time >= NEW.start_time) THEN
        RAISE EXCEPTION 'Return leg start time is before cancelled time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER first_return_leg_not_exist_or_after_trigger
BEFORE INSERT ON return_legs
FOR EACH ROW EXECUTE FUNCTION first_return_leg_not_exist_or_after_func();

/* 9 */
CREATE OR REPLACE FUNCTION check_three_unsuccessful_return_deliveries()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM unsuccessful_return_deliveries WHERE request_id = NEW.request_id) = 3 THEN
        RAISE EXCEPTION 'For each delivery request, there can be at most three unsuccessful_return_deliveries.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_three_unsuccessful_return_deliveries
BEFORE INSERT ON return_legs
FOR EACH ROW
EXECUTE FUNCTION check_three_unsuccessful_return_deliveries();

/* 10 */
CREATE OR REPLACE FUNCTION unsuccessful_return_deliveries_after_func() RETURNS TRIGGER AS $$
DECLARE
    start TIMESTAMP;
BEGIN
    SELECT start_time INTO start
    FROM return_legs
    WHERE request_id = NEW.request_id AND leg_id = NEW.leg_id;
    IF(start >= NEW.attempt_time) THEN
        RAISE EXCEPTION 'Attempt time is before return leg start time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unsuccessful_return_deliveries_after_trigger
BEFORE INSERT ON unsuccessful_return_deliveries
FOR EACH ROW EXECUTE FUNCTION unsuccessful_return_deliveries_after_func();

/** Procedures **/
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

/** Functions **/
-- Function 1
CREATE OR REPLACE FUNCTION view_trajectory(request_id INTEGER)
RETURNS TABLE(source_addr TEXT, destination_addr TEXT, start_time TIMESTAMP, end_time TIMESTAMP) AS $$
DECLARE
    last_return_leg_id INTEGER;
    last_leg_id INTEGER;
BEGIN
    -- return nothing if no legs at all
    --IF (SELECT COUNT(*) FROM legs l0 WHERE l0.request_id = $1) = 0 THEN
      --  RETURN NULL;
    -- END IF

    -- ADD the legs
    RETURN QUERY (
        SELECT t.source_addr,
               t.destination_addr,
               t.start_time,
               t.end_time
        FROM (
            -- Get info for first leg
            SELECT dr.pickup_addr AS source_addr,
                   f.address AS destination_addr,
                   l.start_time AS start_time,
                   l.end_time AS end_time
            FROM legs l JOIN delivery_requests dr ON l.request_id = dr.id
                JOIN facilities f ON l.destination_facility = f.id
            WHERE l.request_id = $1 AND l.leg_id = 1
            UNION
            -- Get correct info for intermediate and last legs (excludes first leg)
            -- Only contains last leg if not delivered (since dest fac is NULL if delivered)
            SELECT f1.address AS source_addr,
                f2.address AS destination_addr,
                l2.start_time AS start_time,
                l2.end_time AS end_time
            FROM (legs l1 JOIN facilities f1 ON l1.destination_facility = f1.id)
                JOIN (legs l2 JOIN facilities f2 ON l2.destination_facility = f2.id)
                ON l1.leg_id = l2.leg_id - 1
                    AND l1.request_id = $1 
                    AND l2.request_id = $1
            UNION
            -- Get info for the last leg if delivered
            SELECT fll1.address AS source_addr,
                drl.recipient_addr AS destination_addr,
                ll2.start_time AS start_time,
                ll2.end_time AS end_time
            FROM (legs ll1 JOIN facilities fll1 ON ll1.destination_facility = fll1.id)
                JOIN (legs ll2 JOIN delivery_requests drl ON ll2.request_id = drl.id)
                ON ll1.leg_id = ll2.leg_id - 1
                    AND ll1.request_id = $1
                    AND ll2.request_id = $1
                    AND ll2.destination_facility IS NULL
            UNION
            -- Add the return legs
            -- Get info for first and intermediate return legs (excludes last return leg)
            SELECT f1.address AS source_addr,
                f2.address AS destination_addr,
                rl1.start_time AS start_time,
                rl1.end_time AS end_time
            FROM (return_legs rl1 JOIN facilities f1 ON rl1.source_facility = f1.id)
                JOIN (return_legs rl2 JOIN facilities f2 ON rl2.source_facility = f2.id)
                ON rl1.leg_id = rl2.leg_id - 1
                    AND rl1.request_id = $1
                    AND rl2.request_id = $1
        ) AS t
        ORDER BY start_time ASC
    );

    -- Get the last return leg id
    SELECT COUNT(*) INTO last_return_leg_id
    FROM return_legs rll
    WHERE rll.request_id = $1;

    IF EXISTS (SELECT 1 FROM unsuccessful_return_deliveries urd WHERE urd.request_id = $1 AND urd.leg_id = last_return_leg_id) THEN
        RETURN QUERY(
            -- didnt go back home aka not successful
            SELECT f.address AS source_addr,
                   f.address AS destination_addr,
                   rl.start_time AS start_time,
                   rl.end_time AS end_time
            FROM return_legs rl JOIN facilities f ON rl.source_facility = f.id
            WHERE rl.request_id = $1 
                    AND rl.leg_id = last_return_leg_id);
    ELSE 
        RETURN QUERY( 
            -- Went back home
            SELECT f.address AS source_addr,
                   dr.pickup_addr AS destination_addr,
                   rl.start_time AS start_time,
                   rl.end_time AS end_time
            FROM return_legs rl JOIN delivery_requests dr ON rl.request_id = dr.id
                JOIN facilities f ON rl.source_facility = f.id
            WHERE rl.request_id = $1 
                    AND rl.leg_id = last_return_leg_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

/* 2 */
CREATE OR REPLACE FUNCTION get_top_delivery_persons (k INTEGER)
RETURNS TABLE (employee_id INTEGER) AS $$
BEGIN
    RETURN QUERY (
        SELECT a.handler_id employee_id
        FROM (
            SELECT handler_id
            FROM unsuccessful_pickups
            UNION ALL
            SELECT handler_id
            FROM legs
            UNION ALL
            SELECT handler_id
            FROM return_legs
        ) a
        GROUP BY a.handler_id
        ORDER BY COUNT(*) DESC, employee_id ASC
        LIMIT $1
    );
END;
$$ LANGUAGE plpgsql;

/* 3 */
CREATE OR REPLACE FUNCTION get_top_connections(k  INTEGER)
RETURNS TABLE(source_facility_id INTEGER, destination_facility_id INTEGER) AS $$
BEGIN
    RETURN QUERY (
        SELECT c.source source_facility_id, c.dest destination_facility_id
        FROM (
            -- Get info for intermediate legs
            SELECT l1.destination_facility AS source,
                l2.destination_facility AS dest
            FROM legs l1 JOIN legs l2
                ON l1.leg_id = l2.leg_id - 1
                    AND l1.request_id = l2.request_id
                    AND l2.destination_facility IS NOT NULL
            UNION ALL
            -- Get info for intermediate return legs
            SELECT rl1.source_facility AS source,
                rl2.source_facility AS dest
            FROM return_legs rl1 JOIN return_legs rl2 
                ON rl1.leg_id = rl2.leg_id - 1
                    AND rl1.request_id = rl2.request_id
        ) c
        GROUP BY c.source, c.dest
        ORDER BY COUNT(*) DESC, (source, dest) ASC
        LIMIT $1
    );
END;
$$ LANGUAGE plpgsql;