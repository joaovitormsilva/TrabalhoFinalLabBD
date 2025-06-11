CREATE OR REPLACE FUNCTION intervalo_anos_escuderia(p_nome_escuderia TEXT)
RETURNS TEXT AS $$
DECLARE
    v_ano_min INTEGER;
    v_ano_max INTEGER;
BEGIN
    SELECT MIN(ra.year), MAX(ra.year)
    INTO v_ano_min, v_ano_max
    FROM races ra
    JOIN results re ON ra.raceid = re.raceid
    JOIN constructors c ON re.constructorid::integer = c.constructorid
    WHERE UPPER(c.name) = UPPER(p_nome_escuderia);

    IF v_ano_min IS NULL OR v_ano_max IS NULL THEN
        RETURN 'Sem dados';
    ELSE
        RETURN v_ano_min::TEXT || ' - ' || v_ano_max::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Erro na consulta';
END;
$$ LANGUAGE plpgsql;

SELECT intervalo_anos_escuderia('McLaren');
