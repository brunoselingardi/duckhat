USE duckhat;

ALTER TABLE usuarios
    ADD COLUMN cnpj VARCHAR(14) NULL AFTER telefone,
    ADD COLUMN responsavel_nome VARCHAR(120) NULL AFTER cnpj,
    ADD CONSTRAINT uq_usuarios_cnpj UNIQUE (cnpj);

CREATE TABLE recuperacao_senha_tokens (
    id BIGINT NOT NULL AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    codigo VARCHAR(12) NOT NULL,
    expira_em DATETIME NOT NULL,
    usado_em DATETIME NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_recuperacao_senha_tokens PRIMARY KEY (id),
    CONSTRAINT fk_recuperacao_senha_tokens_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_recuperacao_senha_tokens_usuario_codigo
    ON recuperacao_senha_tokens (usuario_id, codigo);
