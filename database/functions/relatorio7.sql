CREATE OR REPLACE FUNCTION get_pilot_results_by_status()
RETURNS TABLE (
    status_nome VARCHAR,
    quantidade BIGINT
)
AS $$
DECLARE
    piloto_id INT := get_logged_in_pilot_id();
BEGIN
    RETURN QUERY
    SELECT
        s.status AS status_nome,
        COUNT(*) AS quantidade
    FROM
        results res
    JOIN
        status s ON res.statusid = s.statusid
    WHERE
        res.driverid = piloto_id
    GROUP BY
        s.status
    ORDER BY
        quantidade DESC;
END;
$$ LANGUAGE plpgsql;

CREATE INDEX idx_results_driverid_statusid ON results (driverid, statusid);
CREATE INDEX idx_status_statusid_status ON status (statusid, status);