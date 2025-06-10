
CREATE OR REPLACE FUNCTION relatorio_status_resultados()
RETURNS TABLE (status TEXT, quantidade INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT s.status, COUNT(*)::INTEGER AS quantidade
    FROM results r
    JOIN status s ON r.statusid = s.statusid
    GROUP BY s.status
    ORDER BY quantidade DESC;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION relatorio_aeroportos_proximos(nome_cidade TEXT)
RETURNS TABLE (
    cidade_consulta TEXT,
    iata_code TEXT,
    aeroporto_nome TEXT,
    cidade_aeroporto TEXT,
    distancia_km NUMERIC,
    tipo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ref.city AS cidade_consulta,
        alvo.iatacode::TEXT,
        alvo.name,
        alvo.city,
        ROUND(
            CAST(
                ST_DistanceSphere(
                    ST_SetSRID(ST_MakePoint(ref.longdeg, ref.latdeg), 4326),
                    ST_SetSRID(ST_MakePoint(alvo.longdeg, alvo.latdeg), 4326)
                ) / 1000 AS NUMERIC
            ), 2
        ),
        alvo.type::TEXt
    FROM airports ref
    JOIN airports alvo
      ON ST_DistanceSphere(
            ST_SetSRID(ST_MakePoint(ref.longdeg, ref.latdeg), 4326),
            ST_SetSRID(ST_MakePoint(alvo.longdeg, alvo.latdeg), 4326)
         ) <= 100000
    WHERE ref.city = nome_cidade
      AND ref.isocountry = 'BR'
      AND alvo.isocountry = 'BR'
      AND alvo.type IN ('medium_airport', 'large_airport')
    ORDER BY distancia_km;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION relatorio_total_corridas()
RETURNS INTEGER AS $$
DECLARE
    total INTEGER;
BEGIN
    SELECT COUNT(*) INTO total FROM races;
    RETURN total;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION relatorio_corridas_por_circuito()
RETURNS TABLE (
    circuito TEXT,
    qtd_corridas INTEGER,
    min_voltas INTEGER,
    media_voltas NUMERIC,
    max_voltas INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.name AS circuito,
        COUNT(DISTINCT r.raceId)::INTEGER AS qtd_corridas,
        MIN(v.qtd_voltas)::INTEGER AS min_voltas,
        ROUND(AVG(v.qtd_voltas), 2) AS media_voltas,
        MAX(v.qtd_voltas)::INTEGER AS max_voltas
    FROM (
        SELECT raceId, COUNT(*) AS qtd_voltas
        FROM laptimes
        GROUP BY raceId
    ) v
    JOIN races r ON r.raceId = v.raceId
    JOIN circuits c ON r.circuitId = c.circuitId
    GROUP BY c.name
    ORDER BY qtd_corridas DESC;
END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION relatorio_detalhamento_corridas()
RETURNS TABLE (
    circuito TEXT,
    corrida TEXT,
    voltas INTEGER,
    tempo_total_seg NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.name AS circuito,
        r.name AS corrida,
        COUNT(DISTINCT l.lap)::INTEGER AS voltas,          -- conta voltas distintas na laptimes
        ROUND(SUM(l.milliseconds)/1000.0, 2) AS tempo_total_seg
    FROM laptimes l
    JOIN races r ON l.raceId = r.raceId
    JOIN circuits c ON r.circuitId = c.circuitId
    GROUP BY c.name, r.name
    ORDER BY c.name, r.name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION relatorio_completo_por_escuderia()
RETURNS TABLE (
    escuderia TEXT,
    nivel SMALLINT,
    circuito TEXT,
    corrida TEXT,
    voltas INTEGER,
    tempo_total NUMERIC,
    qtd_corridas_total INTEGER,
    qtd_corridas_circuito INTEGER,
    min_voltas INTEGER,
    avg_voltas NUMERIC,
    max_voltas INTEGER
) AS $$
BEGIN
    RETURN QUERY

    -- 1. Total de corridas por escuderia
    SELECT 
        constructors.name AS escuderia,
        1::SMALLINT AS nivel,
        NULL::TEXT AS circuito,
        NULL::TEXT AS corrida,
        NULL::INTEGER AS voltas,
        NULL::NUMERIC AS tempo_total,
        COUNT(DISTINCT races.raceId)::INTEGER AS qtd_corridas_total,
        NULL::INTEGER AS qtd_corridas_circuito,
        NULL::INTEGER AS min_voltas,
        NULL::NUMERIC AS avg_voltas,
        NULL::INTEGER AS max_voltas
    FROM results
    JOIN constructors ON results.constructorId = constructors.constructorId
    JOIN races ON results.raceId = races.raceId
    GROUP BY constructors.name

    UNION ALL

    -- 2. Corridas por circuito (mín/média/máx de voltas)
    SELECT 
        constructors.name AS escuderia,
        2::SMALLINT AS nivel,
        circuits.name AS circuito,
        NULL::TEXT AS corrida,
        NULL::INTEGER AS voltas,
        NULL::NUMERIC AS tempo_total,
        NULL::INTEGER AS qtd_corridas_total,
        COUNT(DISTINCT races.raceId)::INTEGER AS qtd_corridas_circuito,
        MIN(sub.qtd_voltas)::INTEGER AS min_voltas,
        ROUND(AVG(sub.qtd_voltas)::NUMERIC, 2) AS avg_voltas,
        MAX(sub.qtd_voltas)::INTEGER AS max_voltas
    FROM results
    JOIN constructors ON results.constructorId = constructors.constructorId
    JOIN races ON results.raceId = races.raceId
    JOIN circuits ON races.circuitId = circuits.circuitId
    JOIN (
        SELECT raceId, COUNT(DISTINCT lap)::INTEGER AS qtd_voltas
        FROM laptimes
        GROUP BY raceId
    ) sub ON races.raceId = sub.raceId
    GROUP BY constructors.name, circuits.name

    UNION ALL

    -- 3. Corrida por corrida: voltas e tempo
    SELECT 
        constructors.name AS escuderia,
        3::SMALLINT AS nivel,
        circuits.name AS circuito,
        races.name AS corrida,
        COUNT(DISTINCT laptimes.lap)::INTEGER AS voltas,
        ROUND(SUM(laptimes.milliseconds) / 1000.0, 2) AS tempo_total,
        NULL::INTEGER AS qtd_corridas_total,
        NULL::INTEGER AS qtd_corridas_circuito,
        NULL::INTEGER AS min_voltas,
        NULL::NUMERIC AS avg_voltas,
        NULL::INTEGER AS max_voltas
    FROM results
    JOIN constructors ON results.constructorId = constructors.constructorId
    JOIN races ON results.raceId = races.raceId
    JOIN circuits ON races.circuitId = circuits.circuitId
    JOIN laptimes ON laptimes.raceId = races.raceId AND laptimes.driverId = results.driverId
    GROUP BY constructors.name, circuits.name, races.name
    ORDER BY escuderia, nivel, circuito, corrida;

END;
$$ LANGUAGE plpgsql;

