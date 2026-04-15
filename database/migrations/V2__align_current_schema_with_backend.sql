USE duckhat;

ALTER TABLE usuarios
    MODIFY COLUMN nome VARCHAR(120) NOT NULL,
    MODIFY COLUMN email VARCHAR(150) NOT NULL,
    MODIFY COLUMN senha_hash VARCHAR(255) NOT NULL,
    MODIFY COLUMN telefone VARCHAR(20) NULL,
    MODIFY COLUMN tipo ENUM('CLIENTE', 'PRESTADOR') NOT NULL,
    MODIFY COLUMN criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE servicos
    MODIFY COLUMN prestador_id BIGINT NOT NULL,
    MODIFY COLUMN nome VARCHAR(120) NOT NULL,
    MODIFY COLUMN descricao TEXT NULL,
    MODIFY COLUMN duracao_min INT NOT NULL,
    MODIFY COLUMN preco DECIMAL(10,2) NOT NULL,
    MODIFY COLUMN ativo BOOLEAN NOT NULL DEFAULT TRUE,
    MODIFY COLUMN criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD CONSTRAINT chk_servicos_duracao_min CHECK (duracao_min > 0),
    ADD CONSTRAINT chk_servicos_preco CHECK (preco > 0);

ALTER TABLE disponibilidades
    MODIFY COLUMN prestador_id BIGINT NOT NULL,
    MODIFY COLUMN dia_semana TINYINT NOT NULL,
    MODIFY COLUMN hora_inicio TIME NOT NULL,
    MODIFY COLUMN hora_fim TIME NOT NULL,
    MODIFY COLUMN ativo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD CONSTRAINT chk_disponibilidades_dia_semana CHECK (dia_semana BETWEEN 1 AND 7),
    ADD CONSTRAINT chk_disponibilidades_intervalo CHECK (hora_fim > hora_inicio);

ALTER TABLE agendamentos
    MODIFY COLUMN cliente_id BIGINT NOT NULL,
    MODIFY COLUMN prestador_id BIGINT NOT NULL,
    MODIFY COLUMN servico_id BIGINT NOT NULL,
    MODIFY COLUMN inicio_at DATETIME NOT NULL,
    MODIFY COLUMN fim_at DATETIME NOT NULL,
    MODIFY COLUMN status ENUM('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'CONCLUIDO') NOT NULL DEFAULT 'PENDENTE',
    MODIFY COLUMN observacoes TEXT NULL,
    MODIFY COLUMN criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD CONSTRAINT chk_agendamentos_intervalo CHECK (fim_at > inicio_at);

ALTER TABLE avaliacoes
    MODIFY COLUMN agendamento_id BIGINT NOT NULL,
    MODIFY COLUMN nota INT NOT NULL,
    MODIFY COLUMN comentario TEXT NULL,
    MODIFY COLUMN criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD CONSTRAINT chk_avaliacoes_nota CHECK (nota BETWEEN 1 AND 5);

ALTER TABLE notificacao_eventos
    MODIFY COLUMN agendamento_id BIGINT NOT NULL,
    MODIFY COLUMN canal ENUM('APP', 'EMAIL', 'SMS') NOT NULL DEFAULT 'APP',
    MODIFY COLUMN agendado_para DATETIME NOT NULL,
    MODIFY COLUMN enviado_em DATETIME NULL,
    MODIFY COLUMN status ENUM('PENDENTE', 'ENVIADO', 'FALHA') NOT NULL DEFAULT 'PENDENTE';

CREATE INDEX idx_servicos_prestador_id ON servicos (prestador_id);
CREATE INDEX idx_servicos_ativo ON servicos (ativo);
CREATE INDEX idx_servicos_prestador_ativo ON servicos (prestador_id, ativo);

CREATE INDEX idx_disponibilidades_prestador_id ON disponibilidades (prestador_id);
CREATE INDEX idx_disponibilidades_ativo ON disponibilidades (ativo);
CREATE INDEX idx_disponibilidades_prestador_dia_ativo ON disponibilidades (prestador_id, dia_semana, ativo);

CREATE INDEX idx_agendamentos_cliente_id ON agendamentos (cliente_id);
CREATE INDEX idx_agendamentos_prestador_id ON agendamentos (prestador_id);
CREATE INDEX idx_agendamentos_servico_id ON agendamentos (servico_id);
CREATE INDEX idx_agendamentos_status ON agendamentos (status);
CREATE INDEX idx_agendamentos_cliente_status ON agendamentos (cliente_id, status);
CREATE INDEX idx_agendamentos_prestador_status_intervalo ON agendamentos (prestador_id, status, inicio_at, fim_at);

CREATE INDEX idx_notificacao_eventos_agendamento_id ON notificacao_eventos (agendamento_id);
CREATE INDEX idx_notificacao_eventos_status ON notificacao_eventos (status);
CREATE INDEX idx_notificacao_eventos_canal ON notificacao_eventos (canal);
