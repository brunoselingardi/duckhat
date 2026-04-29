USE duckhat;

CREATE TABLE notificacao_preferencias (
    usuario_id BIGINT NOT NULL,
    agendamentos BOOLEAN NOT NULL DEFAULT TRUE,
    mensagens BOOLEAN NOT NULL DEFAULT TRUE,
    promocoes BOOLEAN NOT NULL DEFAULT TRUE,
    novidades BOOLEAN NOT NULL DEFAULT FALSE,
    resumo_email BOOLEAN NOT NULL DEFAULT TRUE,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_notificacao_preferencias PRIMARY KEY (usuario_id),
    CONSTRAINT fk_notificacao_preferencias_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE notificacao_eventos
    MODIFY COLUMN agendamento_id BIGINT NULL,
    ADD COLUMN usuario_id BIGINT NULL AFTER id,
    ADD COLUMN chat_conversa_id BIGINT NULL AFTER agendamento_id,
    ADD COLUMN tipo ENUM('AGENDAMENTO', 'MENSAGEM', 'PROMOCAO', 'SISTEMA') NOT NULL DEFAULT 'AGENDAMENTO' AFTER chat_conversa_id,
    ADD COLUMN titulo VARCHAR(120) NULL AFTER canal,
    ADD COLUMN mensagem VARCHAR(500) NULL AFTER titulo,
    ADD COLUMN criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER agendado_para,
    ADD COLUMN lido_em DATETIME NULL AFTER enviado_em;

UPDATE notificacao_eventos ne
JOIN agendamentos a ON a.id = ne.agendamento_id
SET
    ne.usuario_id = a.cliente_id,
    ne.tipo = 'AGENDAMENTO',
    ne.titulo = 'Lembrete de agendamento',
    ne.mensagem = CONCAT('Voce tem um agendamento em ', DATE_FORMAT(a.inicio_at, '%d/%m as %H:%i'), '.')
WHERE ne.usuario_id IS NULL;

ALTER TABLE notificacao_eventos
    MODIFY COLUMN usuario_id BIGINT NOT NULL,
    MODIFY COLUMN titulo VARCHAR(120) NOT NULL,
    MODIFY COLUMN mensagem VARCHAR(500) NOT NULL,
    ADD CONSTRAINT fk_notificacao_eventos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_notificacao_eventos_chat_conversa FOREIGN KEY (chat_conversa_id) REFERENCES chat_conversas(id) ON DELETE CASCADE;

CREATE INDEX idx_notificacao_eventos_usuario_criado ON notificacao_eventos (usuario_id, criado_em, id);
CREATE INDEX idx_notificacao_eventos_usuario_lido ON notificacao_eventos (usuario_id, lido_em);
CREATE INDEX idx_notificacao_eventos_chat_conversa_id ON notificacao_eventos (chat_conversa_id);

INSERT INTO notificacao_preferencias (
    usuario_id,
    agendamentos,
    mensagens,
    promocoes,
    novidades,
    resumo_email
)
SELECT id, TRUE, TRUE, TRUE, FALSE, TRUE
FROM usuarios;
