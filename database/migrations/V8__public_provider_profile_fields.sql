USE duckhat;

INSERT INTO estabelecimentos (
    usuario_id,
    nome,
    telefone,
    cnpj,
    responsavel_nome,
    endereco,
    descricao,
    horario_atendimento
)
SELECT
    id,
    nome,
    telefone,
    cnpj,
    responsavel_nome,
    COALESCE(endereco, 'Av. DuckHat, 120 - Setor Bueno'),
    'Uma barberaria com energia Barbie: visual marcante, atendimento caloroso e uma experiencia pensada para quem quer sair com mais estilo e personalidade.',
    'Segunda a sexta 9h - 20h | Sabado 9h - 18h'
FROM usuarios
WHERE id = 2
  AND tipo = 'PRESTADOR'
  AND cnpj IS NOT NULL
  AND responsavel_nome IS NOT NULL
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    telefone = VALUES(telefone),
    cnpj = VALUES(cnpj),
    responsavel_nome = VALUES(responsavel_nome),
    endereco = VALUES(endereco),
    descricao = COALESCE(estabelecimentos.descricao, VALUES(descricao)),
    horario_atendimento = COALESCE(estabelecimentos.horario_atendimento, VALUES(horario_atendimento));
