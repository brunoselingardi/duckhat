USE duckhat;

ALTER TABLE recuperacao_senha_tokens
    ADD COLUMN tentativas_falhas INT NOT NULL DEFAULT 0 AFTER usado_em,
    ADD COLUMN bloqueado_ate DATETIME NULL AFTER tentativas_falhas;
