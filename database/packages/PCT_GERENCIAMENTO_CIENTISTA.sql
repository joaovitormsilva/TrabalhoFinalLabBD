-- Declaração de pacote para gerenciamento do cientista
CREATE OR REPLACE PACKAGE PCT_GERENCIAMENTO_CIENTISTA AS
    E_USER_NAO_CADASTRADO EXCEPTION;
    E_NAO_EH_CIENTISTA EXCEPTION;
    FUNCTION insere_estrela (
        p_cpi LIDER.CPI%TYPE,
        p_id ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN VARCHAR2;
    FUNCTION remove_estrela_por_id (
        p_cpi LIDER.CPI%TYPE,
        p_id ESTRELA.ID_ESTRELA%TYPE
    ) RETURN VARCHAR2;
    FUNCTION remove_estrela_por_posicao (
        p_cpi LIDER.CPI%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN VARCHAR2;
    FUNCTION ler_estrela_por_id (
        p_cpi LIDER.CPI%TYPE,
        p_id ESTRELA.ID_ESTRELA%TYPE
    ) RETURN VARCHAR2;
    FUNCTION ler_estrela_por_posicao (
        p_cpi LIDER.CPI%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN VARCHAR2;
    FUNCTION update_estrela (
        p_cpi LIDER.CPI%TYPE,
        p_id ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN VARCHAR2;
END PCT_GERENCIAMENTO_CIENTISTA;

/

-- Corpo do pacote utilitário
CREATE OR REPLACE PACKAGE BODY PCT_GERENCIAMENTO_CIENTISTA AS
    FUNCTION retorna_se_cientista(
        p_cpiuser LIDER.CPI%TYPE
    ) RETURN BOOLEAN IS
        v_cargo LIDER.CARGO%TYPE;
        v_saida BOOLEAN;
    BEGIN
        SELECT cargo INTO v_cargo FROM lider WHERE CPI =  p_cpiuser;
        IF UPPER(TRIM(v_cargo)) = 'CIENTISTA' THEN
            RETURN TRUE;
        END IF;
        RETURN FALSE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END retorna_se_cientista;

    FUNCTION insere_estrela (
        p_cpi LIDER.CPI%TYPE,
        p_id ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN VARCHAR2 IS
    BEGIN
        IF (NOT retorna_se_cientista(p_cpi)) THEN
            RAISE E_NAO_EH_CIENTISTA;
        END IF;
        INSERT INTO ESTRELA VALUES (p_id, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);
        RETURN 'Estrela inserida com sucesso.';
    EXCEPTION
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado');
        WHEN E_NAO_EH_CIENTISTA THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é cientista');
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20000, 'Já existe estrela nessa posição ou com esse ID');
        --WHEN OTHERS THEN
            --RAISE_APPLICATION_ERROR(-20000, 'Não foi possível inserir estrela.');
    END insere_estrela;

    FUNCTION remove_estrela_por_id (
        p_cpi LIDER.CPI%TYPE,
        p_id ESTRELA.ID_ESTRELA%TYPE
    ) RETURN VARCHAR2 IS
        v_estrela ESTRELA.ID_ESTRELA%TYPE;
    BEGIN
        IF (NOT retorna_se_cientista(p_cpi)) THEN
            RAISE E_NAO_EH_CIENTISTA;
        END IF;
        SELECT ID_ESTRELA INTO v_estrela FROM ESTRELA WHERE ID_ESTRELA = p_id;
        DELETE FROM ESTRELA WHERE ID_ESTRELA = p_id;
        RETURN 'Estrela removida com sucesso.';
    EXCEPTION
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado');
        WHEN E_NAO_EH_CIENTISTA THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é cientista');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Estrela com esse id não existe');
        --WHEN OTHERS THEN
            --RAISE_APPLICATION_ERROR(-20000, 'Não foi possível remover estrela.');
    END remove_estrela_por_id;

    FUNCTION remove_estrela_por_posicao (
        p_cpi LIDER.CPI%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN VARCHAR2 IS
        v_estrela ESTRELA.ID_ESTRELA%TYPE;
    BEGIN
        IF (NOT retorna_se_cientista(p_cpi)) THEN
            RAISE E_NAO_EH_CIENTISTA;
        END IF;
        SELECT ID_ESTRELA INTO v_estrela FROM ESTRELA WHERE X = p_x AND Y = p_y AND Z = p_z;
        DELETE FROM ESTRELA WHERE X = p_x AND Y = p_y AND Z = p_z;
        RETURN 'Estrela removida com sucesso.';
    EXCEPTION
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado');
        WHEN E_NAO_EH_CIENTISTA THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é cientista');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Estrela nessa posição não existe');
        --WHEN OTHERS THEN
            --RAISE_APPLICATION_ERROR(-20000, 'Não foi possível remover estrela.');
    END remove_estrela_por_posicao;

    FUNCTION ler_estrela_por_id (
        p_cpi LIDER.CPI%TYPE,
        p_id ESTRELA.ID_ESTRELA%TYPE
    ) RETURN VARCHAR2 IS
        v_estrela ESTRELA%ROWTYPE;
        v_saida VARCHAR2(32767) := 'ID_ESTRELA;NOME;NOME;CLASSIFICACAO;MASSA;X;Y;Z' || CHR(10);
    BEGIN
        IF (NOT retorna_se_cientista(p_cpi)) THEN
            RAISE E_NAO_EH_CIENTISTA;
        END IF;
        SELECT * INTO v_estrela FROM ESTRELA WHERE ID_ESTRELA = p_id;
        v_saida := v_saida || v_estrela.id_estrela || ';' || v_estrela.nome || ';' || v_estrela.classificacao || ';' || v_estrela.massa || ';' || v_estrela.x || ';' || v_estrela.y || ';' || v_estrela.z || CHR(10);
        RETURN v_saida;
    EXCEPTION
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado');
        WHEN E_NAO_EH_CIENTISTA THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é cientista');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Estrela com esse id não existe');
        --WHEN OTHERS THEN
            --RAISE_APPLICATION_ERROR(-20000, 'Não foi possível ler estrela.');
    END ler_estrela_por_id;

    FUNCTION ler_estrela_por_posicao (
        p_cpi LIDER.CPI%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN VARCHAR2 IS
        v_estrela ESTRELA%ROWTYPE;
        v_saida VARCHAR2(32767) := 'ID_ESTRELA;NOME;NOME;CLASSIFICACAO;MASSA;X;Y;Z' || CHR(10);
    BEGIN
        IF (NOT retorna_se_cientista(p_cpi)) THEN
            RAISE E_NAO_EH_CIENTISTA;
        END IF;
        SELECT * INTO v_estrela FROM ESTRELA WHERE X = p_x AND Y = p_y AND Z = p_z;
        v_saida := v_saida || v_estrela.id_estrela || ';' || v_estrela.nome || ';' || v_estrela.classificacao || ';' || v_estrela.massa || ';' || v_estrela.x || ';' || v_estrela.y || ';' || v_estrela.z || CHR(10);
        RETURN v_saida;
    EXCEPTION
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado');
        WHEN E_NAO_EH_CIENTISTA THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é cientista');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Estrela com esse id não existe');
        --WHEN OTHERS THEN
            --RAISE_APPLICATION_ERROR(-20000, 'Não foi possível ler estrela.');
    END ler_estrela_por_posicao;

    FUNCTION update_estrela (
        p_cpi LIDER.CPI%TYPE,
        p_id ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN VARCHAR2 IS
        v_estrela ESTRELA.ID_ESTRELA%TYPE;
    BEGIN
        IF (NOT retorna_se_cientista(p_cpi)) THEN
            RAISE E_NAO_EH_CIENTISTA;
        END IF;
        SELECT ID_ESTRELA INTO v_estrela FROM ESTRELA WHERE ID_ESTRELA = p_id;
        UPDATE ESTRELA SET nome = p_nome, classificacao = p_classificacao, massa = p_massa, x = p_x, y = p_y, z = p_z WHERE id_estrela = p_id;
        RETURN 'Estrela atualizada com sucesso.';
    EXCEPTION
        WHEN E_USER_NAO_CADASTRADO THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não cadastrado.');
        WHEN E_NAO_EH_CIENTISTA THEN
            RAISE_APPLICATION_ERROR(-20000, 'Usuário não é cientista.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Estrela com esse id não existe.');
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20000, 'Já existe estrela nessa posição.');
        --WHEN OTHERS THEN
            --RAISE_APPLICATION_ERROR(-20000, 'Não foi possível atualizar estrela.');
    END update_estrela;
    
END PCT_GERENCIAMENTO_CIENTISTA;
/
