CREATE OR REPLACE FUNCTION delete_pilot_user()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM USERS
    WHERE idOriginal = OLD.driverId AND Tipo = 'Piloto';
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_delete_pilot
AFTER DELETE ON drivers
FOR EACH ROW
EXECUTE FUNCTION delete_pilot_user();