CREATE OR REPLACE FUNCTION insere_usuario_piloto()
RETURNS TRIGGER AS $$
DECLARE
    v_login TEXT := NEW.driverref || 'd';
BEGIN
    IF EXISTS (SELECT 1 FROM USERS WHERE login = v_login) THEN
        RAISE EXCEPTION 'Login % já existe. Inserção cancelada.', v_login;
    END IF;
    INSERT INTO USERS (login, password, tipo, idoriginal)
    VALUES (
        v_login,
        crypt(NEW.driverref, gen_salt('bf')),
        'Piloto',
        NEW.driverid 
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

