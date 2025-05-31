DECLARE
    TYPE user_name_table IS TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
    user_names user_name_table;
    i PLS_INTEGER;
BEGIN
    user_names(1) := 'a12547382';
    user_names(2) := 'a4818232';
    user_names(3) := 'a13750791';

    i := user_names.FIRST;
    WHILE i IS NOT NULL LOOP
        FOR r IN (SELECT table_name FROM user_tables) LOOP
            dbms_output.put_line('GRANT ALL ON ' || r.table_name || ' TO ' || user_names(i) || ';');
            EXECUTE IMMEDIATE 'GRANT ALL ON ' || r.table_name || ' TO ' || user_names(i);
        END LOOP;

        dbms_output.put_line('GRANT EXECUTE ON PCT_UTILITARIO TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_UTILITARIO TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_TESTE TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_TESTE TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_USER_TABLE TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_USER_TABLE TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_GERENCIAMENTO_CIENTISTA TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_GERENCIAMENTO_CIENTISTA TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_GERENCIAMENTO_COMANDANTE TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_GERENCIAMENTO_COMANDANTE TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_GERENCIAMENTO_LIDER TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_GERENCIAMENTO_LIDER TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_RELATORIO_COMANDANTE TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_RELATORIO_COMANDANTE TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_RELATORIO_LIDER TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_RELATORIO_LIDER TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_RELATORIO_COMANDANTE TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_RELATORIO_COMANDANTE TO ' || user_names(i);
    
        dbms_output.put_line('GRANT EXECUTE ON PCT_RELATORIO_CIENTISTA TO ' || user_names(i) || ';');
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON PCT_RELATORIO_CIENTISTA TO ' || user_names(i);
    
        i := user_names.NEXT(i);
    END LOOP;
END;