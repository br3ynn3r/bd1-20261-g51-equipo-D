



BEGIN;

--
-- 1.- DATOS SEMI-ESTRUCTURADOS PARA BIG DATA
-- Campo "perfil_usuario" en la tabla "usuario"
--

-- 1.1.- Agregar un campo tipo JSONB
ALTER TABLE usuario
    ADD COLUMN IF NOT EXISTS perfil_usuario JSONB;

-- 1.2.- Agregar un par de registros

INSERT INTO rol (nombre_rol, descripcion_rol)
VALUES ('Estudiante', 'Usuario estudiante de la comunidad universitaria');

INSERT INTO tipo_usuario (nombre_tipo_usuario, descripcion_tipo)
VALUES ('Pregrado', 'Estudiante de programa de pregrado');

INSERT INTO usuario
    (id_rol, id_tipo_usuario, nombres, apellidos, correo_institucional,
     clave_hash, fecha_registro, estado_usuario, perfil_usuario)
VALUES
(
    (SELECT id_rol FROM rol WHERE nombre_rol = 'Estudiante' LIMIT 1),
    (SELECT id_tipo_usuario FROM tipo_usuario WHERE nombre_tipo_usuario = 'Pregrado' LIMIT 1),
    'Laura', 'Gómez Restrepo', 'laura.gomez@universidad.edu.co',
    'hash_demo_laura', NOW(), 'activo',
    '{
        "preferencias": {
            "idioma": "es",
            "tema_interfaz": "oscuro",
            "notificaciones": {"correo": true, "push": false}
        },
        "intereses": ["inteligencia artificial", "bases de datos", "ciclismo"],
        "idiomas": [
            {"idioma": "español", "nivel": "nativo"},
            {"idioma": "inglés", "nivel": "B2"}
        ],
        "disponibilidad": {"dias": ["lunes", "miércoles", "viernes"], "franja": "14:00-18:00"},
        "redes": {"linkedin": "linkedin.com/in/lauragomez", "github": "lgomez-dev"}
    }'::jsonb
),
(
    (SELECT id_rol FROM rol WHERE nombre_rol = 'Estudiante' LIMIT 1),
    (SELECT id_tipo_usuario FROM tipo_usuario WHERE nombre_tipo_usuario = 'Pregrado' LIMIT 1),
    'Carlos', 'Mejía Londoño', 'carlos.mejia@universidad.edu.co',
    'hash_demo_carlos', NOW(), 'activo',
    '{
        "preferencias": {
            "idioma": "en",
            "tema_interfaz": "claro",
            "notificaciones": {"correo": true, "push": true}
        },
        "intereses": ["videojuegos", "ciberseguridad", "fotografía"],
        "idiomas": [
            {"idioma": "español", "nivel": "nativo"},
            {"idioma": "inglés", "nivel": "C1"},
            {"idioma": "portugués", "nivel": "A2"}
        ],
        "disponibilidad": {"dias": ["martes", "jueves"], "franja": "08:00-12:00"},
        "certificaciones": ["CCNA", "Scrum Fundamentals"]
    }'::jsonb
);

-- 1.3.- Consultar la información agregada
-- a) Contenido completo del campo
SELECT id_usuario, nombres, apellidos, perfil_usuario
FROM usuario
WHERE perfil_usuario IS NOT NULL;

-- b) Extraer valores específicos (-> devuelve JSON, ->> devuelve texto)
SELECT nombres,
       perfil_usuario -> 'preferencias' ->> 'tema_interfaz' AS tema,
       perfil_usuario ->> 'disponibilidad'                   AS disponibilidad,
       perfil_usuario -> 'intereses' ->> 0                   AS primer_interes
FROM usuario
WHERE perfil_usuario IS NOT NULL;

-- c) Filtrar con el operador de contención @>
SELECT nombres, apellidos
FROM usuario
WHERE perfil_usuario @> '{"intereses": ["ciberseguridad"]}';

-- d) Desanidar un arreglo JSON (un renglón por idioma)
SELECT u.nombres, i ->> 'idioma' AS idioma, i ->> 'nivel' AS nivel
FROM usuario u,
     jsonb_array_elements(u.perfil_usuario -> 'idiomas') AS i;

-- Índice GIN para acelerar búsquedas dentro del JSONB
CREATE INDEX IF NOT EXISTS idx_usuario_perfil_usuario
    ON usuario USING GIN (perfil_usuario);

-- 1.4.- Describir el campo y explicar su propósito
COMMENT ON COLUMN usuario.perfil_usuario IS
    'JSONB con datos flexibles del usuario: preferencias, intereses, idiomas, disponibilidad, redes y certificaciones.';

-- Descripción del campo (catálogo del sistema)
SELECT column_name, data_type, is_nullable,
       col_description('usuario'::regclass, ordinal_position) AS descripcion
FROM information_schema.columns
WHERE table_name = 'usuario' AND column_name = 'perfil_usuario';



--
-- 2.- DATOS SEMI-ESTRUCTURADOS (PARA BIG DATA o IOT)
-- Nuevo campo "datos_iot" en la tabla "evento"
--

-- 2.1.- Agregar un campo tipo JSONB
ALTER TABLE evento
    ADD COLUMN IF NOT EXISTS datos_iot JSONB;

-- 2.2.- Agregar un par de registros de información
INSERT INTO evento
    (id_usuario_organizador, id_tipo_evento, titulo_evento, descripcion_evento,
     fecha_hora_inicio, fecha_hora_fin, lugar_evento, cupo_maximo, datos_iot)
VALUES
(
    (SELECT id_usuario FROM usuario WHERE correo_institucional = 'laura.gomez@universidad.edu.co'),
    NULL,
    'Feria de Tecnología', 'Exposición de proyectos estudiantiles',
    '2026-11-10 09:00', '2026-11-10 17:00', 'Auditorio Principal', 200,
    '{
        "dispositivo": {"id": "SENS-AUD-001", "tipo": "contador_aforo", "firmware": "2.3.1"},
        "lecturas": [
            {"hora": "09:00", "personas": 12, "temperatura_c": 22.5},
            {"hora": "12:00", "personas": 148, "temperatura_c": 25.1},
            {"hora": "15:00", "personas": 173, "temperatura_c": 26.4}
        ],
        "alertas": {"aforo_superado": false, "umbral_temperatura_c": 28}
    }'::jsonb
),
(
    (SELECT id_usuario FROM usuario WHERE correo_institucional = 'carlos.mejia@universidad.edu.co'),
    NULL,
    'Taller de Ciberseguridad', 'Práctica con laboratorio virtual',
    '2026-11-12 14:00', '2026-11-12 18:00', 'Laboratorio de Cómputo 3', 40,
    '{
        "dispositivo": {"id": "SENS-LAB-014", "tipo": "monitor_ambiental", "firmware": "1.8.0"},
        "lecturas": [
            {"hora": "14:00", "personas": 25, "temperatura_c": 23.0, "humedad_pct": 55},
            {"hora": "16:00", "personas": 38, "temperatura_c": 27.8, "humedad_pct": 61}
        ],
        "alertas": {"aforo_superado": false, "umbral_temperatura_c": 28}
    }'::jsonb
);

-- 2.3.- Consultar la información agregada
-- a) Contenido completo
SELECT id_evento, titulo_evento, datos_iot
FROM evento
WHERE datos_iot IS NOT NULL;

-- b) Valores específicos del dispositivo
SELECT titulo_evento,
       datos_iot -> 'dispositivo' ->> 'id'   AS id_sensor,
       datos_iot -> 'dispositivo' ->> 'tipo' AS tipo_sensor
FROM evento
WHERE datos_iot IS NOT NULL;

-- c) Desanidar lecturas y calcular promedios por evento
SELECT e.titulo_evento,
       ROUND(AVG((l ->> 'temperatura_c')::numeric), 2) AS temp_promedio_c,
       MAX((l ->> 'personas')::int)                    AS max_personas
FROM evento e,
     jsonb_array_elements(e.datos_iot -> 'lecturas') AS l
GROUP BY e.titulo_evento;

-- d) Filtrar por tipo de sensor
SELECT titulo_evento
FROM evento
WHERE datos_iot @> '{"dispositivo": {"tipo": "contador_aforo"}}';

-- Índice GIN para consultas sobre el JSONB
CREATE INDEX IF NOT EXISTS idx_evento_datos_iot
    ON evento USING GIN (datos_iot);

-- 2.4.- Describir el campo y explicar su propósito
COMMENT ON COLUMN evento.datos_iot IS
    'JSONB con datos de sensores IoT del evento: dispositivo, lecturas (aforo, temperatura, humedad) y alertas.';

SELECT column_name, data_type, is_nullable,
       col_description('evento'::regclass, ordinal_position) AS descripcion
FROM information_schema.columns
WHERE table_name = 'evento' AND column_name = 'datos_iot';


COMMIT;
