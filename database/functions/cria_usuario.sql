-- Função para registrar novo usuário com hash de senha
-- IMPORTANTE: essa função simula a lógica de hash. Em produção, isso é feito no backend.



CREATE OR REPLACE FUNCTION cria_usuario(login TEXT, senha TEXT, tipo TEXT, id_original INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO USERS (login, password, tipo, idoriginal)
    VALUES (
        login,
        crypt(senha, gen_salt('bf')), -- criptografia Blowfish via extensão pgcrypto
        tipo,
        id_original
    );
END;
$$ LANGUAGE plpgsql;



/*
SELECT 
    COLUMN_NAME 
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME  = 'races'

*/