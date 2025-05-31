CREATE OR REPLACE PROCEDURE inserir_lideres_nao_cadastrados AS
    -- Cursor para passar por todos os líderes da tabela lider
    CURSOR c_lider IS
        SELECT CPI
        FROM lider;
    
    -- Variável para guardar o CPI
    v_lider_idlider lider.CPI%TYPE;
BEGIN
    FOR r_lider IN c_lider LOOP -- Para cada lider
        BEGIN
            -- Verifica se o líder já está na tabela USER
            SELECT idlider INTO v_lider_idlider
                FROM users
                WHERE idlider = r_lider.CPI;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- Somente ocorre se se não for encontrado o líder na tabela user
                INSERT INTO users (idlider, password) -- Insere na tabela user
                    VALUES (r_lider.CPI, r_lider.CPI);
        END;
    END LOOP;
END inserir_lideres_nao_cadastrados;
/
