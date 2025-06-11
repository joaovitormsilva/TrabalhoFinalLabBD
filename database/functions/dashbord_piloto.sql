CREATE OR REPLACE FUNCTION get_pilot_dashboard_info()
RETURNS TABLE (
    escuderia_nome VARCHAR,
    piloto_nome_completo VARCHAR,
    primeiro_ano_dados INT,
    ultimo_ano_dados INT,
    ano_competicao INT,
    circuito_nome VARCHAR,
    pontos_obtidos NUMERIC,
    vitorias_obtidas BIGINT,
    corridas_participadas BIGINT
)
AS $$
DECLARE
    piloto_id INT := get_logged_in_pilot_id();
BEGIN
    SELECT
        c.name,
        d.forename || ' ' || d.surname
    INTO
        escuderia_nome, piloto_nome_completo
    FROM
        drivers d
    JOIN
        results res ON d.driverid = res.driverid
    JOIN
        races r ON res.raceid = r.raceid
    JOIN
        constructors c ON res.constructorid = c.constructorid
    WHERE
        d.driverid = piloto_id
    LIMIT 1;

    SELECT
        MIN(r.year), MAX(r.year)
    INTO
        primeiro_ano_dados, ultimo_ano_dados
    FROM
        results res
    JOIN
        races r ON res.raceid = r.raceid
    WHERE
        res.driverid = piloto_id;

    RETURN QUERY
    SELECT
        escuderia_nome,
        piloto_nome_completo,
        primeiro_ano_dados,
        ultimo_ano_dados,
        r.year AS ano_competicao,
        circ.name AS circuito_nome,
        SUM(res.points) AS pontos_obtidos, [cite: 65]
        COUNT(CASE WHEN res.position = 1 THEN 1 END) AS vitorias_obtidas, [cite: 66]
        COUNT(DISTINCT r.raceid) AS corridas_participadas [cite: 66]
    FROM
        results res
    JOIN
        races r ON res.raceid = r.raceid
    JOIN
        circuits circ ON r.circuitid = circ.circuitid
    WHERE
        res.driverid = piloto_id
    GROUP BY
        r.year, circ.name
    ORDER BY
        r.year, circ.name;
END;
$$ LANGUAGE plpgsql;