-- ---------------------------------------------------------------------------------
-- Scripts - Enunciados 3, 4, 5, 6 y 7 DML para consultas Sin Join, 1 Join, 2 Join, 3 Join y 4 Join
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- 3.- Enunciado para Consulta sin JOIN
-- Análisis de Precios y Disponibilidad en Oferta de Productos
-- ---------------------------------------------------------------------------------

SELECT id_producto                          AS codigo_producto,
       nombre_producto                      AS titulo_descriptivo,
       precio_producto                      AS precio_venta,
       ROUND(precio_producto * 1.05, 2)     AS precio_con_recargo_5_por_ciento,
       estado_producto                      AS estado_disponibilidad
FROM producto
WHERE precio_producto BETWEEN 50000 AND 500000
  AND estado_producto = 'Disponible'
ORDER BY precio_producto DESC, id_producto
LIMIT 20;


-- ---------------------------------------------------------------------------------
-- 4.- Enunciado para consulta con 1 JOIN. 
-- Censo Institucional de Usuarios por Categoría
-- -----------------------------------------------------------------------------------

SELECT tu.nombre_tipo_usuario   AS categoria_institucional,
       COUNT(u.id_usuario)      AS total_usuarios
FROM usuario u
INNER JOIN tipo_usuario tu ON tu.id_tipo_usuario = u.id_tipo_usuario   -- JOIN 1
GROUP BY tu.id_tipo_usuario, tu.nombre_tipo_usuario
ORDER BY total_usuarios DESC, categoria_institucional;


-- ---------------------------------------------------------------------------------
-- 5.- Enunciado para consulta con 2 JOINs
-- Trazabilidad de Eventos Académicos y sus Organizadores
-- ---------------------------------------------------------------------------------

-- Filtro del enunciado: eventos programados en los años 2024 o 2025.
SELECT e.titulo_evento,
       te.nombre_tipo_evento               AS tipo_evento,
       e.fecha_hora_inicio                 AS fecha_realizacion,
       u.nombres || ' ' || u.apellidos     AS organizador,
       u.correo_institucional              AS correo_organizador
FROM evento e
INNER JOIN tipo_evento te ON te.id_tipo_evento = e.id_tipo_evento          -- JOIN 1
INNER JOIN usuario u      ON u.id_usuario      = e.id_usuario_organizador  -- JOIN 2
WHERE e.fecha_hora_inicio >= DATE '2024-01-01'
  AND e.fecha_hora_inicio <  DATE '2026-01-01'
ORDER BY e.fecha_hora_inicio, e.id_evento
LIMIT 20;   -- muestra solo las primeras 20 filas


-- ---------------------------------------------------------------------------------
-- 6.- Enunciado para consulta SELECT con 3 JOINs
-- Consumo de Servicios Académicos por Estudiantes Activos
-- ---------------------------------------------------------------------------------

-- En la tabla el estado se guarda como 'Completada' (equivale a 'Completado').
-- 'servicio_solicitud' corresponde a la tabla solicitud_servicio.
SELECT u.nombres || ' ' || u.apellidos     AS estudiante_solicitante,
       s.titulo_servicio                   AS nombre_servicio,
       ts.nombre_tipo_servicio             AS categoria_servicio,
       ss.fecha_solicitud
FROM solicitud_servicio ss
INNER JOIN servicio s       ON s.id_servicio       = ss.id_servicio             -- JOIN 1
INNER JOIN tipo_servicio ts ON ts.id_tipo_servicio = s.id_tipo_servicio         -- JOIN 2
INNER JOIN usuario u        ON u.id_usuario        = ss.id_usuario_solicitante  -- JOIN 3
WHERE u.id_tipo_usuario = 1                 -- Estudiantes activos
  AND ss.estado_solicitud = 'Completada'
ORDER BY ss.fecha_solicitud DESC, u.id_usuario
LIMIT 20;   -- muestra solo las primeras 20 filas


-- ---------------------------------------------------------------------------------
-- 7.- Enunciado para consulta con 4 JOINs
-- Reporte Transaccional Consolidado de Venta de Productos
-- ---------------------------------------------------------------------------------

-- 'producto_transaccion' corresponde a la tabla compra_producto.
-- La tabla no guarda el valor pagado: se calcula como precio del producto x cantidad.
SELECT p.nombre_producto                     AS titulo_producto,
       tp.nombre_tipo_producto               AS categoria_producto,
       cp.cantidad * p.precio_producto       AS precio_pagado,
       u.nombres || ' ' || u.apellidos       AS comprador,
       tu.nombre_tipo_usuario                AS tipo_usuario,
       tu.descripcion_tipo                   AS descripcion_tipo_usuario
FROM compra_producto cp
INNER JOIN producto p       ON p.id_producto       = cp.id_producto           -- JOIN 1
INNER JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto       -- JOIN 2
INNER JOIN usuario u        ON u.id_usuario        = cp.id_usuario_comprador  -- JOIN 3
INNER JOIN tipo_usuario tu  ON tu.id_tipo_usuario  = u.id_tipo_usuario        -- JOIN 4
WHERE tu.nombre_tipo_usuario IN ('Egresado', 'Estudiante')
  AND cp.cantidad * p.precio_producto > 100000
ORDER BY precio_pagado DESC, comprador
LIMIT 20;   -- muestra solo las primeras 20 filas

