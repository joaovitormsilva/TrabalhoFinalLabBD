-- Inserção das escuderias que já estão no sistema na tabela users
INSERT INTO USERS (login, password, tipo, idoriginal)
SELECT 
    c.constructorref || '_c' AS login,
    crypt(c.constructorref, gen_salt('bf')) AS password,
    'Escuderia' AS tipo,
    c.constructorid AS idoriginal
FROM constructors c
WHERE NOT EXISTS (
    SELECT 1
    FROM USERS u
    WHERE u.tipo = 'Escuderia' AND u.idoriginal = c.constructorid
);
