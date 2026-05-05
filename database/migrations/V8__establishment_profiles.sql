USE duckhat;

CREATE TABLE IF NOT EXISTS estabelecimentos (
    usuario_id BIGINT NOT NULL,
    nome VARCHAR(120) NOT NULL,
    telefone VARCHAR(20) NULL,
    cnpj VARCHAR(14) NOT NULL,
    responsavel_nome VARCHAR(120) NOT NULL,
    endereco VARCHAR(255) NULL,
    descricao TEXT NULL,
    horario_atendimento VARCHAR(160) NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_estabelecimentos PRIMARY KEY (usuario_id),
    CONSTRAINT uq_estabelecimentos_cnpj UNIQUE (cnpj),
    CONSTRAINT fk_estabelecimentos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO estabelecimentos (
    usuario_id,
    nome,
    telefone,
    cnpj,
    responsavel_nome,
    endereco
)
SELECT
    id,
    nome,
    telefone,
    cnpj,
    responsavel_nome,
    endereco
FROM usuarios
WHERE tipo = 'PRESTADOR'
  AND cnpj IS NOT NULL
  AND responsavel_nome IS NOT NULL
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    telefone = VALUES(telefone),
    cnpj = VALUES(cnpj),
    responsavel_nome = VALUES(responsavel_nome),
    endereco = VALUES(endereco);
