-- Inserção do usuário administrador
INSERT INTO USERS (login, password, tipo, idoriginal)
VALUES ('admin', crypt('admin', gen_salt('bf')), 'Administrador', 0);
