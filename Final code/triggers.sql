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
    WHERE request_id = NEW.request_id AND exist = NEW.leg_id; --exist = NEW.leg_id selects the latest leg
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
