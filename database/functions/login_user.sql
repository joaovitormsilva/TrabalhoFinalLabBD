CREATE OR REPLACE FUNCTION public.login_usuario(p_login TEXT, p_senha TEXT)
RETURNS TEXT AS $$
DECLARE
    u USERS%ROWTYPE;
    nacao TEXT := '';
    escuderia TEXT := '';
BEGIN
    SELECT * INTO u FROM USERS
    WHERE login = p_login AND password = crypt(p_senha, password);

    IF NOT FOUND THEN
        RETURN 'ERRO: Login ou senha incorretos';
    END IF;

    IF u.tipo = 'Piloto' THEN
        SELECT nationality INTO nacao FROM driver WHERE driverid = u.idoriginal;
        SELECT name INTO escuderia FROM constructors WHERE constructorid = (
            SELECT constructorid FROM driver WHERE driverid = u.idoriginal
        );
    ELSIF u.tipo = 'Escuderia' THEN
        SELECT name INTO escuderia FROM constructors WHERE constructorid = u.idoriginal;
    END IF;

    RETURN u.userid || ';' || u.login || ';' || u.tipo || ';' || COALESCE(nacao, '') || ';' || COALESCE(escuderia, '');
END;
$$ LANGUAGE plpgsql;
