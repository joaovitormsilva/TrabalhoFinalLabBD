-- Declaração de pacote de relatório para cientistas
CREATE OR REPLACE PACKAGE PCT_RELATORIO_CIENTISTA AS
    FUNCTION GERAR_RELATORIO_INFOS_ESTRELAS(P_CPI_CIENTISTA LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
    FUNCTION GERAR_RELATORIO_INFOS_PLANETAS(P_CPI_CIENTISTA LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
END PCT_RELATORIO_CIENTISTA;
/




-- Corpo do pacote de relatório para cientistas
CREATE OR REPLACE PACKAGE BODY PCT_RELATORIO_CIENTISTA AS
    
    FUNCTION GERAR_RELATORIO_INFOS_ESTRELAS(P_CPI_CIENTISTA LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_NUMERO_LINHA NUMBER := 0;
        V_QTD_LINHAS NUMBER := 0;
        V_BUFFER VARCHAR2(32767);
        V_LIMITE_PAGINA CONSTANT NUMBER := 100;  -- Tamanho máximo de linhas por página

    BEGIN
    
        -- Validação do cientista
        BEGIN
            SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_CIENTISTA;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Cientista não encontrado.');
        END;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'CIENTISTA' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um cientista.');
        END IF;
        
        --cabeçalho do relatório
        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'SISTEMA;ID_ESTRELA;NOME_ESTRELA;CLASSIFICACAO;MASSA;COORD_X;COORD_Y;COORD_Z;QTD_PLANETAS_ORBITANTES;ORBITA_ESTRELA' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;

        -- Query para buscar os dados
        FOR R IN (
            SELECT 
                S.NOME AS SISTEMA,
                E.ID_ESTRELA AS ID_ESTRELA,
                E.NOME AS NOME_ESTRELA,
                E.CLASSIFICACAO AS CLASSIFICACAO,
                E.MASSA AS MASSA,
                E.X AS COORD_X,
                E.Y AS COORD_Y,
                E.Z AS COORD_Z,
                COUNT(OP.PLANETA) AS QTD_PLANETAS_ORBITANTES,
                OE.ORBITADA AS ORBITA_ESTRELA
            FROM
                SISTEMA S 
                RIGHT JOIN ESTRELA E ON S.ESTRELA = E.ID_ESTRELA
                LEFT JOIN ORBITA_PLANETA OP ON OP.ESTRELA = E.ID_ESTRELA
                LEFT JOIN ORBITA_ESTRELA OE ON OE.ORBITANTE = E.ID_ESTRELA
            GROUP BY S.NOME, E.ID_ESTRELA, E.NOME, E.CLASSIFICACAO, E.MASSA, E.X, E.Y, E.Z, OE.ORBITADA
            ORDER BY S.NOME, E.ID_ESTRELA  -- Garantir ordenação consistente para a paginação
        ) LOOP
            V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
            
            -- Pula as linhas até atingir o início da página desejada
            IF V_NUMERO_LINHA <= P_LINHA_INICIO THEN
                CONTINUE;
            END IF;
            
            -- Constrói a linha do relatório
            V_BUFFER := R.SISTEMA || ';' || R.ID_ESTRELA || ';' || R.NOME_ESTRELA || ';' || R.CLASSIFICACAO || ';' || R.MASSA ||  ';' || R.COORD_X || ';' || R.COORD_Y || ';' || R.COORD_Z || ';' || R.QTD_PLANETAS_ORBITANTES || ';' || R.ORBITA_ESTRELA || CHR(10);

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
    END GERAR_RELATORIO_INFOS_ESTRELAS;


    FUNCTION GERAR_RELATORIO_INFOS_PLANETAS(P_CPI_CIENTISTA LIDER.CPI%TYPE, P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_NUMERO_LINHA NUMBER := 0;
        V_QTD_LINHAS NUMBER := 0;
        V_BUFFER VARCHAR2(32767);
        V_LIMITE_PAGINA CONSTANT NUMBER := 100;  -- Tamanho máximo de linhas por página

    BEGIN
    
        -- Validação do cientista
        BEGIN
            SELECT * INTO V_ATRIBUTOS_LIDER FROM LIDER WHERE CPI = P_CPI_CIENTISTA;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Cientista não encontrado.');
        END;

        IF TRIM(V_ATRIBUTOS_LIDER.CARGO) <> 'CIENTISTA' THEN
            RAISE_APPLICATION_ERROR(-20000, 'O líder informado não é um cientista.');
        END IF;
        
        --cabeçalho do relatório
        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'PLANETA;MASSA;RAIO;CLASSIFICACAO;ESTRELA_ORBITADA;DIST_MIN_ORBITA;DIST_MAX_ORBITA;PERIODO_ORBITA' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;

        -- Query para buscar os dados
        FOR R IN (
            SELECT 
                P.ID_ASTRO AS PLANETA,
                P.MASSA AS MASSA,
                P.RAIO AS RAIO,
                P.CLASSIFICACAO AS CLASSIFICACAO,
                OP.ESTRELA AS ESTRELA_ORBITADA,
                OP.DIST_MIN AS DIST_MIN_ORBITA,
                OP.DIST_MAX AS DIST_MAX_ORBTIA,
                OP.PERIODO AS PERIODO_ORBITA
            FROM
                PLANETA P 
                LEFT JOIN ORBITA_PLANETA OP ON OP.PLANETA = P.ID_ASTRO
            ORDER BY P.ID_ASTRO 
        ) LOOP
            V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
            
            -- Pula as linhas até atingir o início da página desejada
            IF V_NUMERO_LINHA <= P_LINHA_INICIO THEN
                CONTINUE;
            END IF;
            
            -- Constrói a linha do relatório
            V_BUFFER := R.PLANETA || ';' || R.MASSA || ';' || R.RAIO || ';' || R.CLASSIFICACAO || ';' || R.ESTRELA_ORBITADA ||  ';' || R.DIST_MIN_ORBITA || ';' || R.DIST_MAX_ORBTIA || ';' || R.PERIODO_ORBITA || CHR(10);

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
    END GERAR_RELATORIO_INFOS_PLANETAS;

END PCT_RELATORIO_CIENTISTA;
/




/* CHAMADA DA FUNCAO (EXEMPLO)

DECLARE
    V_CPI_CIENTISTA LIDER.CPI%TYPE := '111.111.111-11';  -- Substitua pelo CPI do cientista desejado
    V_LINHA_INICIO NUMBER := 1;  -- Número da linha de início para paginação

    V_RELATORIO VARCHAR2(32767);
BEGIN
    -- Chamada da função do pacote PCT_RELATORIO_CIENTISTA
    V_RELATORIO := PCT_RELATORIO_CIENTISTA.GERAR_RELATORIO_INFOS_PLANETAS(V_CPI_CIENTISTA, V_LINHA_INICIO);
    
    -- Exibir o relatório gerado (pode ser substituído por qualquer uso desejado, como salvar em arquivo ou mostrar em um aplicativo)
    DBMS_OUTPUT.PUT_LINE(V_RELATORIO);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao gerar relatório: ' || SQLERRM);
END;

/


*/
