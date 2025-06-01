CREATE OR REPLACE PACKAGE PCT_RELATORIO_OFICIAL IS

    FUNCTION GERAR_RELATORIO_PLANETA(P_CPI_OFICIAL LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
    FUNCTION GERAR_RELATORIO_SISTEMA(P_CPI_OFICIAL LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
    FUNCTION GERAR_RELATORIO_ESPECIE(P_CPI_OFICIAL LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
    FUNCTION GERAR_RELATORIO_FACCAO(P_CPI_OFICIAL LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;

END PCT_RELATORIO_OFICIAL;
/


CREATE OR REPLACE PACKAGE BODY PCT_RELATORIO_OFICIAL IS

    FUNCTION GERAR_RELATORIO_PLANETA(P_CPI_OFICIAL LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_NUMERO_LINHA NUMBER := 0;
        V_QTD_LINHAS NUMBER := 0;
        V_BUFFER VARCHAR2(32767);
        V_LIMITE_PAGINA CONSTANT NUMBER := 100;  -- Tamanho máximo de linhas por página
    BEGIN
    
        -- Validacao do oficial
        BEGIN
            SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_OFICIAL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Oficial não encontrado.');
        END;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'OFICIAL' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um oficial.');
        END IF;
        
        
        --cabeçalho do relatório
        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'PLANETA;QTD_COMUNIDADES_ATUAIS;QTD_ESPECIES_ATUAIS;HABITANTES' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;
        
            FOR R IN (

                SELECT
                    D.PLANETA AS PLANETA,
                    COUNT(DISTINCT H.COMUNIDADE) AS QTD_COMUNIDADES_ATUAIS,
                    COUNT(DISTINCT H.ESPECIE) AS QTD_ESPECIES_ATUAIS,
                    SUM(C.QTD_HABITANTES) AS HABITANTES
                FROM
                    DOMINANCIA D
                    LEFT JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                    JOIN COMUNIDADE C ON C.ESPECIE = H.ESPECIE AND C.NOME = H.COMUNIDADE
                WHERE D.NACAO = (SELECT NACAO FROM LIDER WHERE CPI = P_CPI_OFICIAL) AND H.DATA_FIM IS NOT NULL
                GROUP BY D.PLANETA
                ORDER BY PLANETA
                
            ) LOOP
            
               V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
            
            -- Pula as linhas até atingir o início da página desejada
            IF V_NUMERO_LINHA <= P_LINHA_INICIO THEN
                CONTINUE;
            END IF;
               
             -- Constrói a linha do relatório
            V_BUFFER := R.PLANETA || ';' || R.QTD_COMUNIDADES_ATUAIS || ';' || R.QTD_ESPECIES_ATUAIS || ';' || R.HABITANTES || CHR(10);
            
            -- Verifica se excedeu o limite da página
            IF V_QTD_LINHAS >= V_LIMITE_PAGINA THEN
                EXIT; -- Sai do loop se atingir o limite da página
            END IF;

            -- Adiciona a linha ao relatório
            V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || V_BUFFER;
            V_QTD_LINHAS := V_QTD_LINHAS + 1;
            
            END LOOP;
            
            RETURN V_SAIDA_RELATORIO;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Nenhum dado encontrado';
        WHEN OTHERS THEN
            RETURN 'Erro ao gerar relatório: ' || SQLERRM;

    END GERAR_RELATORIO_PLANETA;
    
    FUNCTION GERAR_RELATORIO_SISTEMA(P_CPI_OFICIAL LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_NUMERO_LINHA NUMBER := 0;
        V_QTD_LINHAS NUMBER := 0;
        V_BUFFER VARCHAR2(32767);
        V_LIMITE_PAGINA CONSTANT NUMBER := 100;  -- Tamanho máximo de linhas por página
    BEGIN
    
        -- Validacao do oficial
        BEGIN
            SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_OFICIAL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Oficial não encontrado.');
        END;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'OFICIAL' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um oficial.');
        END IF;
        
        
        --cabeçalho do relatório
        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'SISTEMA;PLANETAS_DOMINADOS;HABITANTES' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;
        
            FOR R IN (

                SELECT
                    SIST.SISTEMA AS SISTEMA,
                    COUNT(DISTINCT H.PLANETA) AS PLANETAS_DOMINADOS,
                    SUM(C.QTD_HABITANTES) AS HABITANTES
                FROM 
                    DOMINANCIA D
                    LEFT JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                    JOIN COMUNIDADE C ON C.ESPECIE = H.ESPECIE AND C.NOME = H.COMUNIDADE
                    JOIN (
                        SELECT
                            S.NOME AS SISTEMA,
                            OP.PLANETA AS PLANETA
                        FROM
                            SISTEMA S
                            JOIN ORBITA_PLANETA OP ON OP.ESTRELA = S.ESTRELA
                    ) SIST ON SIST.PLANETA = H.PLANETA
                WHERE 
                    D.NACAO = (SELECT NACAO FROM LIDER WHERE CPI = P_CPI_OFICIAL) 
                    
                GROUP BY 
                    SIST.SISTEMA
                ORDER BY 
                    SIST.SISTEMA
                
            ) LOOP
            
               V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
            
            -- Pula as linhas até atingir o início da página desejada
            IF V_NUMERO_LINHA <= P_LINHA_INICIO THEN
                CONTINUE;
            END IF;
               
             -- Constrói a linha do relatório
            V_BUFFER := R.SISTEMA || ';' || R.PLANETAS_DOMINADOS || ';' || R.HABITANTES || CHR(10);
            
            -- Verifica se excedeu o limite da página
            IF V_QTD_LINHAS >= V_LIMITE_PAGINA THEN
                EXIT; -- Sai do loop se atingir o limite da página
            END IF;

            -- Adiciona a linha ao relatório
            V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || V_BUFFER;
            V_QTD_LINHAS := V_QTD_LINHAS + 1;
            
            END LOOP;
            
            RETURN V_SAIDA_RELATORIO;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Nenhum dado encontrado';
        WHEN OTHERS THEN
            RETURN 'Erro ao gerar relatório: ' || SQLERRM;

    END GERAR_RELATORIO_SISTEMA;
    
    FUNCTION GERAR_RELATORIO_ESPECIE(P_CPI_OFICIAL LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_NUMERO_LINHA NUMBER := 0;
        V_QTD_LINHAS NUMBER := 0;
        V_BUFFER VARCHAR2(32767);
        V_LIMITE_PAGINA CONSTANT NUMBER := 100;  -- Tamanho máximo de linhas por página
    BEGIN
    
        -- Validacao do oficial
        BEGIN
            SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_OFICIAL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Oficial não encontrado.');
        END;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'OFICIAL' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um oficial.');
        END IF;
        
        
        --cabeçalho do relatório
        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'ESPECIE;PLANETA_ORIGEM;INTELIGENTE;QTD_PLANETAS_PRESENTE;QTD_COMUNIDADES;POPULACAO_TOTAL' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;
        
            FOR R IN (

                SELECT
                    E.NOME AS ESPECIE,
                    E.PLANETA_OR AS PLANETA_ORIGEM,
                    E.INTELIGENTE AS INTELIGENTE,
                    COUNT(DISTINCT H.PLANETA) AS QTD_PLANETAS_PRESENTE,
                    COUNT(DISTINCT H.COMUNIDADE) AS QTD_COMUNIDADES,
                    SUM(C.QTD_HABITANTES) AS POPULACAO_TOTAL
                FROM
                    DOMINANCIA D
                    LEFT JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                    JOIN COMUNIDADE C ON C.ESPECIE = H.ESPECIE AND C.NOME = H.COMUNIDADE
                    JOIN ESPECIE E ON E.NOME = C.ESPECIE
                WHERE D.NACAO = (SELECT NACAO FROM LIDER WHERE CPI = P_CPI_OFICIAL)
                GROUP BY E.NOME, E.PLANETA_OR, E.INTELIGENTE
                ORDER BY ESPECIE
                
            ) LOOP
            
               V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
            
            -- Pula as linhas até atingir o início da página desejada
            IF V_NUMERO_LINHA <= P_LINHA_INICIO THEN
                CONTINUE;
            END IF;
               
             -- Constrói a linha do relatório
            V_BUFFER := R.ESPECIE || ';' || R.PLANETA_ORIGEM || ';' || R.INTELIGENTE || ';' || R.QTD_PLANETAS_PRESENTE || ';' || R.QTD_COMUNIDADES || ';' || R.POPULACAO_TOTAL || CHR(10);
            
            -- Verifica se excedeu o limite da página
            IF V_QTD_LINHAS >= V_LIMITE_PAGINA THEN
                EXIT; -- Sai do loop se atingir o limite da página
            END IF;

            -- Adiciona a linha ao relatório
            V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || V_BUFFER;
            V_QTD_LINHAS := V_QTD_LINHAS + 1;
            
            END LOOP;
            
            RETURN V_SAIDA_RELATORIO;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Nenhum dado encontrado';
        WHEN OTHERS THEN
            RETURN 'Erro ao gerar relatório: ' || SQLERRM;

    END GERAR_RELATORIO_ESPECIE;
    
    FUNCTION GERAR_RELATORIO_FACCAO(P_CPI_OFICIAL LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_NUMERO_LINHA NUMBER := 0;
        V_QTD_LINHAS NUMBER := 0;
        V_BUFFER VARCHAR2(32767);
        V_LIMITE_PAGINA CONSTANT NUMBER := 100;  -- Tamanho máximo de linhas por página
    BEGIN
    
        -- Validacao do oficial
        BEGIN
            SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_OFICIAL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Oficial não encontrado.');
        END;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'OFICIAL' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um oficial.');
        END IF;
        
        
        --cabeçalho do relatório
        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'FACCAO;QTD_COMUNIDADES_ASSOCIADAS;HABITANTES_FACCAO' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;
        
            FOR R IN (

                SELECT
                    P.FACCAO AS FACCAO,
                    COUNT(DISTINCT C.NOME) AS QTD_COMUNIDADES_ASSOCIADAS,
                    SUM(C.QTD_HABITANTES) AS HABITANTES_FACCAO

                FROM
                    NACAO_FACCAO NF
                    JOIN PARTICIPA P ON P.FACCAO = NF.FACCAO
                    JOIN COMUNIDADE C ON C.ESPECIE = P.ESPECIE AND C.NOME = P.COMUNIDADE
                WHERE NF.NACAO = (SELECT NACAO FROM LIDER WHERE CPI = P_CPI_OFICIAL)
                GROUP BY P.FACCAO
                
            ) LOOP
            
               V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
            
            -- Pula as linhas até atingir o início da página desejada
            IF V_NUMERO_LINHA <= P_LINHA_INICIO THEN
                CONTINUE;
            END IF;
               
             -- Constrói a linha do relatório
            V_BUFFER := R.FACCAO || ';' || R.QTD_COMUNIDADES_ASSOCIADAS || ';' || R.HABITANTES_FACCAO  || CHR(10);
            
            -- Verifica se excedeu o limite da página
            IF V_QTD_LINHAS >= V_LIMITE_PAGINA THEN
                EXIT; -- Sai do loop se atingir o limite da página
            END IF;

            -- Adiciona a linha ao relatório
            V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || V_BUFFER;
            V_QTD_LINHAS := V_QTD_LINHAS + 1;
            
            END LOOP;
            
            RETURN V_SAIDA_RELATORIO;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Nenhum dado encontrado';
        WHEN OTHERS THEN
            RETURN 'Erro ao gerar relatório: ' || SQLERRM;

    END GERAR_RELATORIO_FACCAO;
    
    
END PCT_RELATORIO_OFICIAL;
/
