CREATE OR REPLACE FUNCTION get_logged_in_pilot_id()
RETURNS INT AS $$
DECLARE
    logged_in_user_login VARCHAR(255);
    pilot_id INT;
BEGIN
    logged_in_user_login := current_setting('app.current_user_login', true);

    SELECT IdOriginal INTO pilot_id
    FROM USERS
    WHERE Login = logged_in_user_login AND Tipo = 'Piloto';

    IF pilot_id IS NULL THEN
        RAISE EXCEPTION 'Nenhum piloto logado ou usuário não é do tipo Piloto. Verifique a configuração da sessão.';
    END IF;

    RETURN pilot_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_logged_in_pilot_id IS 'Retorna o IdOriginal do piloto atualmente logado, simulando o contexto da sessão da aplicação.';