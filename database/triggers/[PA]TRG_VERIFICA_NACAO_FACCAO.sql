-- Criação de trigger para restrição b) na tabela nacao_faccao
CREATE OR REPLACE TRIGGER TRG_VERIFICA_NACAO_FACCAO FOR DELETE ON NACAO_FACCAO COMPOUND TRIGGER
    -- Criação de tipo para armazenar os relacionamentos entre nação e facção para líderes de facção
    TYPE T_NACAO_FACCAO IS TABLE OF NACAO_FACCAO%ROWTYPE;

    -- Declaração de variáveis
    V_NACOES_FACCOES_LIDERES T_NACAO_FACCAO := T_NACAO_FACCAO();
    V_NACAO_LIDER LIDER.NACAO%TYPE;

BEFORE STATEMENT IS BEGIN
    -- Consulta da nação e facção dos líderes de fações
    SELECT
        L.NACAO, F.NOME AS FACCAO
    BULK COLLECT INTO
        V_NACOES_FACCOES_LIDERES
    FROM
        LIDER L
    JOIN
        FACCAO F ON F.LIDER = L.CPI;
END BEFORE STATEMENT;
    
BEFORE EACH ROW IS BEGIN
    -- Atribuição da nação do líder com base na consulta do BEFORE STATEMENT
    V_NACAO_LIDER := NULL;
    FOR I IN 1..V_NACOES_FACCOES_LIDERES.COUNT LOOP
        IF :OLD.FACCAO = V_NACOES_FACCOES_LIDERES(I).FACCAO THEN
            V_NACAO_LIDER := V_NACOES_FACCOES_LIDERES(I).NACAO;
            EXIT;
        END IF;
    END LOOP;

    -- Se a nação do líder da facção for igual a nação que está sendo excluída, então dispara um erro
    IF V_NACAO_LIDER = :OLD.NACAO THEN
        raise_application_error(-20000, 'A exclusão deixa o líder da facção sem uma nação associada na facção.');
    END IF;
END BEFORE EACH ROW;

END TRG_VERIFICA_NACAO_FACCAO;
/
