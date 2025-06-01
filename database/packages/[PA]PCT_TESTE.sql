CREATE OR REPLACE PACKAGE PCT_TESTE IS
    FUNCTION GERAR_RELATORIO(p_linha_inicio NUMBER) RETURN VARCHAR2;
END PCT_TESTE;
/

CREATE OR REPLACE PACKAGE BODY PCT_TESTE IS
     FUNCTION GERAR_RELATORIO(p_linha_inicio NUMBER) RETURN VARCHAR2 IS
         V_SAIDA_RELATORIO VARCHAR2(32767) := 'nacao;qtd_planetas;federacao' || CHR(10);
     BEGIN
         FOR R IN (
            SELECT * FROM
                (
                    -- Consulta com o conteúdo do relatório + coluna de numeração de linhas
                    SELECT NOME, QTD_PLANETAS, FEDERACAO, ROW_NUMBER() OVER (ORDER BY NOME) rnum
                    FROM NACAO
                )
                WHERE rnum BETWEEN p_linha_inicio AND (p_linha_inicio + 99)
            )
         LOOP
            V_SAIDA_RELATORIO := V_SAIDA_RELATORIO || R.NOME || ';' || R.QTD_PLANETAS || ';' || R.FEDERACAO || CHR(10);
         END LOOP;
         RETURN V_SAIDA_RELATORIO;
     END GERAR_RELATORIO;
END PCT_TESTE;
/
