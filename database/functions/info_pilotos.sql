CREATE OR REPLACE FUNCTION info_piloto(p_login TEXT)
RETURNS TEXT AS $$
DECLARE
    id_piloto INTEGER;
    forename TEXT;
    surname TEXT;
    escuderia_nome TEXT;
BEGIN
    -- Busca o driverid correspondente ao login
    SELECT idoriginal INTO id_piloto
    FROM USERS
    WHERE login = p_login AND tipo = 'Piloto';

    IF NOT FOUND THEN
        RETURN 'Erro: Piloto não encontrado';
    END IF;

    -- Busca os dados do piloto e da escuderia pela tabela qualifying
    SELECT DISTINCT d.forename, d.surname, c.name
    INTO forename, surname, escuderia_nome
    FROM driver d
    JOIN qualifying q ON d.driverid = q.driverid
    JOIN constructors c ON q.constructorid = c.constructorid
    WHERE d.driverid = id_piloto;

    -- Retorna os dados no formato esperado
    RETURN escuderia_nome || ';' || forename || ';' || surname;
END;
$$ LANGUAGE plpgsql;
