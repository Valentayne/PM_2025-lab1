CREATE TABLE IF NOT EXISTS nameinfo (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(50),
    probability FLOAT,
    countries TEXT,
    flags TEXT
);
