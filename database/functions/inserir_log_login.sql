CREATE OR REPLACE FUNCTION inserir_log_login(p_login TEXT)
RETURNS VOID AS $$
DECLARE
    u_id INTEGER;
BEGIN
    SELECT userid INTO u_id FROM USERS WHERE login = p_login;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuário não encontrado para log.';
    END IF;

    INSERT INTO USERS_LOG (userid, data_login, hora_login)
    VALUES (
        u_id,
        CURRENT_DATE,
        CURRENT_TIME
    );
END;
$$ LANGUAGE plpgsql;

