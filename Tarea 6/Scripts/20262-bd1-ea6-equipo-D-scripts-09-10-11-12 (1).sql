
-- ---------------------------------------------------------------------------------------------------------------------------------
-- 9.- Enunciado para creación de Vista (VIEW) con 4 JOINs, GROUP BY y HAVING
-- Construya una vista (VIEW) con el enunciado del ítem 7. Debe crear la vista (darle un nombre) y ejecutarla.
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Mismo reporte del ítem 7 (5 tablas, 4 JOINs y mismos filtros), agrupado por tipo de usuario
-- comprador y categoría. HAVING: solo grupos con 2 o más compras.

DROP VIEW IF EXISTS vw_reporte_ventas_consolidado;

CREATE VIEW vw_reporte_ventas_consolidado AS
SELECT tu.nombre_tipo_usuario                           AS tipo_usuario,
       tp.nombre_tipo_producto                          AS categoria_producto,
       COUNT(*)                                         AS total_compras,
       SUM(cp.cantidad)                                 AS unidades_vendidas,
       SUM(cp.cantidad * p.precio_producto)             AS total_pagado,
       ROUND(AVG(cp.cantidad * p.precio_producto), 2)   AS promedio_por_compra,
       MIN(cp.cantidad * p.precio_producto)             AS compra_minima,
       MAX(cp.cantidad * p.precio_producto)             AS compra_maxima
FROM compra_producto cp
INNER JOIN producto p       ON p.id_producto       = cp.id_producto           -- JOIN 1
INNER JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto       -- JOIN 2
INNER JOIN usuario u        ON u.id_usuario        = cp.id_usuario_comprador  -- JOIN 3
INNER JOIN tipo_usuario tu  ON tu.id_tipo_usuario  = u.id_tipo_usuario        -- JOIN 4
WHERE tu.nombre_tipo_usuario IN ('Egresado', 'Estudiante')
  AND cp.cantidad * p.precio_producto > 100000
GROUP BY tu.nombre_tipo_usuario, tp.nombre_tipo_producto
HAVING COUNT(*) >= 2;

-- Ejecutar la vista
SELECT *
FROM vw_reporte_ventas_consolidado
ORDER BY total_pagado DESC
LIMIT 20;   -- muestra solo las primeras 20 filas


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 10.- Ejercicio del enunciado para consulta parametrizada (PREPARE / EXECUTE) con 4 JOINs (GROUP BY y HAVING)
-- ---------------------------------------------------------------------------------------------------------------------------------


WITH eventos_prueba AS (
    SELECT id_evento, id_usuario_organizador, fecha_hora_inicio
    FROM (SELECT e.*, ROW_NUMBER() OVER (PARTITION BY id_tipo_evento ORDER BY id_evento) AS n
          FROM evento e
          WHERE id_tipo_evento IN (2, 3) AND fecha_hora_inicio > DATE '2027-01-01'
            AND cupo_maximo >= 40) x
    WHERE n <= 5
)
INSERT INTO asistencia_evento (id_usuario, id_evento, fecha_registro, estado_asistencia)
SELECT u.id_usuario, ep.id_evento, LOCALTIMESTAMP, 'Inscrito'
FROM eventos_prueba ep
CROSS JOIN LATERAL (
    SELECT id_usuario FROM usuario
    WHERE id_rol = 3 AND estado_usuario = 'Activo' AND id_usuario <> ep.id_usuario_organizador
    ORDER BY id_usuario
    LIMIT 15
) u
ON CONFLICT (id_usuario, id_evento) DO UPDATE SET estado_asistencia = 'Inscrito';

PREPARE stmt_analisis_participacion_eventos (INT, DATE) AS
SELECT u.id_usuario                              AS id_organizador,
       u.nombres || ' ' || u.apellidos           AS organizador,
       tu.nombre_tipo_usuario                    AS tipo_usuario_organizador,
       te.nombre_tipo_evento                     AS tipo_evento,
       COUNT(DISTINCT e.id_evento)               AS total_eventos,
       COUNT(*)                                  AS participantes_confirmados
FROM asistencia_evento ae
INNER JOIN evento e         ON e.id_evento         = ae.id_evento
INNER JOIN tipo_evento te   ON te.id_tipo_evento   = e.id_tipo_evento
INNER JOIN usuario u        ON u.id_usuario        = e.id_usuario_organizador
INNER JOIN tipo_usuario tu  ON tu.id_tipo_usuario  = u.id_tipo_usuario
WHERE e.id_tipo_evento = $1
  AND e.fecha_hora_inicio >= $2
  AND ae.estado_asistencia IN ('Inscrito', 'Asistió')
GROUP BY u.id_usuario, u.nombres, u.apellidos, tu.nombre_tipo_usuario,
         te.id_tipo_evento, te.nombre_tipo_evento
HAVING COUNT(*) >= 10
ORDER BY participantes_confirmados DESC, id_organizador;

EXECUTE stmt_analisis_participacion_eventos(2, DATE '2026-01-01');

EXECUTE stmt_analisis_participacion_eventos(3, DATE '2027-01-01');

EXPLAIN (ANALYZE, BUFFERS)
EXECUTE stmt_analisis_participacion_eventos(2, DATE '2026-01-01');

DEALLOCATE stmt_analisis_participacion_eventos;


-- ---------------------------------------------------------------------------------------------------------------------------------
--11.- Ejercicio del enunciado para Evaluación Experimental de Rendimiento con ANALYZE
-- ---------------------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS usuario_1000;
CREATE TABLE usuario_1000 (
    id_usuario      INTEGER PRIMARY KEY,
    nombres         VARCHAR(100) NOT NULL,
    id_tipo_usuario INTEGER NOT NULL,
    fecha_registro  TIMESTAMP NOT NULL
);

INSERT INTO usuario_1000
SELECT g,
       (ARRAY['Juan','María','Carlos','Laura','Andrés','Sofía'])[1 + floor(random() * 6)::int],
       1 + floor(random() * 9)::int,
       TIMESTAMP '2024-01-01' + random() * (TIMESTAMP '2026-12-31' - TIMESTAMP '2024-01-01')
FROM generate_series(1, 1000) AS g;

DROP TABLE IF EXISTS usuario_100000;
CREATE TABLE usuario_100000 (LIKE usuario_1000 INCLUDING ALL);

INSERT INTO usuario_100000
SELECT g,
       (ARRAY['Juan','María','Carlos','Laura','Andrés','Sofía'])[1 + floor(random() * 6)::int],
       1 + floor(random() * 9)::int,
       TIMESTAMP '2024-01-01' + random() * (TIMESTAMP '2026-12-31' - TIMESTAMP '2024-01-01')
FROM generate_series(1, 100000) AS g;

ANALYZE usuario_1000;
ANALYZE usuario_100000;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_usuarios,
       MIN(fecha_registro) AS primer_registro, MAX(fecha_registro) AS ultimo_registro
FROM usuario_1000
WHERE fecha_registro >= TIMESTAMP '2026-01-01'
  AND fecha_registro <  TIMESTAMP '2026-02-01'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_usuarios,
       MIN(fecha_registro) AS primer_registro, MAX(fecha_registro) AS ultimo_registro
FROM usuario_100000
WHERE fecha_registro >= TIMESTAMP '2026-01-01'
  AND fecha_registro <  TIMESTAMP '2026-02-01'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

CREATE INDEX idx_usuario_1000_fecha   ON usuario_1000   (fecha_registro);
CREATE INDEX idx_usuario_100000_fecha ON usuario_100000 (fecha_registro);
ANALYZE usuario_1000;
ANALYZE usuario_100000;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_usuarios,
       MIN(fecha_registro) AS primer_registro, MAX(fecha_registro) AS ultimo_registro
FROM usuario_1000
WHERE fecha_registro >= TIMESTAMP '2026-01-01'
  AND fecha_registro <  TIMESTAMP '2026-02-01'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_usuarios,
       MIN(fecha_registro) AS primer_registro, MAX(fecha_registro) AS ultimo_registro
FROM usuario_100000
WHERE fecha_registro >= TIMESTAMP '2026-01-01'
  AND fecha_registro <  TIMESTAMP '2026-02-01'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.- Enunciado para Validación de Propiedades ACID en 4 Tablas del DDL
-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.1.- Atomicidad (Atomicity)
-- ---------------------------------------------------------------------------------------------------------------------------------

ROLLBACK;

BEGIN;
DROP TABLE IF EXISTS acid_datos, acid_antes;
CREATE TEMP TABLE acid_datos AS
SELECT p.id_producto, p.id_usuario_vendedor AS id_vendedor, u.id_usuario AS id_comprador
FROM (SELECT id_producto, id_usuario_vendedor FROM producto
      WHERE estado_producto = 'Disponible' ORDER BY id_producto ASC LIMIT 1) p
JOIN usuario u ON u.id_usuario <> p.id_usuario_vendedor
WHERE u.id_rol = 3 AND u.estado_usuario = 'Activo'
  AND NOT EXISTS (SELECT 1 FROM compra_producto c
                  WHERE c.id_usuario_comprador = u.id_usuario AND c.id_producto = p.id_producto)
ORDER BY u.id_usuario
LIMIT 1;

CREATE TEMP TABLE acid_antes AS
SELECT '1. ANTES'::text AS momento, u.id_usuario, u.estado_usuario, p.id_producto, p.estado_producto,
       (SELECT count(*) FROM compra_producto) AS total_compras,
       (SELECT count(*) FROM notificacion)    AS total_notificaciones
FROM acid_datos d
JOIN usuario u  ON u.id_usuario  = d.id_comprador
JOIN producto p ON p.id_producto = d.id_producto;
COMMIT;

BEGIN;

UPDATE usuario SET estado_usuario = 'Suspendido'
WHERE id_usuario = (SELECT id_comprador FROM acid_datos);

UPDATE producto SET estado_producto = 'Vendido'
WHERE id_producto = (SELECT id_producto FROM acid_datos);

INSERT INTO notificacion (id_usuario, titulo_notificacion, fecha_envio)
SELECT id_vendedor, 'PRUEBA-ATOMICIDAD', LOCALTIMESTAMP FROM acid_datos;

SAVEPOINT sp_antes_compra;

DO $$
BEGIN
    INSERT INTO compra_producto (id_usuario_comprador, id_producto, fecha_compra, cantidad)
    SELECT 999999, id_producto, LOCALTIMESTAMP, 1 FROM acid_datos;
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Falla en la compra (clave foránea): %', SQLERRM;
END
$$;

ROLLBACK;

SELECT * FROM acid_antes
UNION ALL
SELECT '2. DESPUÉS DEL ROLLBACK'::text AS momento, u.id_usuario, u.estado_usuario, p.id_producto, p.estado_producto,
       (SELECT count(*) FROM compra_producto) AS total_compras,
       (SELECT count(*) FROM notificacion)    AS total_notificaciones
FROM acid_datos d
JOIN usuario u  ON u.id_usuario  = d.id_comprador
JOIN producto p ON p.id_producto = d.id_producto
ORDER BY momento;


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.2.- Consistencia (Consistency)
-- ---------------------------------------------------------------------------------------------------------------------------------

ROLLBACK;

BEGIN;

DROP TABLE IF EXISTS resultado_consistencia;
CREATE TEMP TABLE resultado_consistencia (
    prueba INT, tabla TEXT, restriccion TEXT, resultado TEXT, mensaje_postgresql TEXT
);

DO $$
BEGIN
    BEGIN
        UPDATE producto SET precio_producto = -5000 WHERE id_producto = 1;
        RAISE EXCEPTION 'El CHECK no rechazó el precio negativo';
    EXCEPTION WHEN check_violation THEN
        INSERT INTO resultado_consistencia
        VALUES (1, 'producto', 'CHECK precio_producto >= 0', 'RECHAZADA', SQLERRM);
    END;

    BEGIN
        INSERT INTO compra_producto (id_usuario_comprador, id_producto, fecha_compra, cantidad)
        VALUES (1, 999999, LOCALTIMESTAMP, 1);
        RAISE EXCEPTION 'La FOREIGN KEY no rechazó la compra';
    EXCEPTION WHEN foreign_key_violation THEN
        INSERT INTO resultado_consistencia
        VALUES (2, 'compra_producto', 'FOREIGN KEY id_producto', 'RECHAZADA', SQLERRM);
    END;

    BEGIN
        UPDATE usuario SET nombres = NULL WHERE id_usuario = 1;
        RAISE EXCEPTION 'El NOT NULL no rechazó el valor nulo';
    EXCEPTION WHEN not_null_violation THEN
        INSERT INTO resultado_consistencia
        VALUES (3, 'usuario', 'NOT NULL nombres', 'RECHAZADA', SQLERRM);
    END;
END
$$;

SAVEPOINT sp_consistencia;

UPDATE producto SET precio_producto = precio_producto + 1000 WHERE id_producto = 1;

ROLLBACK TO SAVEPOINT sp_consistencia;

COMMIT;

SELECT * FROM resultado_consistencia ORDER BY prueba;


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.3.- Aislamiento (Isolation)
-- ---------------------------------------------------------------------------------------------------------------------------------

-- ESCENARIO 1: READ COMMITTED
-- Sesión A:  BEGIN ISOLATION LEVEL READ COMMITTED;
-- Sesión A:  SELECT precio_producto FROM producto WHERE id_producto = 1;
-- Sesión B:  UPDATE producto SET precio_producto = precio_producto + 1000 WHERE id_producto = 1;
-- Sesión A:  SELECT precio_producto FROM producto WHERE id_producto = 1;
-- Sesión A:  COMMIT;

-- ESCENARIO 2: REPEATABLE READ
-- Sesión A:  BEGIN ISOLATION LEVEL REPEATABLE READ;
-- Sesión A:  SELECT precio_producto FROM producto WHERE id_producto = 1;
-- Sesión B:  UPDATE producto SET precio_producto = precio_producto + 1000 WHERE id_producto = 1;
-- Sesión A:  SELECT precio_producto FROM producto WHERE id_producto = 1;
-- Sesión A:  COMMIT;

-- UPDATE producto SET precio_producto = precio_producto - 2000 WHERE id_producto = 1;


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.4.- Durabilidad (Durability)
-- ---------------------------------------------------------------------------------------------------------------------------------

ROLLBACK;

BEGIN;
DROP TABLE IF EXISTS acid_durabilidad;
CREATE TEMP TABLE acid_durabilidad AS
SELECT p.id_producto, p.id_usuario_vendedor AS id_vendedor, u.id_usuario AS id_comprador
FROM (SELECT id_producto, id_usuario_vendedor FROM producto
      WHERE estado_producto = 'Disponible' ORDER BY id_producto DESC LIMIT 1) p
JOIN usuario u ON u.id_usuario <> p.id_usuario_vendedor
WHERE u.id_rol = 3 AND u.estado_usuario = 'Activo'
  AND NOT EXISTS (SELECT 1 FROM compra_producto c
                  WHERE c.id_usuario_comprador = u.id_usuario AND c.id_producto = p.id_producto)
ORDER BY u.id_usuario
LIMIT 1;
COMMIT;

BEGIN;

INSERT INTO compra_producto (id_usuario_comprador, id_producto, fecha_compra, cantidad)
SELECT id_comprador, id_producto, LOCALTIMESTAMP, 1 FROM acid_durabilidad;

UPDATE producto SET estado_producto = 'Vendido'
WHERE id_producto = (SELECT id_producto FROM acid_durabilidad);

INSERT INTO notificacion (id_usuario, titulo_notificacion, mensaje_notificacion, fecha_envio)
SELECT id_vendedor, 'PRUEBA-DURABILIDAD', 'Se vendió el producto ' || id_producto, LOCALTIMESTAMP
FROM acid_durabilidad;

SAVEPOINT sp_venta_registrada;

UPDATE usuario SET estado_usuario = 'Suspendido'
WHERE id_usuario = (SELECT id_comprador FROM acid_durabilidad);

ROLLBACK TO SAVEPOINT sp_venta_registrada;

COMMIT;

-- SELECT pg_terminate_backend(pg_backend_pid());

SELECT cp.id_usuario_comprador, u.estado_usuario, cp.id_producto, cp.fecha_compra,
       p.estado_producto, n.id_notificacion,
       current_setting('fsync')              AS fsync,
       current_setting('synchronous_commit') AS synchronous_commit,
       pg_current_wal_lsn()                  AS posicion_wal
FROM notificacion n
JOIN producto p         ON n.mensaje_notificacion = 'Se vendió el producto ' || p.id_producto
JOIN compra_producto cp ON cp.id_producto = p.id_producto
JOIN usuario u          ON u.id_usuario = cp.id_usuario_comprador
WHERE n.titulo_notificacion = 'PRUEBA-DURABILIDAD'
ORDER BY n.id_notificacion DESC, cp.fecha_compra DESC
LIMIT 1;
