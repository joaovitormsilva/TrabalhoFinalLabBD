CREATE OR REPLACE FUNCTION login_usuario(p_login TEXT, p_senha TEXT)
RETURNS TEXT AS $$
DECLARE
    u USERS%ROWTYPE;
    nacao TEXT := '';
    faccao TEXT := '';
BEGIN
    SELECT * INTO u FROM USERS
    WHERE login = p_login AND password = crypt(p_senha, password);

    IF NOT FOUND THEN
        RETURN 'ERRO: Login ou senha incorretos';
    END IF;

    -- Adiciona nacionalidade e faccao (escuderia) se for piloto
    IF u.tipo = 'Piloto' THEN
        SELECT nationality INTO nacao FROM drivers WHERE driverid = u.idoriginal;
        SELECT name INTO faccao FROM constructors WHERE constructorid = (
            SELECT constructorid FROM drivers WHERE driverid = u.idoriginal
        );
    ELSIF u.tipo = 'Escuderia' THEN
        SELECT name INTO faccao FROM constructors WHERE constructorid = u.idoriginal;
    END IF;

    RETURN u.userid || ';' || u.login || ';' || u.tipo || ';' || COALESCE(nacao, '') || ';' || COALESCE(faccao, '');
END;
$$ LANGUAGE plpgsql;
