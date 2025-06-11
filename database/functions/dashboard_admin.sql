CREATE OR REPLACE FUNCTION dashboard_admin_qtds()
RETURNS TEXT AS $$
DECLARE
    qtd_pilotos INTEGER;
    qtd_escuderias INTEGER;
    qtd_temporadas INTEGER;
BEGIN
    SELECT COUNT(*) INTO qtd_pilotos FROM driver;
    SELECT COUNT(*) INTO qtd_escuderias FROM constructors;
    SELECT COUNT(*) INTO qtd_temporadas FROM seasons;

    RETURN 'Pilotos: ' || qtd_pilotos || ', Escuderias: ' || qtd_escuderias || ', Temporadas: ' || qtd_temporadas;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION dashboard_admin_corridas_ano()
RETURNS TEXT AS $$
DECLARE
    v_result TEXT := '';
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT r.name AS corrida,
               COUNT(l.lap) AS total_voltas,
               r.time AS tempo_corrida
        FROM races r
        LEFT JOIN laptimes l ON r.raceid = l.raceid
        WHERE r.year = EXTRACT(YEAR FROM CURRENT_DATE)
        GROUP BY r.name, r.time
    LOOP
        v_result := v_result || 'Corrida: ' || rec.corrida ||
                                ', Voltas: ' || rec.total_voltas ||
                                ', Tempo: ' || COALESCE(rec.tempo_corrida, 'N/A') || E'\n';
    END LOOP;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION dashboard_admin_pontos_escuderias()
RETURNS TEXT AS $$
DECLARE
    v_result TEXT := '';
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT c.name AS escuderia,
               SUM(r.points) AS total_pontos
        FROM results r
        JOIN constructors c ON r.constructorid = c.constructorid
        JOIN races ra ON r.raceid = ra.raceid
        WHERE ra.year = EXTRACT(YEAR FROM CURRENT_DATE)
        GROUP BY c.name
        ORDER BY total_pontos DESC
    LOOP
        v_result := v_result || 'Escuderia: ' || rec.escuderia ||
                                ', Pontos: ' || rec.total_pontos || E'\n';
    END LOOP;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION dashboard_admin_pontos_pilotos()
RETURNS TEXT AS $$
DECLARE
    v_result TEXT := '';
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT d.forename || ' ' || d.surname AS piloto,
               SUM(r.points) AS total_pontos
        FROM results r
        JOIN driver d ON r.driverid = d.driverid
        JOIN races ra ON r.raceid = ra.raceid
        WHERE ra.year = EXTRACT(YEAR FROM CURRENT_DATE)
        GROUP BY d.forename, d.surname
        ORDER BY total_pontos DESC
    LOOP
        v_result := v_result || 'Piloto: ' || rec.piloto ||
                                ', Pontos: ' || rec.total_pontos || E'\n';
    END LOOP;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

