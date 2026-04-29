DROP TABLE IF EXISTS `prestador_arquivos`;

CREATE TABLE `prestador_arquivos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `prestador_id` bigint NOT NULL,
  
  -- Identifica o local (banner, logo, perfil, estabelecimento, info, etc.)
  `tipo_area` varchar(50) NOT NULL, 
  
  -- Alterado para permitir NULL caso você queira salvar apenas a descrição em algum registro
  `arquivo_binario` LONGBLOB DEFAULT NULL, 
  
  -- Tipo do arquivo (image/jpeg, image/png)
  `mime_type` varchar(50) DEFAULT NULL,
  
  -- NOVA COLUNA: Descrição detalhada do estabelecimento
  `descricao_estabelecimento` TEXT DEFAULT NULL,
  
  `criado_em` datetime DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`id`),
  -- Índice para busca rápida por prestador e área
  KEY `idx_prestador_area` (`prestador_id`, `tipo_area`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

---
-- 2. Exemplos de queries que seu Backend irá utilizar:

-- A) Para tipos de "1 por vez" (Banner, Logo, Perfil):
-- O backend deve rodar o DELETE antes de inserir o novo para não acumular lixo.
DELETE FROM `prestador_arquivos` WHERE `prestador_id` = 1 AND `tipo_area` = 'banner';

-- B) Para buscar as imagens do estabelecimento (Até 5):
SELECT `id`, `arquivo_binario`, `mime_type` 
FROM `prestador_arquivos` 
WHERE `prestador_id` = 1 AND `tipo_area` = 'estabelecimento'
ORDER BY `criado_em` ASC;

-- C) Para deletar uma imagem específica da galeria de 5 (quando o usuário clica no "X"):
DELETE FROM `prestador_arquivos` WHERE `id` = 123;