CREATE OR REPLACE FUNCTION insere_usuario_piloto()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM users WHERE login = NEW.driverref || '_d') THEN
        RAISE EXCEPTION 'Já existe um usuário com o login %.', NEW.driverref || '_d';
    END IF;

    INSERT INTO users (login, password, tipo, idoriginal)
    VALUES (NEW.driverref || '_d', crypt(NEW.driverref, gen_salt('bf')), 'Piloto', NEW.driverid);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_piloto_insert
AFTER INSERT ON driver
FOR EACH ROW
EXECUTE FUNCTION insere_usuario_piloto();


