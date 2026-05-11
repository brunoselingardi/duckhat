USE duckhat;

ALTER TABLE estabelecimentos
    ADD COLUMN categoria VARCHAR(60) NULL AFTER endereco;

UPDATE estabelecimentos
SET categoria = CASE
    WHEN LOWER(nome) LIKE '%barber%' OR LOWER(nome) LIKE '%barbear%' THEN 'barbearia'
    WHEN LOWER(nome) LIKE '%encan%' OR LOWER(nome) LIKE '%plumb%' THEN 'encanador'
    ELSE 'barbearia'
END
WHERE categoria IS NULL;
