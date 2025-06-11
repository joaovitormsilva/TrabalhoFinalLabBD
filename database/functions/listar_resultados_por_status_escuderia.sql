CREATE OR REPLACE FUNCTION listar_resultados_por_status_escuderia(p_nome_escuderia TEXT)
RETURNS TEXT AS $$
DECLARE
    rec RECORD;
    v_result TEXT := '';
    v_msg TEXT;
BEGIN
    FOR rec IN
        SELECT
            s.status,
            COUNT(*) AS qtd_resultados
        FROM
            results r
        JOIN
            constructors c ON r.constructorid = c.constructorid
        JOIN
            status s ON r.statusid = s.statusid
        WHERE
            UPPER(c.name) = UPPER(p_nome_escuderia)
        GROUP BY
            s.status
        ORDER BY
            qtd_resultados DESC
    LOOP
        v_result := v_result || rec.status || ': ' || rec.qtd_resultados;
    END LOOP;

    IF v_result = '' THEN
        RETURN 'Sem dados para a escuderia ' || p_nome_escuderia;
    ELSE
        RETURN v_result::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_msg = MESSAGE_TEXT;
        RETURN 'Erro na consulta: ' || v_msg;
END;
$$ LANGUAGE plpgsql;

SELECT listar_resultados_por_status_escuderia('McLaren');
