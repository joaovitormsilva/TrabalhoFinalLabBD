CREATE OR REPLACE TRIGGER TRG_USERS_PASSWORD
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
BEGIN
    -- Aplica MD5 no campo password usando a função calcular_md5
    :NEW.password := PCT_USER_TABLE.calcular_md5(:NEW.password);
END;
/
