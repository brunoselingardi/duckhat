USE duckhat;

CREATE TABLE usuarios (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20) NULL,
    cnpj VARCHAR(14) NULL,
    responsavel_nome VARCHAR(120) NULL,
    data_nascimento DATE NULL,
    endereco VARCHAR(255) NULL,
    tipo ENUM('CLIENTE', 'PRESTADOR') NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuarios PRIMARY KEY (id),
    CONSTRAINT uq_usuarios_email UNIQUE (email),
    CONSTRAINT uq_usuarios_cnpj UNIQUE (cnpj)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE recuperacao_senha_tokens (
    id BIGINT NOT NULL AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    codigo VARCHAR(12) NOT NULL,
    expira_em DATETIME NOT NULL,
    usado_em DATETIME NULL,
    tentativas_falhas INT NOT NULL DEFAULT 0,
    bloqueado_ate DATETIME NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_recuperacao_senha_tokens PRIMARY KEY (id),
    CONSTRAINT fk_recuperacao_senha_tokens_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    prestador_id BIGINT NOT NULL,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT NULL,
    duracao_min INT NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_servicos PRIMARY KEY (id),
    CONSTRAINT fk_servicos_prestador FOREIGN KEY (prestador_id) REFERENCES usuarios(id),
    CONSTRAINT chk_servicos_duracao_min CHECK (duracao_min > 0),
    CONSTRAINT chk_servicos_preco CHECK (preco > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE disponibilidades (
    id BIGINT NOT NULL AUTO_INCREMENT,
    prestador_id BIGINT NOT NULL,
    dia_semana TINYINT NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_disponibilidades PRIMARY KEY (id),
    CONSTRAINT fk_disponibilidades_prestador FOREIGN KEY (prestador_id) REFERENCES usuarios(id),
    CONSTRAINT chk_disponibilidades_dia_semana CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT chk_disponibilidades_intervalo CHECK (hora_fim > hora_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE agendamentos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    cliente_id BIGINT NOT NULL,
    prestador_id BIGINT NOT NULL,
    servico_id BIGINT NOT NULL,
    inicio_at DATETIME NOT NULL,
    fim_at DATETIME NOT NULL,
    status ENUM('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'CONCLUIDO') NOT NULL DEFAULT 'PENDENTE',
    observacoes TEXT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_agendamentos PRIMARY KEY (id),
    CONSTRAINT fk_agendamentos_cliente FOREIGN KEY (cliente_id) REFERENCES usuarios(id),
    CONSTRAINT fk_agendamentos_prestador FOREIGN KEY (prestador_id) REFERENCES usuarios(id),
    CONSTRAINT fk_agendamentos_servico FOREIGN KEY (servico_id) REFERENCES servicos(id),
    CONSTRAINT chk_agendamentos_intervalo CHECK (fim_at > inicio_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE avaliacoes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    agendamento_id BIGINT NOT NULL,
    nota INT NOT NULL,
    comentario TEXT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_avaliacoes PRIMARY KEY (id),
    CONSTRAINT uq_avaliacoes_agendamento UNIQUE (agendamento_id),
    CONSTRAINT fk_avaliacoes_agendamento FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id),
    CONSTRAINT chk_avaliacoes_nota CHECK (nota BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE chat_conversas (
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

CREATE TABLE chat_mensagens (
    id BIGINT NOT NULL AUTO_INCREMENT,
    conversa_id BIGINT NOT NULL,
    remetente_id BIGINT NOT NULL,
    conteudo TEXT NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_chat_mensagens PRIMARY KEY (id),
    CONSTRAINT fk_chat_mensagens_conversa FOREIGN KEY (conversa_id) REFERENCES chat_conversas(id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_mensagens_remetente FOREIGN KEY (remetente_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE notificacao_eventos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    agendamento_id BIGINT NULL,
    chat_conversa_id BIGINT NULL,
    tipo ENUM('AGENDAMENTO', 'MENSAGEM', 'PROMOCAO', 'SISTEMA') NOT NULL DEFAULT 'SISTEMA',
    canal ENUM('APP', 'EMAIL', 'SMS') NOT NULL DEFAULT 'APP',
    titulo VARCHAR(120) NOT NULL,
    mensagem VARCHAR(500) NOT NULL,
    agendado_para DATETIME NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    enviado_em DATETIME NULL,
    lido_em DATETIME NULL,
    status ENUM('PENDENTE', 'ENVIADO', 'FALHA') NOT NULL DEFAULT 'PENDENTE',
    CONSTRAINT pk_notificacao_eventos PRIMARY KEY (id),
    CONSTRAINT fk_notificacao_eventos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_notificacao_eventos_agendamento FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id),
    CONSTRAINT fk_notificacao_eventos_chat_conversa FOREIGN KEY (chat_conversa_id) REFERENCES chat_conversas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
CREATE INDEX idx_notificacao_eventos_usuario_criado ON notificacao_eventos (usuario_id, criado_em, id);
CREATE INDEX idx_notificacao_eventos_usuario_lido ON notificacao_eventos (usuario_id, lido_em);
CREATE INDEX idx_notificacao_eventos_status ON notificacao_eventos (status);
CREATE INDEX idx_notificacao_eventos_canal ON notificacao_eventos (canal);
CREATE INDEX idx_notificacao_eventos_chat_conversa_id ON notificacao_eventos (chat_conversa_id);
CREATE INDEX idx_recuperacao_senha_tokens_usuario_codigo ON recuperacao_senha_tokens (usuario_id, codigo);
CREATE INDEX idx_chat_conversas_cliente_ultima ON chat_conversas (cliente_id, ultima_mensagem_em);
CREATE INDEX idx_chat_conversas_prestador_ultima ON chat_conversas (prestador_id, ultima_mensagem_em);
CREATE INDEX idx_chat_mensagens_conversa_criado ON chat_mensagens (conversa_id, criado_em, id);
CREATE INDEX idx_chat_mensagens_criado ON chat_mensagens (criado_em);
