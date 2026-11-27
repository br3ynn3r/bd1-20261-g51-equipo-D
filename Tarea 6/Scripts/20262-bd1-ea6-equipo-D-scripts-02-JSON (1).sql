--
-- Scripts - Enunciados DML para Manipulación de Datos Semi-Estructurados (JSON)
-- Manipulación de Campo JSON (Perfil Profesional y Competencias)
--
-- Requisito: haber ejecutado antes red_pascualina_completo.sql.
-- Ejecute los bloques en orden. Si vuelve a ejecutar el script de poblamiento,
-- la columna JSON se borra y debe repetir los pasos 0 y 1.


-- 0. Preparación (DDL): el esquema no tiene un campo JSON, por eso se agrega a "perfil"
ALTER TABLE perfil ADD COLUMN IF NOT EXISTS datos_profesionales JSONB;


-- 1. UPDATE: carga inicial del perfil profesional de todos los perfiles
UPDATE perfil
SET datos_profesionales = jsonb_build_object(
        'competencias',
            CASE id_perfil % 4
                WHEN 0 THEN '["SQL", "PostgreSQL", "Python"]'::jsonb
                WHEN 1 THEN '["Java", "Git", "SQL"]'::jsonb
                WHEN 2 THEN '["AutoCAD", "Excel"]'::jsonb
                ELSE        '["JavaScript", "React", "Figma"]'::jsonb
            END,
        'idiomas',
            jsonb_build_object(
                'español', 'Nativo',
                'ingles', (ARRAY['A2','B1','B2','C1'])[1 + (id_perfil % 4)]
            ),
        'experiencia_anios', id_perfil % 11,
        'disponible_para_trabajar', (id_perfil % 3 = 0)
    );


-- 2. INSERT: crear un perfil nuevo con un documento JSON
--    (ON CONFLICT permite repetir el script sin error)
INSERT INTO perfil (id_perfil, area_estudio, biografia_corta, fecha_actualizacion, datos_profesionales)
VALUES (
    900001,
    'Análisis de Datos',
    'Perfil de prueba para operaciones JSON.',
    LOCALTIMESTAMP,
    '{
        "competencias": ["SQL", "Power BI"],
        "idiomas": {"español": "Nativo", "ingles": "B2"},
        "experiencia_anios": 2,
        "disponible_para_trabajar": true
     }'::jsonb
)
ON CONFLICT (id_perfil) DO UPDATE
SET datos_profesionales = EXCLUDED.datos_profesionales,
    fecha_actualizacion = EXCLUDED.fecha_actualizacion;


-- 3. SELECT: extraer valores del JSON (-> devuelve JSON, ->> devuelve texto, #>> sigue una ruta)
SELECT id_perfil,
       area_estudio,
       datos_profesionales -> 'competencias'                AS competencias,
       datos_profesionales #>> '{idiomas,ingles}'           AS nivel_ingles,
       (datos_profesionales ->> 'experiencia_anios')::int   AS experiencia_anios
FROM perfil
WHERE id_perfil IN (1, 2, 3, 4, 900001)
ORDER BY id_perfil;


-- 4. SELECT con filtros: perfiles que saben SQL, tienen 5 o más años y están disponibles
SELECT id_perfil, area_estudio, datos_profesionales
FROM perfil
WHERE datos_profesionales -> 'competencias' ? 'SQL'
  AND (datos_profesionales ->> 'experiencia_anios')::int >= 5
  AND datos_profesionales @> '{"disponible_para_trabajar": true}'
ORDER BY id_perfil
LIMIT 20;


-- 5. UPDATE: modificar un valor interno con jsonb_set
UPDATE perfil
SET datos_profesionales = jsonb_set(datos_profesionales, '{idiomas,ingles}', '"C1"'),
    fecha_actualizacion = LOCALTIMESTAMP
WHERE id_perfil = 900001
RETURNING id_perfil, datos_profesionales -> 'idiomas' AS idiomas;


-- 6. UPDATE: agregar una competencia al arreglo (sin duplicarla)
UPDATE perfil
SET datos_profesionales = jsonb_set(
        datos_profesionales,
        '{competencias}',
        (datos_profesionales -> 'competencias') || '["Python"]'::jsonb
    ),
    fecha_actualizacion = LOCALTIMESTAMP
WHERE id_perfil = 900001
  AND NOT (datos_profesionales -> 'competencias' ? 'Python')
RETURNING id_perfil, datos_profesionales -> 'competencias' AS competencias;


-- 7. UPDATE: agregar una clave nueva con el operador de concatenación ||
UPDATE perfil
SET datos_profesionales = datos_profesionales || '{"certificaciones": ["Fundamentos de bases de datos"]}'::jsonb
WHERE id_perfil = 900001
RETURNING id_perfil, datos_profesionales;


-- 8. UPDATE: eliminar un elemento del arreglo y una clave completa
UPDATE perfil
SET datos_profesionales =
        jsonb_set(datos_profesionales, '{competencias}',
                  (datos_profesionales -> 'competencias') - 'Power BI')
        - 'certificaciones'
WHERE id_perfil = 900001
RETURNING id_perfil, datos_profesionales;


-- 9. SELECT con expansión del arreglo: ranking de competencias en la plataforma
SELECT c.competencia, COUNT(*) AS total_perfiles
FROM perfil p
CROSS JOIN LATERAL jsonb_array_elements_text(p.datos_profesionales -> 'competencias') AS c(competencia)
GROUP BY c.competencia
ORDER BY total_perfiles DESC, c.competencia;


-- 10. Índice GIN para acelerar búsquedas con los operadores @> y ?
CREATE INDEX IF NOT EXISTS idx_perfil_datos_profesionales
    ON perfil USING GIN (datos_profesionales);


-- 11. DELETE: eliminar el perfil de prueba usando una condición sobre el JSON
DELETE FROM perfil
WHERE id_perfil = 900001
  AND datos_profesionales @> '{"idiomas": {"ingles": "C1"}}'
RETURNING id_perfil, datos_profesionales;
