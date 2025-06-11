CREATE TABLE teste_login (
    id SERIAL PRIMARY KEY,
    login TEXT NOT NULL UNIQUE,
    senha TEXT NOT NULL
);

INSERT INTO teste_login (login, senha) VALUES
('usuario1', 'senha1'),
('usuario2', 'senha2');
