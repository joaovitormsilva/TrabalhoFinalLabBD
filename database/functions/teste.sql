--SELECT * from users ORDER BY userid DESC;

--SELECT * from constructors ORDER BY constructorid DESC;

-- d.driverref, d.dateofbirth, d.nationality from driver d where d.driverid 

SELECT * FROM constructors;

SELECT 
    u.userid,
    u.login,
    qtd_pilotos_escuderia(REPLACE(u.login, '_c', '')) AS total_pilotos
FROM 
    users u;


SELECT * from users;

SELECT * from results;

SELECT * from driver;

SELECT * from constructors;

SELECT DISTINCT c.name, d.forename, d.dateofbirth, d.nationality
FROM driver d 
JOIN results r ON d.driverid = r.driverid
JOIN constructors c ON r.constructorid = c.constructorid
WHERE c.name='AlphaTauri';