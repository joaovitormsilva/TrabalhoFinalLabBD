CREATE OR REPLACE FUNCTION relatorio_pontos_por_ano(p_id INT)
RETURNS TABLE (
    ano INT,
    corrida TEXT,
    pontos INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.year,
        ra.name,
        r.points
    FROM results r
    JOIN races ra ON ra.raceid = r.raceid
    JOIN seasons s ON s.year = ra.year
    WHERE r.driverid = p_id
      AND r.points > 0
    ORDER BY s.year, ra.name;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION relatorio_status_resultados(p_id INT)
RETURNS TABLE (
    status TEXT,
    quantidade BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.status,
        COUNT(*) AS quantidade
    FROM results r
    JOIN status s ON s.statusid = r.statusid
    WHERE r.driverid = p_id
    GROUP BY s.status
    ORDER BY quantidade DESC;
END;
$$ LANGUAGE plpgsql;
