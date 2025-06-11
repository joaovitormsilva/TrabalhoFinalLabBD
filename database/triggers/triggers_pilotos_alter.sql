CREATE OR REPLACE FUNCTION update_pilot_user()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.driverref IS DISTINCT FROM NEW.driverref THEN
        UPDATE USERS
        SET Login = NEW.driverref || '_d',
            Password = NEW.driverref
        WHERE IdOriginal = OLD.driverId AND Tipo = 'Piloto'; 
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_update_pilot
AFTER UPDATE OF driverRef ON drivers
FOR EACH ROW
EXECUTE FUNCTION update_pilot_user();