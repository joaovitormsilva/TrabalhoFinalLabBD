CREATE TRIGGER trigger_piloto_insert
AFTER INSERT ON driver
FOR EACH ROW
EXECUTE FUNCTION insere_usuario_piloto();

