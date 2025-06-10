
-- Adicione uma corrida em 2025


INSERT INTO races (raceid, year, round, circuitid, name, date)
VALUES (9999, 2025, 1, 1, 'Corrida Teste', '2025-05-01');

-- Adicione um resultado com pontos para um piloto e escuderia
INSERT INTO results (resultid, raceid, driverid, constructorid, grid, position, points)
VALUES (40000, 9999, 1, 1, 1, 1, 25.0);

