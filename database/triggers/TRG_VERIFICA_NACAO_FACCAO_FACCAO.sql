-- Criação de trigger para restrição de associação de facção liderada à nação do líder na tabela faccao
CREATE OR REPLACE TRIGGER TRG_VERIFICA_NACAO_FACCAO_FACCAO FOR INSERT OR UPDATE OF LIDER ON FACCAO COMPOUND TRIGGER
    -- Criação de tipos para armazenamento de coleções
    TYPE T_LIDERES IS VARRAY(100000) OF LIDER%ROWTYPE;
    TYPE T_NACOES_FACCOES IS VARRAY(100000) OF NACAO_FACCAO%ROWTYPE;

    -- Declaração de variáveis
    V_LIDERES T_LIDERES := T_LIDERES();
    V_NACOES_FACCOES_PRE_INSERIDAS T_NACOES_FACCOES := T_NACOES_FACCOES();
    V_NACOES_FACCOES_POS_INSERIDAS T_NACOES_FACCOES := T_NACOES_FACCOES();
    V_NACAO_LIDER LIDER.NACAO%TYPE;
    V_NACAO_FACCAO NACAO_FACCAO%ROWTYPE;
    V_CORRESPONDENCIA_UPDATE_ENCONTRADA NUMBER;
    V_LANCAR_ERRO_UPDATE NUMBER := 0;

BEFORE STATEMENT IS BEGIN
    -- Consulta das nações dos líderes
    SELECT
        *
    BULK COLLECT INTO
        V_LIDERES
    FROM
        LIDER L;
    
    IF UPDATING THEN
        -- Consulta das associações de nações às facções
        SELECT
            *
        BULK COLLECT INTO
            V_NACOES_FACCOES_PRE_INSERIDAS
        FROM
            NACAO_FACCAO NF;
    END IF;
END BEFORE STATEMENT;

BEFORE EACH ROW IS BEGIN
    -- Atribuição da nação do líder com base na consulta do BEFORE STATEMENT
    V_NACAO_LIDER := NULL;
    FOR I IN 1..V_LIDERES.COUNT LOOP
        IF :NEW.LIDER = V_LIDERES(I).CPI THEN
            V_NACAO_LIDER := V_LIDERES(I).NACAO;
            EXIT;
        END IF;
    END LOOP;

    -- Se for uma nova facção, deve ser inserida a relação da nação do líder com a nova fação
    IF INSERTING THEN
        V_NACOES_FACCOES_POS_INSERIDAS.EXTEND();
        V_NACAO_FACCAO.NACAO := V_NACAO_LIDER;
        V_NACAO_FACCAO.FACCAO := :NEW.NOME;
        V_NACOES_FACCOES_POS_INSERIDAS(V_NACOES_FACCOES_POS_INSERIDAS.COUNT) := V_NACAO_FACCAO;

    -- Se for uma atualização, deve ser verificado se a nação do líder está associada à nova facção
    ELSIF UPDATING THEN
        V_CORRESPONDENCIA_UPDATE_ENCONTRADA := 0;
        FOR I IN 1..V_NACOES_FACCOES_PRE_INSERIDAS.COUNT LOOP
            IF V_NACOES_FACCOES_PRE_INSERIDAS(I).NACAO = V_NACAO_LIDER AND V_NACOES_FACCOES_PRE_INSERIDAS(I).FACCAO = :NEW.NOME THEN
                V_CORRESPONDENCIA_UPDATE_ENCONTRADA := 1;
                EXIT;
            END IF;
        END LOOP;
        IF V_CORRESPONDENCIA_UPDATE_ENCONTRADA = 0 THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder da facção atualizada deve estar associado a uma nação em que a facção está presente.');
        END IF;
    END IF;
END BEFORE EACH ROW;

AFTER STATEMENT IS BEGIN
    -- Inserção das novas relações entre nações e facções
    IF INSERTING THEN
        FOR I IN 1..V_NACOES_FACCOES_POS_INSERIDAS.COUNT LOOP
            INSERT INTO NACAO_FACCAO VALUES(V_NACOES_FACCOES_POS_INSERIDAS(I).NACAO, V_NACOES_FACCOES_POS_INSERIDAS(I).FACCAO);
        END LOOP;
    END IF;
END AFTER STATEMENT;

END TRG_VERIFICA_NACAO_FACCAO_FACCAO;
/
