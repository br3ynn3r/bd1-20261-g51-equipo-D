--
-- Scripts - 8.- Enunciados para Consultas con Funciones de Agregación

-- ---------------------------------------------------------------------------------------------------------------------------------
-- Script del Enunciado 8.1 — Función COUNT: Volumen Global de Solicitudes de Servicio
-- Calcular la cantidad total de solicitudes de servicios registradas en la plataforma agrupadas por el estado de la transacción (Completado, Pendiente, Cancelado). 
-- ---------------------------------------------------------------------------------------------------------------------------------
-- En la base de datos los estados se guardan en femenino (Completada, Cancelada).
-- Además existen 'Aceptada' y 'Rechazada'. Para que el volumen sea GLOBAL se muestran
-- todos los estados y ROLLUP agrega la fila del total general.

SELECT CASE WHEN GROUPING(estado_solicitud) = 1 THEN 'TOTAL GENERAL'
            ELSE estado_solicitud
       END            AS estado,
       COUNT(*)       AS total_solicitudes
FROM solicitud_servicio
GROUP BY ROLLUP (estado_solicitud)
ORDER BY GROUPING(estado_solicitud), total_solicitudes DESC;

-- Variante: únicamente los tres estados nombrados en el enunciado
SELECT estado_solicitud AS estado,
       COUNT(*)         AS total_solicitudes
FROM solicitud_servicio
WHERE estado_solicitud IN ('Completada', 'Pendiente', 'Cancelada')
GROUP BY estado_solicitud
ORDER BY total_solicitudes DESC;


-- ---------------------------------------------------------------------------------------------------------------------------------
-- Script del Enunciado 8.2 — Función SUM: Recaudo Comercial Total por Categoría de Producto
-- Calcular el monto total acumulado ($) en ventas de productos pertenecientes a la categoría 'Libros' y 'Tecnología/Computadores'.
-- ---------------------------------------------------------------------------------------------------------------------------------
-- En el catálogo las categorías se llaman 'Libro' (equivale a 'Libros')
-- y 'Computador' (equivale a 'Tecnología/Computadores').
-- ILIKE reconoce el nombre en singular o plural. LEFT JOIN muestra la categoría aunque
-- no tenga ventas (en ese caso aparece 0). ROLLUP agrega el total conjunto.

SELECT CASE WHEN GROUPING(tp.nombre_tipo_producto) = 1 THEN 'TOTAL AMBAS CATEGORÍAS'
            ELSE tp.nombre_tipo_producto
       END                                                  AS categoria,
       COALESCE(SUM(cp.cantidad), 0)                        AS unidades_vendidas,
       COALESCE(SUM(cp.cantidad * p.precio_producto), 0)    AS recaudo_total
FROM tipo_producto tp
LEFT JOIN producto p         ON p.id_tipo_producto = tp.id_tipo_producto
LEFT JOIN compra_producto cp ON cp.id_producto     = p.id_producto
WHERE tp.nombre_tipo_producto ILIKE 'libro%'
   OR tp.nombre_tipo_producto ILIKE '%computador%'
GROUP BY ROLLUP (tp.nombre_tipo_producto)
ORDER BY GROUPING(tp.nombre_tipo_producto), recaudo_total DESC;
