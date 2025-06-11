CREATE OR REPLACE FUNCTION qtd_pilotos_escuderia(p_nome_escuderia TEXT)
RETURNS TEXT AS $$
DECLARE
    v_qtd INTEGER;
    v_nome_constructor TEXT;
BEGIN
   
    SELECT COUNT(DISTINCT q.driverid)
    INTO v_qtd
    FROM qualifying q
    JOIN constructors c ON q.constructorid = c.constructorid
    WHERE UPPER(c.name) = UPPER(p_nome_escuderia);

    RETURN v_qtd::TEXT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '0';
END;
$$ LANGUAGE plpgsql;
