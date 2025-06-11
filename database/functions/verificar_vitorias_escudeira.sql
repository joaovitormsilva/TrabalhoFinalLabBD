CREATE OR REPLACE FUNCTION verificar_vitorias_escudeira(nome_construtor VARCHAR)
RETURNS TEXT AS $$
DECLARE
    v_qtd INTEGER;
    v_nome_constructor TEXT;
BEGIN
    SELECT COUNT(*) INTO v_qtd
    FROM results r
    JOIN constructors c ON r.constructorid::integer = c.constructorid
    WHERE r.rank = '1' AND c.name = nome_construtor;

    RETURN v_qtd;
END;
$$ LANGUAGE plpgsql;


SELECT verificar_vitorias_escudeira('McLaren');
