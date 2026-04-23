USE duckhat;

CREATE TABLE IF NOT EXISTS chat_conversas (
    id BIGINT NOT NULL AUTO_INCREMENT,
    cliente_id BIGINT NOT NULL,
    prestador_id BIGINT NOT NULL,
    ultima_mensagem_em DATETIME NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_chat_conversas PRIMARY KEY (id),
    CONSTRAINT uq_chat_conversas_cliente_prestador UNIQUE (cliente_id, prestador_id),
    CONSTRAINT fk_chat_conversas_cliente FOREIGN KEY (cliente_id) REFERENCES usuarios(id),
    CONSTRAINT fk_chat_conversas_prestador FOREIGN KEY (prestador_id) REFERENCES usuarios(id),
    CONSTRAINT chk_chat_conversas_participantes CHECK (cliente_id <> prestador_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS chat_mensagens (
    id BIGINT NOT NULL AUTO_INCREMENT,
    conversa_id BIGINT NOT NULL,
    remetente_id BIGINT NOT NULL,
    conteudo TEXT NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_chat_mensagens PRIMARY KEY (id),
    CONSTRAINT fk_chat_mensagens_conversa FOREIGN KEY (conversa_id) REFERENCES chat_conversas(id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_mensagens_remetente FOREIGN KEY (remetente_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_chat_conversas_cliente_ultima ON chat_conversas (cliente_id, ultima_mensagem_em);
CREATE INDEX idx_chat_conversas_prestador_ultima ON chat_conversas (prestador_id, ultima_mensagem_em);
CREATE INDEX idx_chat_mensagens_conversa_criado ON chat_mensagens (conversa_id, criado_em, id);
CREATE INDEX idx_chat_mensagens_criado ON chat_mensagens (criado_em);
