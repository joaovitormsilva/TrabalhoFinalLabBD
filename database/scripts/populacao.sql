-- Importação de dados do lado do servidor
COPY AIRPORTS
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\airports.csv'
DELIMITER ','
CSV HEADER;

COPY CIRCUITS
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\circuits.csv'
DELIMITER ','
CSV HEADER;

COPY CONSTRUCTORS
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\constructors.csv'
DELIMITER ','
CSV HEADER;

COPY COUNTRIES
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\countries.csv'
DELIMITER ','
CSV HEADER;

COPY DRIVER
FROM 'data/driver.csv'
DELIMITER ','
CSV HEADER;

COPY GEOCITIES15K
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\geocities15K.csv'
DELIMITER E'\t'
CSV HEADER;

COPY RACES
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\races.csv'
DELIMITER ','
CSV HEADER;

COPY SEASONS
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\seasons.csv'
DELIMITER ','
CSV HEADER;

COPY STATUS
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\status.csv'
DELIMITER ','
CSV HEADER;

COPY RESULTS
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\results.csv'
DELIMITER ','
CSV HEADER;

COPY QUALIFYING
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\qualifying.csv'
DELIMITER ','
CSV HEADER;

COPY LAPTIMES
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\laptimes.csv'
DELIMITER ','
CSV HEADER;

COPY DRIVERSTANDINGS
FROM 'C:\Program Files\PostgreSQL\17\data\imports\LabBD\driverstandings.csv'
DELIMITER ','
CSV HEADER;

