USE duckhat;

INSERT INTO disponibilidades (prestador_id, dia_semana, hora_inicio, hora_fim, ativo)
SELECT u.id, dias.dia_semana, '09:00:00', '18:00:00', TRUE
FROM usuarios u
JOIN (
    SELECT 1 AS dia_semana
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
) dias
WHERE u.tipo = 'PRESTADOR'
  AND NOT EXISTS (
      SELECT 1
      FROM disponibilidades d
      WHERE d.prestador_id = u.id
        AND d.dia_semana = dias.dia_semana
  );
