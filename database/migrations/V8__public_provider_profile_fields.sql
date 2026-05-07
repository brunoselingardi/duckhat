USE duckhat;

ALTER TABLE usuarios
    ADD COLUMN descricao_publica VARCHAR(600) NULL AFTER endereco,
    ADD COLUMN horario_atendimento VARCHAR(160) NULL AFTER descricao_publica,
    ADD COLUMN imagem_capa VARCHAR(255) NULL AFTER horario_atendimento,
    ADD COLUMN imagem_logo VARCHAR(255) NULL AFTER imagem_capa;

UPDATE usuarios
SET endereco = COALESCE(endereco, 'Av. DuckHat, 120 - Setor Bueno'),
    descricao_publica = COALESCE(
        descricao_publica,
        'Uma barberaria com energia Barbie: visual marcante, atendimento caloroso e uma experiencia pensada para quem quer sair com mais estilo e personalidade.'
    ),
    horario_atendimento = COALESCE(
        horario_atendimento,
        'Segunda a sexta 9h - 20h | Sabado 9h - 18h'
    ),
    imagem_capa = COALESCE(imagem_capa, 'assets/barbie.jpg'),
    imagem_logo = COALESCE(imagem_logo, 'assets/barbielogo.jpg')
WHERE id = 2
  AND tipo = 'PRESTADOR';
