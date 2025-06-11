--SELECT * from users ORDER BY userid DESC;

--SELECT * from constructors ORDER BY constructorid DESC;

-- d.driverref, d.dateofbirth, d.nationality from driver d where d.driverid 

SELECT * from status;
/*


SELECT 
    u.userid,
    u.login,
    qtd_pilotos_escuderia(REPLACE(u.login, '_c', '')) AS total_pilotos
FROM 
    users u;


SELECT * FROM constructors WHERE name = 'AlphaTauri';

SELECT * FROM driver WHERE forename = 'Yuki';

SELECT * from users;

SELECT * from results;

SELECT * from driver;

SELECT * from constructors;

SELECT count(*) as Vitorias FROM results r
JOIN constructors  c
ON r.constructorid = c.constructorid
WHERE r.rank='1' and c.name='McLaren';



SELECT DISTINCT c.name, d.forename, d.dateofbirth, d.nationality
FROM driver d 
JOIN results r ON d.driverid = r.driverid
JOIN constructors c ON r.constructorid = c.constructorid
WHERE c.name='McLaren';


SELECT min(year), max(year) FROM races ra
JOIN results re
ON ra.raceid = re.raceid
JOIN constructors c
ON re.constructorid = c.constructorid
WHERE c.name='McLaren';

*/