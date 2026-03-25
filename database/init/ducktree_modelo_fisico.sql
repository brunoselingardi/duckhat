CREATE DATABASE IF NOT EXISTS ducktree_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ducktree_db;

CREATE TABLE usuario (
    id_usuario BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha_hash CHAR(60) NOT NULL,
    tipo_perfil VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_usuario_email UNIQUE (email),
    CONSTRAINT chk_usuario_tipo_perfil
        CHECK (tipo_perfil IN ('CLIENTE', 'PRESTADOR', 'ADMIN'))
) ENGINE=InnoDB;

CREATE TABLE prestador (
    id_prestador BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario_admin BIGINT UNSIGNED NOT NULL,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT NULL,
    telefone VARCHAR(20) NOT NULL,
    cep CHAR(8) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    bairro VARCHAR(80) NOT NULL,
    rua VARCHAR(120) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prestador_usuario_admin
        FOREIGN KEY (id_usuario_admin)
        REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE servico (
    id_servico BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_prestador BIGINT UNSIGNED NOT NULL,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT NULL,
    preco DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(60) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_servico_prestador_nome UNIQUE (id_prestador, nome),
    CONSTRAINT uq_servico_ref UNIQUE (id_servico, id_prestador),
    CONSTRAINT chk_servico_preco CHECK (preco >= 0),
    CONSTRAINT fk_servico_prestador
        FOREIGN KEY (id_prestador)
        REFERENCES prestador (id_prestador)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE disponibilidade (
    id_disponibilidade BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_prestador BIGINT UNSIGNED NOT NULL,
    dia_semana TINYINT UNSIGNED NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_disponibilidade_dia CHECK (dia_semana BETWEEN 0 AND 6),
    CONSTRAINT chk_disponibilidade_intervalo CHECK (hora_inicio < hora_fim),
    CONSTRAINT uq_disponibilidade_faixa
        UNIQUE (id_prestador, dia_semana, hora_inicio, hora_fim),
    CONSTRAINT fk_disponibilidade_prestador
        FOREIGN KEY (id_prestador)
        REFERENCES prestador (id_prestador)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE agendamento (
    id_agendamento BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario_cliente BIGINT UNSIGNED NOT NULL,
    id_prestador BIGINT UNSIGNED NOT NULL,
    id_servico BIGINT UNSIGNED NOT NULL,
    data_hora DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    observacoes VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_agendamento_slot UNIQUE (id_prestador, data_hora),
    CONSTRAINT chk_agendamento_status
        CHECK (status IN ('PENDENTE', 'CONFIRMADO', 'REMARCADO', 'CANCELADO', 'CONCLUIDO')),
    CONSTRAINT fk_agendamento_usuario
        FOREIGN KEY (id_usuario_cliente)
        REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_agendamento_prestador
        FOREIGN KEY (id_prestador)
        REFERENCES prestador (id_prestador)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_agendamento_servico_prestador
        FOREIGN KEY (id_servico, id_prestador)
        REFERENCES servico (id_servico, id_prestador)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE avaliacao (
    id_agendamento BIGINT UNSIGNED PRIMARY KEY,
    nota_avaliacao TINYINT UNSIGNED NOT NULL,
    comentarios VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_avaliacao_nota CHECK (nota_avaliacao BETWEEN 1 AND 5),
    CONSTRAINT fk_avaliacao_agendamento
        FOREIGN KEY (id_agendamento)
        REFERENCES agendamento (id_agendamento)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE evento_notificacao (
    id_evento BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_agendamento BIGINT UNSIGNED NOT NULL,
    tipo_evento VARCHAR(30) NOT NULL,
    disparar_em DATETIME NOT NULL,
    status_envio VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_evento_tipo
        CHECK (tipo_evento IN ('CONFIRMACAO', 'LEMBRETE', 'REMARCACAO', 'CANCELAMENTO',
                               'CHECKIN', 'ATRASO', 'PAGAMENTO', 'POS_ATENDIMENTO')),
    CONSTRAINT chk_evento_status
        CHECK (status_envio IN ('PENDENTE', 'ENVIADO', 'FALHOU', 'CANCELADO')),
    CONSTRAINT fk_evento_agendamento
        FOREIGN KEY (id_agendamento)
        REFERENCES agendamento (id_agendamento)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_evento_fila (status_envio, disparar_em)
) ENGINE=InnoDB;

INSERT INTO agendamento
    (id_usuario_cliente, id_prestador, id_servico, data_hora, status, observacoes)
VALUES
    (1, 1, 1, '2026-04-02 14:00:00', 'PENDENTE',
     'Primeiro atendimento agendado pelo aplicativo.');

SELECT
    a.id_agendamento,
    u.nome AS cliente,
    p.nome AS prestador,
    s.nome AS servico,
    s.preco,
    a.data_hora,
    a.status
FROM agendamento AS a
INNER JOIN usuario AS u
    ON u.id_usuario = a.id_usuario_cliente
INNER JOIN prestador AS p
    ON p.id_prestador = a.id_prestador
INNER JOIN servico AS s
    ON s.id_servico = a.id_servico
ORDER BY a.data_hora ASC;