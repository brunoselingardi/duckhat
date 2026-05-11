USE duckhat;

INSERT INTO usuarios (
    id,
    nome,
    email,
    senha_hash,
    telefone,
    cnpj,
    responsavel_nome,
    endereco,
    descricao_publica,
    horario_atendimento,
    imagem_capa,
    imagem_logo,
    tipo,
    criado_em
) VALUES (
    13,
    'Jorje Encanamentos',
    'encanador@duckhat.com',
    '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu',
    '62999990013',
    '12345678000199',
    'Jorje Silva',
    'Rua dos Canos, 45 - Setor Oeste',
    'Atendimento rapido para vazamentos, pias, ralos e manutencao hidraulica residencial e comercial.',
    'Segunda a sabado 7h - 19h',
    'assets/salao.jpg',
    'assets/Ducklogo.jpg',
    'PRESTADOR',
    '2026-05-07 18:00:00'
)
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    email = VALUES(email),
    senha_hash = VALUES(senha_hash),
    telefone = VALUES(telefone),
    cnpj = VALUES(cnpj),
    responsavel_nome = VALUES(responsavel_nome),
    endereco = VALUES(endereco),
    descricao_publica = VALUES(descricao_publica),
    horario_atendimento = VALUES(horario_atendimento),
    imagem_capa = VALUES(imagem_capa),
    imagem_logo = VALUES(imagem_logo),
    tipo = VALUES(tipo);

INSERT INTO servicos (
    id,
    prestador_id,
    nome,
    descricao,
    duracao_min,
    preco,
    ativo,
    criado_em
) VALUES
    (5, 13, 'Visita tecnica de encanador', 'Diagnostico inicial para canos, ralos, pias e pontos de vazamento.', 45, 90.00, TRUE, '2026-05-07 18:00:10'),
    (6, 13, 'Reparo de vazamento', 'Correcao de vazamentos aparentes e troca de conexoes danificadas.', 90, 180.00, TRUE, '2026-05-07 18:00:11'),
    (7, 13, 'Desentupimento de pia e ralo', 'Atendimento para entupimentos leves em cozinha, banheiro e area de servico.', 60, 140.00, TRUE, '2026-05-07 18:00:12')
ON DUPLICATE KEY UPDATE
    prestador_id = VALUES(prestador_id),
    nome = VALUES(nome),
    descricao = VALUES(descricao),
    duracao_min = VALUES(duracao_min),
    preco = VALUES(preco),
    ativo = VALUES(ativo);

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
    endereco,
    descricao_publica,
    horario_atendimento
FROM usuarios
WHERE id = 13
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    telefone = VALUES(telefone),
    cnpj = VALUES(cnpj),
    responsavel_nome = VALUES(responsavel_nome),
    endereco = VALUES(endereco),
    descricao = VALUES(descricao),
    horario_atendimento = VALUES(horario_atendimento);

DELETE FROM disponibilidades WHERE prestador_id = 13;

INSERT INTO disponibilidades (prestador_id, dia_semana, hora_inicio, hora_fim, ativo) VALUES
    (13, 1, '07:00:00', '19:00:00', TRUE),
    (13, 2, '07:00:00', '19:00:00', TRUE),
    (13, 3, '07:00:00', '19:00:00', TRUE),
    (13, 4, '07:00:00', '19:00:00', TRUE),
    (13, 5, '07:00:00', '19:00:00', TRUE),
    (13, 6, '07:00:00', '15:00:00', TRUE);

INSERT INTO notificacao_preferencias (
    usuario_id,
    agendamentos,
    mensagens,
    promocoes,
    novidades,
    resumo_email
) VALUES (
    13,
    TRUE,
    TRUE,
    FALSE,
    FALSE,
    TRUE
)
ON DUPLICATE KEY UPDATE
    agendamentos = VALUES(agendamentos),
    mensagens = VALUES(mensagens),
    promocoes = VALUES(promocoes),
    novidades = VALUES(novidades),
    resumo_email = VALUES(resumo_email);

ALTER TABLE usuarios AUTO_INCREMENT = 14;
ALTER TABLE servicos AUTO_INCREMENT = 8;
