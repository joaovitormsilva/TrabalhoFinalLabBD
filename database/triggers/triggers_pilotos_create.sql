CREATE OR REPLACE FUNCTION create_piloto_user()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM USERS WHERE Login = NEW.driverref || '_d') THEN
        RAISE EXCEPTION 'Já existe um usuário com o login %_d. Inserção cancelada.', NEW.driverRef;
    END IF;
    INSERT INTO users(login, password, tipo, idOriginal)
    VALUES (NEW.driverref || '_d', NEW.driverref, 'Piloto', NEW.driverId);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_piloto
AFTER INSERT ON drivers
FOR EACH ROW
EXECUTE FUNCTION create_pilot_user();