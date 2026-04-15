CREATE TABLE usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    tipo ENUM('CLIENTE', 'PRESTADOR') NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE servicos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    prestador_id BIGINT NOT NULL,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT,
    duracao_min INT NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_servicos_prestador
        FOREIGN KEY (prestador_id) REFERENCES usuarios(id)
);

CREATE TABLE disponibilidades (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    prestador_id BIGINT NOT NULL,
    dia_semana TINYINT NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_disponibilidades_prestador
        FOREIGN KEY (prestador_id) REFERENCES usuarios(id)
);

CREATE TABLE agendamentos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    prestador_id BIGINT NOT NULL,
    servico_id BIGINT NOT NULL,
    inicio_at DATETIME NOT NULL,
    fim_at DATETIME NOT NULL,
    status ENUM('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'CONCLUIDO') NOT NULL DEFAULT 'PENDENTE',
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_agendamentos_cliente
        FOREIGN KEY (cliente_id) REFERENCES usuarios(id),
    CONSTRAINT fk_agendamentos_prestador
        FOREIGN KEY (prestador_id) REFERENCES usuarios(id),
    CONSTRAINT fk_agendamentos_servico
        FOREIGN KEY (servico_id) REFERENCES servicos(id)
);

CREATE TABLE avaliacoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agendamento_id BIGINT NOT NULL UNIQUE,
    nota INT NOT NULL,
    comentario TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_avaliacoes_agendamento
        FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id)
);

CREATE TABLE notificacao_eventos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agendamento_id BIGINT NOT NULL,
    canal ENUM('APP', 'EMAIL', 'SMS') NOT NULL DEFAULT 'APP',
    agendado_para DATETIME NOT NULL,
    enviado_em DATETIME NULL,
    status ENUM('PENDENTE', 'ENVIADO', 'FALHA') NOT NULL DEFAULT 'PENDENTE',
    CONSTRAINT fk_notificacao_agendamento
        FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id)
);