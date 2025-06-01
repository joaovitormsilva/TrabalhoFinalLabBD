-- Criação da tabela de usuários
CREATE TABLE USERS (
    userid SERIAL PRIMARY KEY,
    login TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL, -- Senha armazenada de forma segura
    tipo TEXT CHECK (tipo IN ('Administrador', 'Escuderia', 'Piloto')) NOT NULL,
    idoriginal INTEGER NOT NULL -- Referência ao id_piloto ou id_escuderia dependendo do tipo
);
