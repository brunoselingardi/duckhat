USE duckhat;

ALTER TABLE usuarios
    ADD COLUMN foto_perfil_base64 MEDIUMTEXT NULL AFTER endereco;
