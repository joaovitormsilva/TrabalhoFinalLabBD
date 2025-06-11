INSERT INTO USERS (login, password, tipo, idoriginal)
SELECT 
    d.driverref || '_d' AS login,
    crypt(d.driverref, gen_salt('bf')) AS password,
    'Piloto' AS tipo,
    d.driverid AS idoriginal
FROM driver d
WHERE NOT EXISTS (
    SELECT 1
    FROM USERS u
    WHERE u.tipo = 'Piloto' AND u.idoriginal = d.driverid
);

