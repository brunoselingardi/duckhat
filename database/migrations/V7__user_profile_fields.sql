USE duckhat;

ALTER TABLE usuarios
    ADD COLUMN data_nascimento DATE NULL AFTER responsavel_nome,
    ADD COLUMN endereco VARCHAR(255) NULL AFTER data_nascimento;
