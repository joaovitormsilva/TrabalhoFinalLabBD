CREATE INDEX idx_results_driverid ON results (driverid);
COMMENT ON INDEX idx_results_driverid IS 'Otimiza consultas filtradas pelo ID do piloto na tabela de resultados.';

CREATE INDEX idx_results_driverid_points_raceid ON results (driverid, points, raceid);
COMMENT ON INDEX idx_results_driverid_points_raceid IS 'Otimiza o Relatório 6 (pontos por ano e corrida) para o piloto logado.';

CREATE INDEX idx_results_driverid_statusid ON results (driverid, statusid);
COMMENT ON INDEX idx_results_driverid_statusid IS 'Otimiza o Relatório 7 (resultados por status) para o piloto logado.';

CREATE INDEX idx_races_raceid_year_name ON races (raceid, year, name);
COMMENT ON INDEX idx_races_raceid_year_name IS 'Otimiza junções com a tabela de corridas nos relatórios de piloto.';

CREATE INDEX idx_status_statusid_status ON status (statusid, status);
COMMENT ON INDEX idx_status_statusid_status IS 'Otimiza junções com a tabela de status nos relatórios de piloto.';