-- Função para listar vitórias dos pilotos da escuderia
CREATE OR REPLACE FUNCTION listar_vitorias_escuderia(p_nome_escuderia TEXT)
RETURNS TEXT AS $$
DECLARE
    rec RECORD;
    v_result TEXT := '';
    v_msg TEXT;
BEGIN
    FOR rec IN
        SELECT
            d.forename || ' ' || d.surname AS nome_completo,
            COUNT(*) AS qtd_vitorias
        FROM
            driver d
        JOIN
            results r ON d.driverid = r.driverid
        JOIN
            constructors c ON r.constructorid = c.constructorid
        WHERE
            UPPER(c.name) = UPPER(p_nome_escuderia)
            AND r.rank = '1'
        GROUP BY
            d.driverid, d.forename, d.surname
        ORDER BY
            qtd_vitorias DESC
    LOOP
        v_result := v_result || rec.nome_completo || ': ' || rec.qtd_vitorias || ' vitórias';
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




SELECT listar_vitorias_escuderia('McLaren');
