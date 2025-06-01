-- Trigger function para inserir usuário escuderia ao cadastrar uma nova escuderia


CREATE OR REPLACE FUNCTION insere_usuario_escuderia()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO USERS (login, password, tipo, idoriginal)
    VALUES (
        NEW.constructorref || '_c',
        crypt(NEW.constructorref, gen_salt('bf')),
        'Escuderia',
        NEW.constructorid
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

