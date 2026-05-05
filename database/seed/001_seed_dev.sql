USE duckhat;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE notificacao_eventos;
TRUNCATE TABLE notificacao_preferencias;
TRUNCATE TABLE avaliacoes;
TRUNCATE TABLE agendamentos;
TRUNCATE TABLE disponibilidades;
TRUNCATE TABLE servicos;
TRUNCATE TABLE estabelecimentos;
TRUNCATE TABLE usuarios;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO usuarios (id, nome, email, senha_hash, telefone, cnpj, responsavel_nome, tipo, criado_em) VALUES
    (1, 'Login Teste', 'login@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999999', NULL, NULL, 'CLIENTE', '2026-04-03 19:26:19'),
    (2, 'Barbie Dream Barber', 'prestador@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999999', '11222333000144', 'Barbie Responsavel', 'PRESTADOR', '2026-04-04 12:43:06'),
    (3, 'Novo Usuario', 'novo@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999999', NULL, NULL, 'CLIENTE', '2026-04-04 12:48:35'),
    (4, 'Prestador API A', 'prestador.api.a@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999991', '11222333000145', 'Responsavel API A', 'PRESTADOR', '2026-04-06 11:57:36'),
    (5, 'Prestador API B', 'prestador.api.b@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999992', '11222333000146', 'Responsavel API B', 'PRESTADOR', '2026-04-06 11:57:42'),
    (6, 'Cliente API Fluxo', 'cliente.api.fluxo@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999993', NULL, NULL, 'CLIENTE', '2026-04-06 12:13:19'),
    (7, 'Cliente Fluxo API', 'cliente.fluxo.1775477863@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999993', NULL, NULL, 'CLIENTE', '2026-04-06 12:17:44'),
    (8, 'Cliente Fluxo API', 'cliente.fluxo.1775477879@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999993', NULL, NULL, 'CLIENTE', '2026-04-06 12:17:59'),
    (9, 'Cliente API B', 'cliente.api.b@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999994', NULL, NULL, 'CLIENTE', '2026-04-06 12:48:29');

INSERT INTO estabelecimentos (usuario_id, nome, telefone, cnpj, responsavel_nome) VALUES
    (2, 'Barbie Dream Barber', '19999999999', '11222333000144', 'Barbie Responsavel'),
    (4, 'Prestador API A', '19999999991', '11222333000145', 'Responsavel API A'),
    (5, 'Prestador API B', '19999999992', '11222333000146', 'Responsavel API B');

INSERT INTO notificacao_preferencias (usuario_id, agendamentos, mensagens, promocoes, novidades, resumo_email) VALUES
    (1, TRUE, TRUE, TRUE, FALSE, TRUE),
    (2, TRUE, TRUE, TRUE, FALSE, TRUE),
    (3, TRUE, TRUE, TRUE, FALSE, TRUE),
    (4, TRUE, TRUE, TRUE, FALSE, TRUE),
    (5, TRUE, TRUE, TRUE, FALSE, TRUE),
    (6, TRUE, TRUE, TRUE, FALSE, TRUE),
    (7, TRUE, TRUE, TRUE, FALSE, TRUE),
    (8, TRUE, TRUE, TRUE, FALSE, TRUE),
    (9, TRUE, TRUE, TRUE, FALSE, TRUE);

INSERT INTO servicos (id, prestador_id, nome, descricao, duracao_min, preco, ativo, criado_em) VALUES
    (1, 2, 'Glow Cut Barbie', 'Corte com acabamento leve, volume alinhado e finalizacao com assinatura fashionista.', 50, 55.00, TRUE, '2026-04-04 13:26:33'),
    (2, 2, 'Pink Beard Design', 'Desenho de barba com contorno preciso, toalha quente e cuidado premium.', 35, 42.00, TRUE, '2026-04-04 14:37:32'),
    (3, 2, 'Dream Combo', 'Pacote completo com corte, barba e finalizacao pensado para um visual marcante.', 80, 89.00, TRUE, '2026-04-06 11:58:10'),
    (4, 2, 'Ken Executive Finish', 'Acabamento rapido para quem quer elegancia, limpeza e presenca no mesmo horario.', 30, 38.00, TRUE, '2026-04-06 11:58:11');

INSERT INTO disponibilidades (id, prestador_id, dia_semana, hora_inicio, hora_fim, ativo) VALUES
    (1, 2, 1, '08:00:00', '19:00:00', TRUE),
    (2, 2, 2, '08:00:00', '19:00:00', TRUE),
    (3, 2, 3, '08:00:00', '19:00:00', TRUE),
    (4, 2, 4, '08:00:00', '19:00:00', TRUE),
    (5, 2, 5, '08:00:00', '19:00:00', TRUE),
    (6, 2, 6, '08:00:00', '19:00:00', TRUE),
    (7, 2, 7, '08:00:00', '19:00:00', TRUE);

INSERT INTO agendamentos (id, cliente_id, prestador_id, servico_id, inicio_at, fim_at, status, observacoes, criado_em) VALUES
    (1, 1, 2, 1, '2026-04-05 10:00:00', '2026-04-05 10:45:00', 'CANCELADO', 'Agendamento cancelado para teste de fluxo', '2026-04-04 13:26:51'),
    (2, 1, 2, 1, '2026-04-06 10:00:00', '2026-04-06 10:45:00', 'CONCLUIDO', 'Teste após cancelamento em conflito', '2026-04-04 23:07:10'),
    (3, 6, 4, 3, '2026-04-13 09:00:00', '2026-04-13 10:00:00', 'PENDENTE', 'Teste do fluxo completo', '2026-04-06 12:13:34'),
    (4, 8, 4, 3, '2026-04-13 10:00:00', '2026-04-13 11:00:00', 'CONCLUIDO', 'Teste do fluxo completo', '2026-04-06 12:21:55');

INSERT INTO avaliacoes (id, agendamento_id, nota, comentario, criado_em) VALUES
    (1, 2, 5, 'Atendimento excelente', '2026-04-05 00:52:25'),
    (2, 4, 5, 'Teste de avaliação após conclusão', '2026-04-06 12:42:02');

INSERT INTO notificacao_eventos (
    id,
    usuario_id,
    agendamento_id,
    chat_conversa_id,
    tipo,
    canal,
    titulo,
    mensagem,
    agendado_para,
    criado_em,
    enviado_em,
    lido_em,
    status
) VALUES
    (1, 1, 2, NULL, 'AGENDAMENTO', 'APP', 'Agendamento confirmado', 'Seu horario com Barbie Dream Barber foi confirmado.', '2026-04-06 09:30:00', '2026-04-06 09:25:00', '2026-04-06 09:30:05', '2026-04-06 09:35:00', 'ENVIADO'),
    (2, 1, 2, NULL, 'AGENDAMENTO', 'APP', 'Lembrete de horario', 'Seu atendimento comeca em breve.', '2026-04-06 10:30:00', '2026-04-06 10:20:00', '2026-04-06 10:30:08', NULL, 'ENVIADO'),
    (3, 8, 4, NULL, 'AGENDAMENTO', 'APP', 'Lembrete de agendamento', 'Voce tem um agendamento em 13/04 as 09:30.', '2026-04-13 09:30:00', '2026-04-12 18:00:00', NULL, NULL, 'PENDENTE');

ALTER TABLE usuarios AUTO_INCREMENT = 10;
ALTER TABLE servicos AUTO_INCREMENT = 5;
ALTER TABLE disponibilidades AUTO_INCREMENT = 8;
ALTER TABLE agendamentos AUTO_INCREMENT = 5;
ALTER TABLE avaliacoes AUTO_INCREMENT = 3;
ALTER TABLE notificacao_eventos AUTO_INCREMENT = 4;
