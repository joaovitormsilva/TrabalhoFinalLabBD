CREATE OR REPLACE PACKAGE PCT_RELATORIO_COMANDANTE IS
    FUNCTION GERAR_RELATORIO_TODOS_PLANETAS_COMANDANTE(P_CPI_COMANDANTE LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
    FUNCTION GERAR_RELATORIO_PLANETAS_NACAO_COMANDANTE(P_CPI_COMANDANTE LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
    FUNCTION GERAR_RELATORIO_PLANETAS_EXPANSAO_COMANDANTE(P_CPI_COMANDANTE LIDER.CPI%TYPE, P_DIST_MAX NUMBER, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
END PCT_RELATORIO_COMANDANTE;
/

CREATE OR REPLACE PACKAGE BODY PCT_RELATORIO_COMANDANTE IS
    FUNCTION GERAR_RELATORIO_TODOS_PLANETAS_COMANDANTE(P_CPI_COMANDANTE LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;

        -- Tipo para registro de nação e datas de início e fim da última dominação
        TYPE REGDATASDOMINACAO IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            NOME_NACAO_DOMINANTE NACAO.NOME%TYPE,
            DATA_INICIO DATE,
            DATA_FIM DATE
        );

        -- Tipos para tabelas associativas dos resultados
        TYPE TABDATASDOMINACAO IS TABLE OF REGDATASDOMINACAO;

        -- Arrays associativos para armazenar os resultados
        DATAS_DOMINACAO_ATUAL TABDATASDOMINACAO;
    BEGIN
        -- Validação do comandante
        BEGIN
            SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_COMANDANTE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Comandante não encontrado.');
        END;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'COMANDANTE' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um comandante.');
        END IF;

        -- Consulta das datas de início e fim da última dominação
        SELECT
            P.ID_ASTRO AS ID_PLANETA,
            UD.NACAO AS NOME_NACAO_DOMINANTE,
            UD.DATA_INI,
            UD.DATA_FIM
        BULK COLLECT INTO DATAS_DOMINACAO_ATUAL
        FROM
            PLANETA P
        LEFT JOIN (
            SELECT D.NACAO, D.DATA_INI, D.DATA_FIM, D.PLANETA
            FROM DOMINANCIA D
            JOIN (
                SELECT PLANETA, MAX(DATA_INI) AS DATA_INI
                FROM DOMINANCIA
                GROUP BY PLANETA
            ) D2 ON D2.DATA_INI = D.DATA_INI AND D2.PLANETA = D.PLANETA
        ) UD ON UD.PLANETA = P.ID_ASTRO
        ORDER BY
            P.ID_ASTRO;

        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'PLANETA;ULT_NACAO_DOMINANTE;DATA_INICIO_DOMINACAO;DATA_FIM_DOMINACAO' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;

        FOR i IN P_LINHA_INICIO..(P_LINHA_INICIO+100) LOOP
            IF i > DATAS_DOMINACAO_ATUAL.COUNT THEN
                EXIT;
            END IF;
            V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || 
                DATAS_DOMINACAO_ATUAL(i).ID_PLANETA || ';' ||
                DATAS_DOMINACAO_ATUAL(i).NOME_NACAO_DOMINANTE || ';' ||
                DATAS_DOMINACAO_ATUAL(i).DATA_INICIO || ';' ||
                DATAS_DOMINACAO_ATUAL(i).DATA_FIM || CHR(10);
        END LOOP;

        RETURN V_SAIDA_RELATORIO;
    END GERAR_RELATORIO_TODOS_PLANETAS_COMANDANTE;

    FUNCTION GERAR_RELATORIO_PLANETAS_NACAO_COMANDANTE(P_CPI_COMANDANTE LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_QTD_LINHAS NUMBER;
        V_NUMERO_LINHA NUMBER;

        -- Tipo para registro de nação e datas de início e fim da última dominação
        TYPE REGDATASDOMINACAO IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            NOME_NACAO_DOMINANTE NACAO.NOME%TYPE,
            DATA_INICIO DATE,
            DATA_FIM DATE
        );

        -- Tipo para registro de quantidade de espécies, comunidades e habitantes
        TYPE REGQUANTIDADESESPCOMHAB IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            QTD_ESPECIES_ORIGINARIAS NUMBER,
            QTD_ESPECIES_ATUAIS NUMBER,
            QTD_COMUNIDADES_ATUAIS NUMBER,
            QTD_HABITANTES_ATUAIS NUMBER
        );

        -- Tipo genérico para registros com ID do planeta e quantidade
        TYPE REGIDQUANTIDADE IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            QUANTIDADE NUMBER
        );

        -- Tipo para registro da faccao majoritária
        TYPE REGFACCOESMAJORITARIAS IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            NOME_FACCAO_MAJORITARIA FACCAO.NOME%TYPE,
            QTD_FACCAO_MAJORITARIA NUMBER
        );

        -- Tipos para tabelas associativas dos resultados
        TYPE TABDATASDOMINACAO IS TABLE OF REGDATASDOMINACAO;
        TYPE TABQUANTIDADESESPCOMHAB IS TABLE OF REGQUANTIDADESESPCOMHAB;
        TYPE TABIDQUANTIDADE IS TABLE OF REGIDQUANTIDADE;
        TYPE TABFACCOESMAJORITARIAS IS TABLE OF REGFACCOESMAJORITARIAS INDEX BY VARCHAR2(32);

        -- Arrays associativos para armazenar os resultados
        DATAS_DOMINACAO_ATUAL TABDATASDOMINACAO;
        QTDS_ESP_COM_HAB TABQUANTIDADESESPCOMHAB;
        QTD_FACCOES TABIDQUANTIDADE;
        FACCOES_MAJORITARIAS TABFACCOESMAJORITARIAS := TABFACCOESMAJORITARIAS();
    BEGIN
        -- Validação do comandante
        SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_COMANDANTE;
        IF V_ATRIBUTOS_LIDER.CPI IS NULL THEN
            RAISE_APPLICATION_ERROR(-20000, 'Comandante não encontrado.');
        END IF;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'COMANDANTE' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um comandante.');
        END IF;

        -- Consulta das datas de início e fim da última dominação
        SELECT
            P.ID_ASTRO AS ID_PLANETA,
            UD.NACAO AS NOME_NACAO_DOMINANTE,
            UD.DATA_INI,
            UD.DATA_FIM
        BULK COLLECT INTO DATAS_DOMINACAO_ATUAL
        FROM
            PLANETA P
        LEFT JOIN (
            SELECT D.NACAO, D.DATA_INI, D.DATA_FIM, D.PLANETA
            FROM DOMINANCIA D
            JOIN (
                SELECT PLANETA, MAX(DATA_INI) AS DATA_INI
                FROM DOMINANCIA
                GROUP BY PLANETA
            ) D2 ON D2.DATA_INI = D.DATA_INI AND D2.PLANETA = D.PLANETA
        ) UD ON UD.PLANETA = P.ID_ASTRO
        ORDER BY
            P.ID_ASTRO;

        -- Consulta das quantidades de espécies originárias, espécies atuais, comunidades e habitantes presentes
        SELECT
            P.ID_ASTRO AS ID_PLANETA,
            COUNT (
                DISTINCT EO.NOME
            ) AS QTD_ESPECIES_ORIGINARIAS,
            COUNT (
                DISTINCT
                CASE
                    WHEN H.PLANETA IS NOT NULL AND (H.DATA_FIM IS NULL OR H.DATA_FIM > CURRENT_DATE) THEN H.ESPECIE
                    ELSE NULL
                END
            ) AS QTD_ESPECIES_ATUAIS,
            COUNT (
                DISTINCT
                CASE
                    WHEN H.PLANETA IS NOT NULL AND (H.DATA_FIM IS NULL OR H.DATA_FIM > CURRENT_DATE) THEN H.COMUNIDADE
                    ELSE NULL
                END
            ) AS QTD_COMUNIDADES_ATUAIS,
            SUM(
                CASE
                    WHEN H.PLANETA IS NOT NULL AND (H.DATA_FIM IS NULL OR H.DATA_FIM > CURRENT_DATE) THEN C.QTD_HABITANTES
                    ELSE 0
                END
            ) AS QTD_HABITANTES_ATUAIS
        BULK COLLECT INTO QTDS_ESP_COM_HAB
        FROM
            PLANETA P
        LEFT JOIN
            HABITACAO H ON H.PLANETA = P.ID_ASTRO
        LEFT JOIN
            COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        LEFT JOIN
            ESPECIE EO ON EO.NOME = H.ESPECIE
        GROUP BY
            P.ID_ASTRO
        ORDER BY
            P.ID_ASTRO;

        -- Consulta da quantidade de facções presentes
        SELECT
            P.ID_ASTRO,
            COUNT(
                CASE
                    WHEN D.PLANETA IS NOT NULL AND (D.DATA_FIM IS NULL OR D.DATA_FIM > CURRENT_DATE) THEN 1
                    ELSE NULL
                END
            ) AS QTD_FACCOES
        BULK COLLECT INTO QTD_FACCOES
        FROM
            PLANETA P
        LEFT JOIN
            DOMINANCIA D ON D.PLANETA = P.ID_ASTRO
        LEFT JOIN
            NACAO_FACCAO NF ON D.NACAO = NF.NACAO
        LEFT JOIN
            FACCAO F ON NF.FACCAO = F.NOME
        GROUP BY 
            P.ID_ASTRO
        ORDER BY
            P.ID_ASTRO;
        
        -- Consulta das facções majoritárias
        FOR R IN (
            SELECT
                H.PLANETA,
                P.FACCAO,
                SUM(C.QTD_HABITANTES) AS TOTAL_HABITANTES
            FROM
                HABITACAO H
            JOIN
                COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
            JOIN
                PARTICIPA P ON C.ESPECIE = P.ESPECIE AND C.NOME = P.COMUNIDADE
            WHERE
                H.DATA_FIM IS NULL OR H.DATA_FIM > SYSDATE
            GROUP BY
                H.PLANETA, P.FACCAO
            ORDER BY
                H.PLANETA, P.FACCAO
        ) LOOP
            IF FACCOES_MAJORITARIAS.EXISTS(R.PLANETA) THEN
                IF R.TOTAL_HABITANTES > FACCOES_MAJORITARIAS(R.PLANETA).QTD_FACCAO_MAJORITARIA THEN
                    FACCOES_MAJORITARIAS(R.PLANETA) := REGFACCOESMAJORITARIAS(R.PLANETA, R.FACCAO, R.TOTAL_HABITANTES);
                END IF;
            ELSE
                FACCOES_MAJORITARIAS(R.PLANETA) := REGFACCOESMAJORITARIAS(R.PLANETA, R.FACCAO, R.TOTAL_HABITANTES);
            END IF;
        END LOOP;

        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'PLANETA;ULT_NACAO_DOMINANTE;DATA_INICIO_DOMINACAO;DATA_FIM_DOMINACAO;QTD_ESPECIES_ORIGINARIAS;QTD_ESPECIES_ATUAIS;QTD_COMUNIDADES_ATUAIS;QTD_HABITANTES_ATUAIS;QTD_FACCOES_ATUAIS;FACCAO_MAJORITARIA;QTD_FACCAO_MAJORITARIA' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;

        V_QTD_LINHAS := 0;
        V_NUMERO_LINHA := 0;
        FOR i IN 1..DATAS_DOMINACAO_ATUAL.COUNT LOOP
            IF V_QTD_LINHAS >= 100 THEN
                EXIT;
            END IF;
            IF DATAS_DOMINACAO_ATUAL(i).NOME_NACAO_DOMINANTE = V_ATRIBUTOS_LIDER.NACAO THEN
                V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
                IF V_NUMERO_LINHA < P_LINHA_INICIO THEN
                    CONTINUE;
                END IF;
                V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || DATAS_DOMINACAO_ATUAL(i).ID_PLANETA || ';' || DATAS_DOMINACAO_ATUAL(i).NOME_NACAO_DOMINANTE || ';' || DATAS_DOMINACAO_ATUAL(i).DATA_INICIO || ';' || DATAS_DOMINACAO_ATUAL(i).DATA_FIM || ';' || QTDS_ESP_COM_HAB(i).QTD_ESPECIES_ORIGINARIAS || ';' || QTDS_ESP_COM_HAB(i).QTD_ESPECIES_ATUAIS || ';' || QTDS_ESP_COM_HAB(i).QTD_COMUNIDADES_ATUAIS || ';' || QTDS_ESP_COM_HAB(i).QTD_HABITANTES_ATUAIS || ';' || QTD_FACCOES(i).QUANTIDADE || ';';
                IF FACCOES_MAJORITARIAS.EXISTS(DATAS_DOMINACAO_ATUAL(i).ID_PLANETA) THEN
                    V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || FACCOES_MAJORITARIAS(DATAS_DOMINACAO_ATUAL(i).ID_PLANETA).NOME_FACCAO_MAJORITARIA || ';' || FACCOES_MAJORITARIAS(DATAS_DOMINACAO_ATUAL(i).ID_PLANETA).QTD_FACCAO_MAJORITARIA || CHR(10);
                ELSE
                    V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || ';' || CHR(10);
                END IF;
                V_QTD_LINHAS := V_QTD_LINHAS + 1;
            END IF;
        END LOOP;

        RETURN V_SAIDA_RELATORIO;
    END GERAR_RELATORIO_PLANETAS_NACAO_COMANDANTE;

    FUNCTION GERAR_RELATORIO_PLANETAS_EXPANSAO_COMANDANTE(P_CPI_COMANDANTE LIDER.CPI%TYPE, P_DIST_MAX NUMBER, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_DIST_PLANETA NUMBER;
        V_QTD_LINHAS NUMBER;
        V_NUMERO_LINHA NUMBER;
        V_QTD_NACOES_DOMINANTES NUMBER;

        -- Tipo para registro de nação e datas de início e fim da última dominação
        TYPE REGDATASDOMINACAO IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            NOME_NACAO_DOMINANTE NACAO.NOME%TYPE,
            DATA_INICIO DATE,
            DATA_FIM DATE
        );

        -- Tipo para registro de quantidade de espécies, comunidades e habitantes
        TYPE REGQUANTIDADESESPCOMHAB IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            QTD_ESPECIES_ORIGINARIAS NUMBER,
            QTD_ESPECIES_ATUAIS NUMBER,
            QTD_COMUNIDADES_ATUAIS NUMBER,
            QTD_HABITANTES_ATUAIS NUMBER
        );

        -- Tipo genérico para registros com ID do planeta e quantidade
        TYPE REGIDQUANTIDADE IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            QUANTIDADE NUMBER
        );

        -- Tipo para registro da faccao majoritária
        TYPE REGFACCOESMAJORITARIAS IS RECORD (
            ID_PLANETA PLANETA.ID_ASTRO%TYPE,
            NOME_FACCAO_MAJORITARIA FACCAO.NOME%TYPE,
            QTD_FACCAO_MAJORITARIA NUMBER
        );

        -- Tipo para registro de planetas com potencial de dominação
        TYPE REGPLANETASEXPANSAO IS RECORD (
            PLANETA ORBITA_PLANETA.PLANETA%TYPE,
            DISTANCIA NUMBER
        );

        -- Tipos para tabelas associativas dos resultados
        TYPE TABDATASDOMINACAO IS TABLE OF REGDATASDOMINACAO;
        TYPE TABQUANTIDADESESPCOMHAB IS TABLE OF REGQUANTIDADESESPCOMHAB;
        TYPE TABIDQUANTIDADE IS TABLE OF REGIDQUANTIDADE;
        TYPE TABFACCOESMAJORITARIAS IS TABLE OF REGFACCOESMAJORITARIAS INDEX BY VARCHAR2(32);
        TYPE TABPLANETASEXPANSAO IS TABLE OF REGPLANETASEXPANSAO INDEX BY VARCHAR2(32);

        -- Arrays associativos para armazenar os resultados
        DATAS_DOMINACAO_ATUAL TABDATASDOMINACAO;
        QTDS_ESP_COM_HAB TABQUANTIDADESESPCOMHAB;
        QTD_FACCOES TABIDQUANTIDADE;
        FACCOES_MAJORITARIAS TABFACCOESMAJORITARIAS := TABFACCOESMAJORITARIAS();
        PLANETAS_EXPANSAO TABPLANETASEXPANSAO := TABPLANETASEXPANSAO();
    BEGIN
        -- Validação do comandante
        SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_COMANDANTE;
        IF V_ATRIBUTOS_LIDER.CPI IS NULL THEN
            RAISE_APPLICATION_ERROR(-20000, 'Comandante não encontrado.');
        END IF;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'COMANDANTE' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um comandante.');
        END IF;

        -- Consulta das datas de início e fim da última dominação
        SELECT
            P.ID_ASTRO AS ID_PLANETA,
            UD.NACAO AS NOME_NACAO_DOMINANTE,
            UD.DATA_INI,
            UD.DATA_FIM
        BULK COLLECT INTO DATAS_DOMINACAO_ATUAL
        FROM
            PLANETA P
        LEFT JOIN (
            SELECT D.NACAO, D.DATA_INI, D.DATA_FIM, D.PLANETA
            FROM DOMINANCIA D
            JOIN (
                SELECT PLANETA, MAX(DATA_INI) AS DATA_INI
                FROM DOMINANCIA
                GROUP BY PLANETA
            ) D2 ON D2.DATA_INI = D.DATA_INI AND D2.PLANETA = D.PLANETA
        ) UD ON UD.PLANETA = P.ID_ASTRO
        ORDER BY
            P.ID_ASTRO;

        -- Consulta das quantidades de espécies atuais, espécies originárias, comunidades e habitantes presentes
        SELECT
            P.ID_ASTRO AS ID_PLANETA,
            COUNT (
                DISTINCT EO.NOME
            ) AS QTD_ESPECIES_ORIGINARIAS,
            COUNT (
                DISTINCT
                CASE
                    WHEN H.PLANETA IS NOT NULL AND (H.DATA_FIM IS NULL OR H.DATA_FIM > CURRENT_DATE) THEN H.ESPECIE
                    ELSE NULL
                END
            ) AS QTD_ESPECIES_ATUAIS,
            COUNT (
                DISTINCT
                CASE
                    WHEN H.PLANETA IS NOT NULL AND (H.DATA_FIM IS NULL OR H.DATA_FIM > CURRENT_DATE) THEN H.COMUNIDADE
                    ELSE NULL
                END
            ) AS QTD_COMUNIDADES_ATUAIS,
            SUM(
                CASE
                    WHEN H.PLANETA IS NOT NULL AND (H.DATA_FIM IS NULL OR H.DATA_FIM > CURRENT_DATE) THEN C.QTD_HABITANTES
                    ELSE 0
                END
            ) AS QTD_HABITANTES_ATUAIS
        BULK COLLECT INTO QTDS_ESP_COM_HAB
        FROM
            PLANETA P
        LEFT JOIN
            HABITACAO H ON H.PLANETA = P.ID_ASTRO
        LEFT JOIN
            COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        LEFT JOIN
            ESPECIE EO ON EO.NOME = H.ESPECIE
        GROUP BY
            P.ID_ASTRO
        ORDER BY
            P.ID_ASTRO;

        -- Consulta da quantidade de facções presentes
        SELECT
            P.ID_ASTRO,
            COUNT(
                CASE
                    WHEN D.PLANETA IS NOT NULL AND (D.DATA_FIM IS NULL OR D.DATA_FIM > CURRENT_DATE) THEN 1
                    ELSE NULL
                END
            ) AS QTD_FACCOES
        BULK COLLECT INTO QTD_FACCOES
        FROM
            PLANETA P
        LEFT JOIN
            DOMINANCIA D ON D.PLANETA = P.ID_ASTRO
        LEFT JOIN
            NACAO_FACCAO NF ON D.NACAO = NF.NACAO
        LEFT JOIN
            FACCAO F ON NF.FACCAO = F.NOME
        GROUP BY 
            P.ID_ASTRO
        ORDER BY
            P.ID_ASTRO;
        
        -- Consulta das facções majoritárias
        FOR R IN (
            SELECT
                H.PLANETA,
                P.FACCAO,
                SUM(C.QTD_HABITANTES) AS TOTAL_HABITANTES
            FROM
                HABITACAO H
            JOIN
                COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
            JOIN
                PARTICIPA P ON C.ESPECIE = P.ESPECIE AND C.NOME = P.COMUNIDADE
            WHERE
                H.DATA_FIM IS NULL OR H.DATA_FIM > SYSDATE
            GROUP BY
                H.PLANETA, P.FACCAO
            ORDER BY
                H.PLANETA, P.FACCAO
        ) LOOP
            IF FACCOES_MAJORITARIAS.EXISTS(R.PLANETA) THEN
                IF R.TOTAL_HABITANTES > FACCOES_MAJORITARIAS(R.PLANETA).QTD_FACCAO_MAJORITARIA THEN
                    FACCOES_MAJORITARIAS(R.PLANETA) := REGFACCOESMAJORITARIAS(R.PLANETA, R.FACCAO, R.TOTAL_HABITANTES);
                END IF;
            ELSE
                FACCOES_MAJORITARIAS(R.PLANETA) := REGFACCOESMAJORITARIAS(R.PLANETA, R.FACCAO, R.TOTAL_HABITANTES);
            END IF;
        END LOOP;

        -- Consulta dos planetas com potencial de dominação
        SELECT
            COUNT(*)
        INTO
            V_QTD_NACOES_DOMINANTES
        FROM 
            DOMINANCIA D
        WHERE
            (D.DATA_FIM IS NULL OR D.DATA_FIM > CURRENT_DATE) AND D.NACAO = V_ATRIBUTOS_LIDER.NACAO;
        IF V_QTD_NACOES_DOMINANTES = 0 THEN
            FOR R IN (
                SELECT
                    OP.ESTRELA,
                    OP.PLANETA
                FROM
                    DOMINANCIA D
                JOIN
                    ORBITA_PLANETA OP ON OP.PLANETA = D.PLANETA
                JOIN
                    SISTEMA S ON S.ESTRELA = OP.ESTRELA  -- garantia de que a estrela pertence a um sistema
                WHERE
                    D.DATA_FIM IS NOT NULL AND D.DATA_FIM < CURRENT_DATE
            ) LOOP
                PLANETAS_EXPANSAO(R.PLANETA) := REGPLANETASEXPANSAO(R.PLANETA, 0);
            END LOOP;
        ELSE
            FOR R IN (
                SELECT
                    OP.ESTRELA,
                    OP.PLANETA
                FROM
                    DOMINANCIA D
                JOIN
                    ORBITA_PLANETA OP ON OP.PLANETA = D.PLANETA
                JOIN
                    SISTEMA S ON S.ESTRELA = OP.ESTRELA  -- garantia de que a estrela pertence a um sistema
                WHERE
                    D.DATA_FIM IS NOT NULL AND D.DATA_FIM < CURRENT_DATE
            ) LOOP
                SELECT 
                    MIN(PCT_UTILITARIO.CALCULAR_DISTANCIA_ESTRELAS(R.ESTRELA, S2.estrela))
                INTO
                    V_DIST_PLANETA
                FROM
                    SISTEMA S2
                JOIN
                    ORBITA_PLANETA OP2 ON OP2.ESTRELA = S2.ESTRELA
                JOIN
                    DOMINANCIA D2 ON OP2.PLANETA = D2.PLANETA
                WHERE 
                    D2.NACAO = V_ATRIBUTOS_LIDER.NACAO;
                IF V_DIST_PLANETA <= P_DIST_MAX THEN
                    IF PLANETAS_EXPANSAO.EXISTS(R.PLANETA) THEN
                        IF V_DIST_PLANETA < PLANETAS_EXPANSAO(R.PLANETA).DISTANCIA THEN
                            PLANETAS_EXPANSAO(R.PLANETA) := REGPLANETASEXPANSAO(R.PLANETA, V_DIST_PLANETA);
                        END IF;
                    ELSE
                        PLANETAS_EXPANSAO(R.PLANETA) := REGPLANETASEXPANSAO(R.PLANETA, V_DIST_PLANETA);
                    END IF;
                END IF;
            END LOOP;
        END IF;

        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'PLANETA;ULT_NACAO_DOMINANTE;DATA_INICIO_DOMINACAO;DATA_FIM_DOMINACAO;QTD_ESPECIES_ORIGINARIAS;QTD_ESPECIES_ATUAIS;QTD_COMUNIDADES_ATUAIS;QTD_HABITANTES_ATUAIS;QTD_FACCOES_ATUAIS;FACCAO_MAJORITARIA;QTD_FACCAO_MAJORITARIA;DISTANCIA' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;

        V_QTD_LINHAS := 0;
        V_NUMERO_LINHA := 0;
        FOR i IN 1..DATAS_DOMINACAO_ATUAL.COUNT LOOP
            IF V_QTD_LINHAS >= 100 THEN
                EXIT;
            END IF;

            IF PLANETAS_EXPANSAO.EXISTS(DATAS_DOMINACAO_ATUAL(i).ID_PLANETA) THEN
                IF DATAS_DOMINACAO_ATUAL(i).NOME_NACAO_DOMINANTE IS NOT NULL AND (DATAS_DOMINACAO_ATUAL(i).DATA_FIM IS NULL OR DATAS_DOMINACAO_ATUAL(i).DATA_FIM > CURRENT_DATE) THEN
                    CONTINUE;
                END IF;
                V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
                IF V_NUMERO_LINHA < P_LINHA_INICIO THEN
                    CONTINUE;
                END IF;
                V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || DATAS_DOMINACAO_ATUAL(i).ID_PLANETA || ';' || DATAS_DOMINACAO_ATUAL(i).NOME_NACAO_DOMINANTE || ';' || DATAS_DOMINACAO_ATUAL(i).DATA_INICIO || ';' || DATAS_DOMINACAO_ATUAL(i).DATA_FIM || ';' || QTDS_ESP_COM_HAB(i).QTD_ESPECIES_ORIGINARIAS || ';' || QTDS_ESP_COM_HAB(i).QTD_ESPECIES_ATUAIS || ';' || QTDS_ESP_COM_HAB(i).QTD_COMUNIDADES_ATUAIS || ';' || QTDS_ESP_COM_HAB(i).QTD_HABITANTES_ATUAIS || ';' || QTD_FACCOES(i).QUANTIDADE || ';';
                IF FACCOES_MAJORITARIAS.EXISTS(DATAS_DOMINACAO_ATUAL(i).ID_PLANETA) THEN
                    V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || FACCOES_MAJORITARIAS(DATAS_DOMINACAO_ATUAL(i).ID_PLANETA).NOME_FACCAO_MAJORITARIA || ';' || FACCOES_MAJORITARIAS(DATAS_DOMINACAO_ATUAL(i).ID_PLANETA).QTD_FACCAO_MAJORITARIA || ';';
                ELSE
                    V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || ';0;';
                END IF;
                V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || PLANETAS_EXPANSAO(DATAS_DOMINACAO_ATUAL(i).ID_PLANETA).DISTANCIA || CHR(10);
            END IF;
        END LOOP;

        RETURN V_SAIDA_RELATORIO;
    END GERAR_RELATORIO_PLANETAS_EXPANSAO_COMANDANTE;
END PCT_RELATORIO_COMANDANTE;
/
