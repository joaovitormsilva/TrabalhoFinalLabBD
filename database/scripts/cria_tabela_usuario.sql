CREATE TABLE USERS (
    userid SERIAL PRIMARY KEY,
    login TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL, 
    tipo TEXT CHECK (tipo IN ('Administrador', 'Escuderia', 'Piloto')) NOT NULL,
    idoriginal INTEGER NOT NULL 
);
