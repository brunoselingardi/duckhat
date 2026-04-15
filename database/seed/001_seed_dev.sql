USE duckhat;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE notificacao_eventos;
TRUNCATE TABLE avaliacoes;
TRUNCATE TABLE agendamentos;
TRUNCATE TABLE disponibilidades;
TRUNCATE TABLE servicos;
TRUNCATE TABLE usuarios;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO usuarios (id, nome, email, senha_hash, telefone, tipo, criado_em) VALUES
    (1, 'Login Teste', 'login@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999999', 'CLIENTE', '2026-04-03 19:26:19'),
    (2, 'Prestador Teste', 'prestador@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999999', 'PRESTADOR', '2026-04-04 12:43:06'),
    (3, 'Novo Usuario', 'novo@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999999', 'CLIENTE', '2026-04-04 12:48:35'),
    (4, 'Prestador API A', 'prestador.api.a@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999991', 'PRESTADOR', '2026-04-06 11:57:36'),
    (5, 'Prestador API B', 'prestador.api.b@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999992', 'PRESTADOR', '2026-04-06 11:57:42'),
    (6, 'Cliente API Fluxo', 'cliente.api.fluxo@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999993', 'CLIENTE', '2026-04-06 12:13:19'),
    (7, 'Cliente Fluxo API', 'cliente.fluxo.1775477863@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999993', 'CLIENTE', '2026-04-06 12:17:44'),
    (8, 'Cliente Fluxo API', 'cliente.fluxo.1775477879@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999993', 'CLIENTE', '2026-04-06 12:17:59'),
    (9, 'Cliente API B', 'cliente.api.b@duckhat.com', '$2a$10$RhfsPNigztx9DXgo8efRae5WoXabIFKbFo2H6L2RCewKP98XJSRFu', '19999999994', 'CLIENTE', '2026-04-06 12:48:29');

INSERT INTO servicos (id, prestador_id, nome, descricao, duracao_min, preco, ativo, criado_em) VALUES
    (1, 2, 'Corte de cabelo', 'Corte masculino com acabamento', 45, 35.00, TRUE, '2026-04-04 13:26:33'),
    (2, 2, 'Barba', 'Barba completa', 30, 25.00, TRUE, '2026-04-04 14:37:32'),
    (3, 4, 'Corte Premium', 'Teste de serviço do prestador API A', 60, 80.00, TRUE, '2026-04-06 11:58:10');

INSERT INTO disponibilidades (id, prestador_id, dia_semana, hora_inicio, hora_fim, ativo) VALUES
    (1, 2, 1, '08:00:00', '12:00:00', TRUE),
    (2, 4, 1, '09:00:00', '12:00:00', TRUE);

INSERT INTO agendamentos (id, cliente_id, prestador_id, servico_id, inicio_at, fim_at, status, observacoes, criado_em) VALUES
    (1, 1, 2, 1, '2026-04-05 10:00:00', '2026-04-05 10:45:00', 'CANCELADO', 'Agendamento cancelado para teste de fluxo', '2026-04-04 13:26:51'),
    (2, 1, 2, 1, '2026-04-06 10:00:00', '2026-04-06 10:45:00', 'CONCLUIDO', 'Teste após cancelamento em conflito', '2026-04-04 23:07:10'),
    (3, 6, 4, 3, '2026-04-13 09:00:00', '2026-04-13 10:00:00', 'PENDENTE', 'Teste do fluxo completo', '2026-04-06 12:13:34'),
    (4, 8, 4, 3, '2026-04-13 10:00:00', '2026-04-13 11:00:00', 'CONCLUIDO', 'Teste do fluxo completo', '2026-04-06 12:21:55');

INSERT INTO avaliacoes (id, agendamento_id, nota, comentario, criado_em) VALUES
    (1, 2, 5, 'Atendimento excelente', '2026-04-05 00:52:25'),
    (2, 4, 5, 'Teste de avaliação após conclusão', '2026-04-06 12:42:02');

INSERT INTO notificacao_eventos (id, agendamento_id, canal, agendado_para, enviado_em, status) VALUES
    (1, 2, 'APP', '2026-04-06 09:30:00', '2026-04-06 09:30:05', 'ENVIADO'),
    (2, 2, 'APP', '2026-04-06 10:30:00', '2026-04-06 10:30:08', 'ENVIADO'),
    (3, 4, 'APP', '2026-04-13 09:30:00', NULL, 'PENDENTE');

ALTER TABLE usuarios AUTO_INCREMENT = 10;
ALTER TABLE servicos AUTO_INCREMENT = 4;
ALTER TABLE disponibilidades AUTO_INCREMENT = 3;
ALTER TABLE agendamentos AUTO_INCREMENT = 5;
ALTER TABLE avaliacoes AUTO_INCREMENT = 3;
ALTER TABLE notificacao_eventos AUTO_INCREMENT = 4;
