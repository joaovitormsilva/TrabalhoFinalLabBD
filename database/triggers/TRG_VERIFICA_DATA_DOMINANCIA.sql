CREATE OR REPLACE TRIGGER TRG_VERIFICA_DOMINANCIA
    BEFORE INSERT OR UPDATE ON DOMINANCIA
    FOR EACH ROW
DECLARE
    TYPE T_DOMINANCIAS IS TABLE OF DOMINANCIA%ROWTYPE;
    DOMINANCIAS T_DOMINANCIAS := T_DOMINANCIAS();
BEGIN
    -- Consulta das dominâncias do planeta que está sendo inserido ou atualizado
    BEGIN
        SELECT
            *
        BULK COLLECT INTO
            DOMINANCIAS
        FROM
            DOMINANCIA
        WHERE
            PLANETA = :NEW.PLANETA;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DOMINANCIAS := NULL;
    END;

    -- Verificação se o planeta está sob domínio de uma nação no período informado
    IF DOMINANCIAS IS NOT NULL THEN
        FOR I IN 1..DOMINANCIAS.COUNT LOOP
            IF DOMINANCIAS(I).DATA_FIM IS NULL AND (:NEW.DATA_INI >= DOMINANCIAS(I).DATA_INI OR :NEW.DATA_FIM > DOMINANCIAS(I).DATA_INI) 
            OR DOMINANCIAS(I).DATA_FIM IS NOT NULL AND :NEW.DATA_INI BETWEEN DOMINANCIAS(I).DATA_INI AND DOMINANCIAS(I).DATA_FIM THEN
                RAISE_APPLICATION_ERROR(-20000, 'O planeta já está sob domínio da nação ' || dominancias(i).nacao || ' no período informado.');
            END IF;
        END LOOP;
    END IF;
END TRG_VERIFICA_DOMINANCIA;
/
