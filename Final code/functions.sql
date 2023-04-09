/* 1 */
CREATE OR REPLACE FUNCTION view_trajectory(request_id INTEGER)
RETURNS TABLE(source_addr TEXT, destination_addr TEXT, start_time TIMESTAMP, end_time TIMESTAMP) AS $$
DECLARE
    last_return_leg_id INTEGER;
BEGIN
    -- return nothing if no legs at all
    IF (SELECT COUNT(*) FROM legs WHERE request_id = $1) = 0 THEN
        RETURN NULL
    END IF

    -- ADD the legs
    RETURN QUERY (
        SELECT source_addr,
               destination_addr,
               start_time,
               end_time
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
            -- Add the return legs
            -- Get info for first and intermediate return legs (excludes last return leg)
            SELECT f1.address AS source_addr,
                f2.address AS destination_addr,
                rl1.start_time AS start_time,
                rl1.end_time AS end_time
            FROM (return_legs rl1 JOIN facilities f1 ON rl1.destination_facility = f1.id)
                JOIN (return_legs rl2 JOIN facilities f2 ON rl2.destination_facility = f2.id)
                ON rl1.leg_id = rl2.leg_id - 1
                    AND rl1.request_id = $1
                    AND rl2.request_id = $1
        )
        ORDER BY start_time ASC
    );

    -- Get the last return leg id
    SELECT COUNT(*) INTO last_return_leg_id
    FROM return_legs
    WHERE request_id = $1

    IF EXISTS (SELECT 1 FROM unsuccessful_return_deliveries WHERE request_id = $1 AND leg_id = last_return_leg_id) THEN
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
                   dr.recipient_addr AS destination_addr,
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
            UNION ALL
            -- Get the last return_leg if it is not successful
            SELECT rl3.source_facility AS source,
                rl3.source_facility AS dest
            FROM return_legs rl3
            WHERE rl3.leg_id = (SELECT COUNT(*) FROM return_legs WHERE request_id = rl3.request_id)
            AND EXISTS(SELECT 1 FROM unsuccessful_return_deliveries WHERE request_id = rl3.request_id AND leg_id = rl3.leg_id)
        ) c
        GROUP BY c.source, c.dest
        ORDER BY COUNT(*) DESC, (source, dest) ASC
        LIMIT $1
    );
END;
$$ LANGUAGE plpgsql;