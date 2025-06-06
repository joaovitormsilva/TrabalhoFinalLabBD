-- Criação de trigger para restrição de existência de federações sem nações
CREATE OR REPLACE TRIGGER TRG_EXCLUI_FEDERACAO_SEM_NACAO FOR UPDATE OF FEDERACAO OR DELETE ON NACAO COMPOUND TRIGGER
    -- Declaração de tipo para armazenamento de coleção
    TYPE T_FEDERACOES IS TABLE OF NACAO.FEDERACAO%TYPE;

    -- Declaração de variável
    FEDERACOES_EXCLUIDAS T_FEDERACOES := T_FEDERACOES();

AFTER EACH ROW IS BEGIN
    -- Adição de federação excluída da nação
    FEDERACOES_EXCLUIDAS.EXTEND();
    FEDERACOES_EXCLUIDAS(FEDERACOES_EXCLUIDAS.COUNT) := :OLD.FEDERACAO;
END AFTER EACH ROW;

AFTER STATEMENT IS BEGIN
    -- Deleção das federações excluídas que não possuem nenhuma nação
    FOR I IN 1..FEDERACOES_EXCLUIDAS.COUNT LOOP
        DELETE FROM FEDERACAO WHERE NOME = FEDERACOES_EXCLUIDAS(I) AND NOT EXISTS (
            SELECT 1 FROM NACAO WHERE FEDERACAO = FEDERACOES_EXCLUIDAS(I)
        );
    END LOOP;
END AFTER STATEMENT;

END TRG_EXCLUI_FEDERACAO_SEM_NACAO; 
/
