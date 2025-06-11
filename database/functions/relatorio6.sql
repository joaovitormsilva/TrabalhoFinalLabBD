CREATE OR REPLACE FUNCTION get_pilot_points_by_year_and_race()
RETURNS TABLE (
    ano INT,
    nome_corrida VARCHAR,
    pontos NUMERIC
)
AS $$
DECLARE
    piloto_id INT := get_logged_in_pilot_id();
BEGIN
    RETURN QUERY
    SELECT
        r.year AS ano,              
        r.name AS nome_corrida,      
        res.points AS pontos         
    FROM
        results res                  
    JOIN
        races r ON res.raceid = r.raceid 
    WHERE
        res.driverid = piloto_id     
        AND res.points > 0;          
    ORDER BY
        r.year DESC,                 
        r.name;                      
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_pilot_points_by_year_and_race() IS 'Gera o Relatório 6, listando os pontos obtidos pelo piloto logado por ano e por corrida.';