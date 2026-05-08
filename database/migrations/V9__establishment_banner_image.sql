USE duckhat;

ALTER TABLE estabelecimentos
    ADD COLUMN banner_imagem_base64 MEDIUMTEXT NULL AFTER horario_atendimento;
