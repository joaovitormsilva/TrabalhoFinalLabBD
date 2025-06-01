CREATE OR REPLACE PACKAGE PCT_RELATORIO_LIDER IS
    FUNCTION GERAR_RELATORIO_COMUNIDADES(V_LIDER LIDER.CPI%TYPE,  P_LINHA_INICIO NUMBER) RETURN VARCHAR2;
END PCT_RELATORIO_LIDER;
/

CREATE OR REPLACE PACKAGE BODY PCT_RELATORIO_LIDER IS
    FUNCTION GERAR_RELATORIO_COMUNIDADES(V_LIDER LIDER.CPI%TYPE,  P_LINHA_INICIO NUMBER) RETURN VARCHAR2 IS
        V_SAIDA_RELATORIO VARCHAR2(32767);
        V_ATRIBUTOS_LIDER LIDER%ROWTYPE;
        V_NUMERO_LINHA NUMBER := 0;
        V_QTD_LINHAS NUMBER := 0;
        V_BUFFER VARCHAR2(32767);
        V_LIMITE_PAGINA CONSTANT NUMBER := 100;  -- Tamanho máximo de linhas por página
    BEGIN
    
        
        --cabeçalho do relatório
        IF P_LINHA_INICIO = 1 THEN
            V_SAIDA_RELATORIO := 'FACCAO;NACAO;COMUNIDADE;ESPECIE;PLANETA_HABITADO;SISTEMA' || CHR(10);
        ELSE
            V_SAIDA_RELATORIO := '';
        END IF;
    
        FOR R IN (
            SELECT 
                NF.FACCAO AS FACCAO,
                NF.NACAO AS NACAO,
                C.NOME AS COMUNIDADE,
                C.ESPECIE AS ESPECIE,
                H.PLANETA AS PLANETA_HABITADO,
                S.NOME AS SISTEMA
                
            FROM 
                NACAO_FACCAO NF 
                JOIN FACCAO F ON NF.FACCAO = F.NOME
                JOIN PARTICIPA P ON F.NOME = P.FACCAO
                JOIN COMUNIDADE C ON P.COMUNIDADE = C.NOME AND P.ESPECIE = C.ESPECIE
                JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                JOIN ORBITA_PLANETA OP ON OP.PLANETA = H.PLANETA
                JOIN SISTEMA S ON S.ESTRELA = OP.ESTRELA
            WHERE 
                F.LIDER = V_LIDER
            GROUP BY 
                NF.FACCAO, NF.NACAO, C.NOME,  C.ESPECIE, H.PLANETA, S.NOME 
        ) 
        LOOP
            V_NUMERO_LINHA := V_NUMERO_LINHA + 1;
            
            -- Pula as linhas até atingir o início da página desejada
            IF V_NUMERO_LINHA <= P_LINHA_INICIO THEN
                CONTINUE;
            END IF;
            
            -- Constrói a linha do relatório
            V_BUFFER := R.FACCAO || ';' || R.NACAO || ';' || R.COMUNIDADE || ';' || R.ESPECIE || ';' || R.PLANETA_HABITADO ||  ';' || R.SISTEMA || CHR(10);

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
    END GERAR_RELATORIO_COMUNIDADES;
    
END PCT_RELATORIO_LIDER;


/*
-- Bloco anônimo PL/SQL para chamar a função GERAR_RELATORIO_COMUNIDADES

DECLARE
    V_LIDER LIDER.CPI%TYPE := '111.111.111-11';  -- Defina o valor adequado para o CPI do líder
    P_LINHA_INICIO NUMBER := 1;  -- Defina o número da linha de início adequado

    V_RELATORIO VARCHAR2(32767);
BEGIN
    -- Chama a função para gerar o relatório
    V_RELATORIO := PCT_RELATORIO_LIDER.GERAR_RELATORIO_COMUNIDADES(V_LIDER, P_LINHA_INICIO);

    -- Exibe o relatório gerado
    DBMS_OUTPUT.PUT_LINE('Relatório de Comunidades:');
    DBMS_OUTPUT.PUT_LINE(V_RELATORIO);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao executar o relatório: ' || SQLERRM);
END;
/



*/
