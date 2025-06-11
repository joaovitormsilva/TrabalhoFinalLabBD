CREATE OR REPLACE FUNCTION insere_usuario_escuderia()
RETURNS TRIGGER AS $$
DECLARE
    v_login TEXT := NEW.constructorref || '_c';
BEGIN
    IF EXISTS (SELECT 1 FROM USERS WHERE login = v_login) THEN
        RAISE EXCEPTION 'Login % já existe. Inserção cancelada.', v_login;
    END IF;

    INSERT INTO USERS (login, password, tipo, idoriginal)
    VALUES (
        v_login,
        crypt(NEW.constructorref, gen_salt('bf')),
        'Escuderia',
        NEW.constructorid
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


