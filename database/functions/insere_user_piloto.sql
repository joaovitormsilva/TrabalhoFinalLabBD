-- Trigger function para inserir usuário piloto ao cadastrar um novo piloto
CREATE OR REPLACE FUNCTION insere_usuario_piloto()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO USERS (login, password, tipo, idoriginal)
    VALUES (
        NEW.driverref || '_d',
        crypt(NEW.driverref, gen_salt('bf')),
        'Piloto',
        NEW.driverid
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
