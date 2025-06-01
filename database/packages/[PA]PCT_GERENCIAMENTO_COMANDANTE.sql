-- Declaração de pacote para manipulações de usuário
CREATE OR REPLACE PACKAGE PCT_GERENCIAMENTO_COMANDANTE AS
    E_USER_NAO_CADASTRADO EXCEPTION;
    E_USER_NAO_EH_COMANDANTE EXCEPTION;
    E_NACAO_JA_TEM_FEDERACAO EXCEPTION;
    E_NACAO_NAO_TEM_FEDERACAO EXCEPTION;
    E_PLANETA_JA_DOMINADO EXCEPTION;
    FUNCTION inserir_federacao (
        p_cpiuser LIDER.CPI%TYPE,
        p_federacao FEDERACAO.NOME%TYPE
    ) RETURN VARCHAR2;
    FUNCTION excluir_federacao (
        p_cpiuser LIDER.CPI%TYPE
    ) RETURN VARCHAR2;
    FUNCTION insere_dominancia (
        p_cpiuser LIDER.CPI%TYPE,
        p_planeta PLANETA.ID_ASTRO%TYPE
    ) RETURN VARCHAR2;
    FUNCTION criar_federacao (
        p_cpiuser LIDER.CPI%TYPE,
        p_federacao FEDERACAO.NOME%TYPE
    ) RETURN VARCHAR2;
END PCT_GERENCIAMENTO_COMANDANTE;

/

-- Corpo do pacote utilitário
CREATE OR REPLACE PACKAGE BODY PCT_GERENCIAMENTO_COMANDANTE AS
    FUNCTION retorna_nacao(
        p_cpiuser LIDER.CPI%TYPE
    ) RETURN FACCAO.NOME%TYPE IS
        v_nacao NACAO.NOME%TYPE;
    BEGIN
        SELECT nacao INTO v_nacao FROM lider WHERE CPI =  p_cpiuser;
        RETURN v_nacao;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END retorna_nacao;

    FUNCTION retorna_se_comandante(
        p_cpiuser LIDER.CPI%TYPE
    ) RETURN BOOLEAN IS
        v_cargo LIDER.CARGO%TYPE;
        v_saida BOOLEAN;
    BEGIN
        SELECT cargo INTO v_cargo FROM lider WHERE CPI =  p_cpiuser;
        IF UPPER(TRIM(v_cargo)) = 'COMANDANTE' THEN
            RETURN TRUE;
        END IF;
        RETURN FALSE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END retorna_se_comandante;

    FUNCTION inserir_federacao (
        p_cpiuser LIDER.CPI%TYPE,
        p_federacao FEDERACAO.NOME%TYPE
    ) RETURN VARCHAR2 IS
        v_nacao NACAO.NOME%TYPE;
        v_federacao_antiga FEDERACAO.NOME%TYPE;
    BEGIN
        v_nacao := retorna_nacao(p_cpiuser);
        IF v_nacao IS NULL THEN
            RAISE E_USER_NAO_CADASTRADO;
        END IF;
        IF (NOT retorna_se_comandante(p_cpiuser)) THEN
            RAISE E_USER_NAO_EH_COMANDANTE;
        END IF;
        SELECT FEDERACAO INTO v_federacao_antiga FROM NACAO WHERE NOME = v_nacao;
        IF v_federacao_antiga IS NOT NULL THEN
            RAISE E_NACAO_JA_TEM_FEDERACAO;
        END IF;
        UPDATE NACAO SET FEDERACAO = p_federacao WHERE NOME = v_nacao;
        RETURN 'Federação inserida com sucesso!';
    EXCEPTION 
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado.');
        WHEN E_USER_NAO_EH_COMANDANTE THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é comandante.');
        WHEN E_NACAO_JA_TEM_FEDERACAO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nação já tem federação.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nação não existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Não foi possível inserir federação.');
    END inserir_federacao;

    FUNCTION excluir_federacao (
        p_cpiuser LIDER.CPI%TYPE
    ) RETURN VARCHAR2 IS
        v_nacao NACAO.NOME%TYPE;
        v_federacao_antiga FEDERACAO.NOME%TYPE;
    BEGIN
        v_nacao := retorna_nacao(p_cpiuser);
        IF v_nacao IS NULL THEN
            RAISE E_USER_NAO_CADASTRADO;
        END IF;
        IF (NOT retorna_se_comandante(p_cpiuser)) THEN
            RAISE E_USER_NAO_EH_COMANDANTE;
        END IF;
        SELECT FEDERACAO INTO v_federacao_antiga FROM NACAO WHERE NOME = v_nacao;
        IF v_federacao_antiga IS NULL THEN
            RAISE E_NACAO_NAO_TEM_FEDERACAO;
        END IF;
        UPDATE NACAO SET FEDERACAO = null WHERE NOME = v_nacao;
        RETURN 'Federação excluída com sucesso!';
    EXCEPTION 
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado.');
        WHEN E_USER_NAO_EH_COMANDANTE THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é comandante.');
        WHEN E_NACAO_NAO_TEM_FEDERACAO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nação já não tem federação.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nação não existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Não foi possível inserir federação.');
    END excluir_federacao;

    FUNCTION insere_dominancia (
        p_cpiuser LIDER.CPI%TYPE,
        p_planeta PLANETA.ID_ASTRO%TYPE
    ) RETURN VARCHAR2 IS
        v_nacao NACAO.NOME%TYPE;
        v_inicio_dominancia DOMINANCIA.DATA_INI%TYPE;
        v_fim_dominancia DOMINANCIA.DATA_FIM%TYPE;
        v_data_atual DATE := SYSDATE; 
        v_count NUMBER;
    BEGIN
        v_nacao := retorna_nacao(p_cpiuser);
        IF v_nacao IS NULL THEN
            RAISE E_USER_NAO_CADASTRADO;
        END IF;
        IF (NOT retorna_se_comandante(p_cpiuser)) THEN
            RAISE E_USER_NAO_EH_COMANDANTE;
        END IF;
        SELECT COUNT(*) INTO v_count FROM DOMINANCIA WHERE PLANETA = p_planeta;
        IF v_count > 0 THEN
            SELECT DATA_INI, DATA_FIM INTO v_inicio_dominancia, v_fim_dominancia FROM DOMINANCIA WHERE PLANETA = p_planeta;
            -- Lógica para determinar se o planeta já está dominado (considera-se que não pode inserir dominações futuras)
            IF v_inicio_dominancia IS NOT NULL THEN -- Se tem dado de dominância
                IF v_fim_dominancia IS NULL OR v_fim_dominancia > v_data_atual THEN -- Se dominância não acabou ainda
                    RAISE E_PLANETA_JA_DOMINADO;
                END IF;
            END IF;
        END IF;
        INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES (p_planeta, v_nacao, v_data_atual);
        RETURN 'Dominância inserida com sucesso!';
    EXCEPTION 
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado.');
        WHEN E_USER_NAO_EH_COMANDANTE THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é comandante.');
        WHEN E_PLANETA_JA_DOMINADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Planeta já está dominado.');
        --WHEN OTHERS THEN
            --RAISE_APPLICATION_ERROR(-20000, 'Não foi possível inserir dominância.');
    END insere_dominancia;

    FUNCTION criar_federacao (
        p_cpiuser LIDER.CPI%TYPE,
        p_federacao FEDERACAO.NOME%TYPE
    ) RETURN VARCHAR2 IS
        v_nacao NACAO.NOME%TYPE;
        v_federacao_antiga FEDERACAO.NOME%TYPE;
    BEGIN
        v_nacao := retorna_nacao(p_cpiuser);
        IF v_nacao IS NULL THEN
            RAISE E_USER_NAO_CADASTRADO;
        END IF;
        IF (NOT retorna_se_comandante(p_cpiuser)) THEN
            RAISE E_USER_NAO_EH_COMANDANTE;
        END IF;
        SELECT FEDERACAO INTO v_federacao_antiga FROM NACAO WHERE NOME = v_nacao;
        IF v_federacao_antiga IS NOT NULL THEN
            RAISE E_NACAO_JA_TEM_FEDERACAO;
        END IF;
        INSERT INTO FEDERACAO VALUES (p_federacao, SYSDATE);
        UPDATE NACAO SET FEDERACAO = p_federacao WHERE NOME = v_nacao;
        RETURN 'Federação criada com sucesso!';
    EXCEPTION 
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado.');
        WHEN E_USER_NAO_EH_COMANDANTE THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é comandante.');
        WHEN E_NACAO_JA_TEM_FEDERACAO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nação já tem federação.');
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20000, 'Federação inválida.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Não foi possível inserir federação.');
    END criar_federacao;
    
END PCT_GERENCIAMENTO_COMANDANTE;
/
