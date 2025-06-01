-- Criação do trigger
CREATE TRIGGER trigger_escuderia_insert
AFTER INSERT ON constructors
FOR EACH ROW
EXECUTE FUNCTION insere_usuario_escuderia();

