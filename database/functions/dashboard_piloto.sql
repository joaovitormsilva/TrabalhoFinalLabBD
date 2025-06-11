CREATE OR REPLACE FUNCTION info_piloto_dashboard(p_login TEXT)
RETURNS TABLE (
    primeiro_ano INT,
    ultimo_ano INT,
    ano INT,
    circuito TEXT,
    pontos INT,
    vitorias INT,
    corridas INT
) AS $$
DECLARE
    id_piloto INT;
BEGIN
    SELECT idOriginal INTO id_piloto
    FROM USERS
    WHERE login = p_login AND tipo = 'Piloto';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Piloto não encontrado';
    END IF;

    RETURN QUERY
    WITH dados AS (
        SELECT
            r.driverid,
            s.year,
            c.name AS nome_circuito,
            r.points,
            CASE WHEN r.position = 1 THEN 1 ELSE 0 END AS vitoria,
            1 AS corrida
        FROM results r
        JOIN races ra ON ra.raceid = r.raceid
        JOIN circuits c ON c.circuitid = ra.circuitid
        JOIN seasons s ON s.year = ra.year
        WHERE r.driverid = id_piloto
    ),
    anos AS (
        SELECT MIN(year) AS primeiro_ano, MAX(year) AS ultimo_ano
        FROM dados
    )
    SELECT 
        (SELECT a.primeiro_ano FROM anos a) AS primeiro_ano,
        (SELECT a.ultimo_ano FROM anos a) AS ultimo_ano,
        d.year AS ano,
        d.nome_circuito AS circuito,
        SUM(d.points)::INT AS pontos,        -- Cast explícito aqui
        SUM(d.vitoria)::INT AS vitorias,     -- Cast explícito aqui
        COUNT(d.corrida)::INT AS corridas    -- Cast explícito aqui
    FROM dados d
    GROUP BY d.year, d.nome_circuito;
END;
$$ LANGUAGE plpgsql;
