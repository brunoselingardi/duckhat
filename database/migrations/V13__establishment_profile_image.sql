USE duckhat;

ALTER TABLE estabelecimentos
    ADD COLUMN foto_perfil_base64 MEDIUMTEXT NULL AFTER banner_imagem_base64;
