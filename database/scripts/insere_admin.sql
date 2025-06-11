
-- Inserção do usuário administrador
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO USERS (login, password, tipo, idoriginal)
VALUES ('admin', crypt('admin', gen_salt('bf')), 'Administrador', 0);
