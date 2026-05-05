USE duckhat;

INSERT INTO usuarios (id, nome, email, senha_hash, telefone, cnpj, responsavel_nome, tipo, criado_em) VALUES
    (2, 'Barbie Dream Barber', 'prestador@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999999', '11222333000144', 'Barbie Responsavel', 'PRESTADOR', '2026-04-04 12:43:06')
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    email = VALUES(email),
    senha_hash = VALUES(senha_hash),
    telefone = VALUES(telefone),
    cnpj = VALUES(cnpj),
    responsavel_nome = VALUES(responsavel_nome),
    tipo = VALUES(tipo);

INSERT INTO estabelecimentos (usuario_id, nome, telefone, cnpj, responsavel_nome) VALUES
    (2, 'Barbie Dream Barber', '19999999999', '11222333000144', 'Barbie Responsavel')
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    telefone = VALUES(telefone),
    cnpj = VALUES(cnpj),
    responsavel_nome = VALUES(responsavel_nome);

INSERT INTO servicos (id, prestador_id, nome, descricao, duracao_min, preco, ativo, criado_em) VALUES
    (1, 2, 'Glow Cut Barbie', 'Corte com acabamento leve, volume alinhado e finalizacao com assinatura fashionista.', 50, 55.00, TRUE, '2026-04-04 13:26:33'),
    (2, 2, 'Pink Beard Design', 'Desenho de barba com contorno preciso, toalha quente e cuidado premium.', 35, 42.00, TRUE, '2026-04-04 14:37:32'),
    (3, 2, 'Dream Combo', 'Pacote completo com corte, barba e finalizacao pensado para um visual marcante.', 80, 89.00, TRUE, '2026-04-06 11:58:10'),
    (4, 2, 'Ken Executive Finish', 'Acabamento rapido para quem quer elegancia, limpeza e presenca no mesmo horario.', 30, 38.00, TRUE, '2026-04-06 11:58:11')
ON DUPLICATE KEY UPDATE
    prestador_id = VALUES(prestador_id),
    nome = VALUES(nome),
    descricao = VALUES(descricao),
    duracao_min = VALUES(duracao_min),
    preco = VALUES(preco),
    ativo = VALUES(ativo);

DELETE FROM disponibilidades WHERE prestador_id = 2;

INSERT INTO disponibilidades (prestador_id, dia_semana, hora_inicio, hora_fim, ativo) VALUES
    (2, 1, '08:00:00', '19:00:00', TRUE),
    (2, 2, '08:00:00', '19:00:00', TRUE),
    (2, 3, '08:00:00', '19:00:00', TRUE),
    (2, 4, '08:00:00', '19:00:00', TRUE),
    (2, 5, '08:00:00', '19:00:00', TRUE),
    (2, 6, '08:00:00', '19:00:00', TRUE),
    (2, 7, '08:00:00', '19:00:00', TRUE);

ALTER TABLE servicos AUTO_INCREMENT = 5;
