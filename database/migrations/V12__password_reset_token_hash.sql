USE duckhat;

ALTER TABLE recuperacao_senha_tokens
    MODIFY COLUMN codigo VARCHAR(255) NOT NULL;
