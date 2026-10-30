/* ==================================================================
   UNIVERSIDAD MARIANO GALVEZ DE GUATEMALA - BASE DE DATOS I
   PROYECTO FINAL: SISTEMA DE INVENTARIO Y FACTURACION (FERRETERIA)
   SGBD: Oracle Database 21c XE | Esquema: FERRETERIADB
   ------------------------------------------------------------------
   04_consultas_reportes.sql
   Ejecutar despues de 03_dml_datos_prueba.sql. Cada consulta lleva un
   comentario con su proposito y, cuando aplica, el resultado esperado
   con los datos de prueba iniciales.

   Criterio comun: solo cuentan las facturas en estado PAGADO y las
   compras en estado RECIBIDA (son las que mueven dinero e inventario).
   Los montos "sin IVA" suman el Subtotal del detalle.

   CONSULTAS MINIMAS DEL ENUNCIADO (6.4) Y DONDE ESTAN
   - Productos con bajo stock .................... Consulta 8
   - Productos con su categoria y proveedor (JOIN) .. Consulta 9
   - Factura completa con detalle y subtotales ..... Consulta 10
   - Ventas totales por cliente .................... Consulta 2
   - Ventas por producto (cantidad e ingreso) ...... Consulta 1
   - Compras / inventario valorizado por proveedor .. Consulta 3
   - Productos nunca vendidos (subconsulta) ........ Consulta 11
   - Ventas por rango de fechas (por mes) .......... Consulta 12
   - Funciones de agregacion con HAVING ............ Consultas 1, 3, 6 y 7
   Las consultas 4, 5, 6 y 7 son adicionales.
   ================================================================== */



/* ------------------------------------------------------------------
   CONSULTA 1: TOP DE PRODUCTOS MAS VENDIDOS EN UN RANGO DE FECHAS
   Rango: 1 de junio al 30 de septiembre de 2026 (cambiar las fechas
   para otro periodo). Solo productos con 5 o mas unidades vendidas.
   Esperado: 1) Cemento gris 42.5 kg, 215 uds, 21070.00
             2) Manguera de jardin, 160 uds, 1760.00
             3) Clavo de acero 3 pulg, 55 uds, 660.00
   ------------------------------------------------------------------ */
SELECT p.ID_Producto,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       SUM(fd.Cantidad)                 AS Unidades_Vendidas,
       SUM(fd.Subtotal)                 AS Monto_Generado,
       COUNT(DISTINCT fe.ID_Factura)    AS Facturas
  FROM FACTURAS_DETALLE fd
 INNER JOIN FACTURAS_ENCABEZADO fe ON fe.ID_Factura  = fd.ID_Factura
 INNER JOIN PRODUCTOS p            ON p.ID_Producto  = fd.ID_Producto
 INNER JOIN CATEGORIAS c           ON c.ID_Categoria = p.ID_Categoria
 WHERE fe.Estado = 'PAGADO'
   AND fe.Fecha_Emision >= DATE '2026-06-01'
   AND fe.Fecha_Emision <  DATE '2026-10-01'
 GROUP BY p.ID_Producto, p.Nombre_Producto, c.Nombre_Categoria
HAVING SUM(fd.Cantidad) >= 5
 ORDER BY Unidades_Vendidas DESC, Monto_Generado DESC
 FETCH FIRST 10 ROWS ONLY;


/* ------------------------------------------------------------------
   CONSULTA 2: REPORTE CONSOLIDADO POR CLIENTE
   Frecuencia de compra, total gastado y promedio por compra.
   LEFT JOIN: los clientes sin compras tambien aparecen (con 0).
   ------------------------------------------------------------------ */
SELECT cl.ID_Cliente,
       cl.NIT,
       cl.Nombre_Completo,
       COUNT(fe.ID_Factura)                  AS Frecuencia_Compra,
       NVL(SUM(fe.Total_Factura), 0)         AS Total_Gastado,
       NVL(ROUND(AVG(fe.Total_Factura), 2), 0) AS Promedio_Por_Compra,
       MAX(fe.Fecha_Emision)                 AS Ultima_Compra
  FROM CLIENTES cl
  LEFT JOIN FACTURAS_ENCABEZADO fe
         ON fe.ID_Cliente = cl.ID_Cliente
        AND fe.Estado = 'PAGADO'
 GROUP BY cl.ID_Cliente, cl.NIT, cl.Nombre_Completo
 ORDER BY Total_Gastado DESC, cl.Nombre_Completo;


/* ------------------------------------------------------------------
   CONSULTA 3: RESUMEN DE COMPRAS A PROVEEDORES POR CATEGORIA
   Acumulado de compras por proveedor, clasificado por la categoria
   de los productos comprados. HAVING: solo combinaciones proveedor-
   categoria con mas de Q 1,000 comprados (sin IVA).
   ------------------------------------------------------------------ */
SELECT pr.Nombre_Empresa                AS Proveedor,
       c.Nombre_Categoria               AS Categoria,
       COUNT(DISTINCT ce.ID_Compra)     AS Compras,
       SUM(cd.Cantidad)                 AS Unidades_Compradas,
       SUM(cd.Subtotal)                 AS Total_Sin_IVA,
       ROUND(AVG(cd.Precio_Unitario), 2) AS Precio_Promedio
  FROM COMPRAS_ENCABEZADO ce
 INNER JOIN COMPRAS_DETALLE cd ON cd.ID_Compra   = ce.ID_Compra
 INNER JOIN PRODUCTOS p        ON p.ID_Producto  = cd.ID_Producto
 INNER JOIN CATEGORIAS c       ON c.ID_Categoria = p.ID_Categoria
 INNER JOIN PROVEEDORES pr     ON pr.ID_Proveedor = ce.ID_Proveedor
 WHERE ce.Estado = 'RECIBIDA'
 GROUP BY pr.Nombre_Empresa, c.Nombre_Categoria
HAVING SUM(cd.Subtotal) > 1000
 ORDER BY pr.Nombre_Empresa, Total_Sin_IVA DESC;


/* ------------------------------------------------------------------
   CONSULTA 4: KARDEX / HISTORIAL DE MOVIMIENTOS DE UN PRODUCTO
   Ejemplo con el cemento (ID 13); cambiar el ID para otro producto.
   LEFT JOIN a compras y facturas: cada movimiento viene de una u otra.
   Esperado: ENTRADA 150 (COMP-0007) saldo 150; SALIDA 60 (FAC-0003) saldo 90;
             SALIDA 80 (FAC-0008) saldo 10; ENTRADA 100 (COMP-0013) saldo 110;
             SALIDA 75 (FAC-0010) saldo 35.
   ------------------------------------------------------------------ */
SELECT m.ID_Movimiento,
       p.Nombre_Producto,
       m.Fecha_Movimiento,
       m.Tipo_Movimiento,
       m.Cantidad,
       m.Saldo_Resultante,
       NVL(ce.Numero_Compra, fe.Numero_Factura) AS Documento,
       m.Observacion
  FROM MOVIMIENTOS_INVENTARIO m
 INNER JOIN PRODUCTOS p              ON p.ID_Producto = m.ID_Producto
  LEFT JOIN COMPRAS_ENCABEZADO ce    ON ce.ID_Compra  = m.ID_Compra
  LEFT JOIN FACTURAS_ENCABEZADO fe   ON fe.ID_Factura = m.ID_Factura
 WHERE m.ID_Producto = 13
 ORDER BY m.Fecha_Movimiento, m.ID_Movimiento;


/* ------------------------------------------------------------------
   CONSULTA 5: CIERRE DE CAJA POR FORMA DE PAGO
   Periodo: 1 de julio al 30 de septiembre de 2026 (cambiar fechas
   para otro cierre). LEFT JOIN: las formas de pago sin cobros
   tambien aparecen (Deposito Bancario, con 0).
   Esperado (total cobrado): Transferencia 13444.48, Efectivo 11016.32,
                             Cheque 9296.00, Tarjeta 5708.64, Deposito 0.
   ------------------------------------------------------------------ */
SELECT mp.Nombre_Metodo                          AS Forma_Pago,
       COUNT(fe.ID_Factura)                      AS Facturas,
       NVL(SUM(fe.Total_Factura), 0)             AS Total_Cobrado,
       NVL(ROUND(AVG(fe.Total_Factura), 2), 0)   AS Promedio_Por_Factura,
       ROUND(100 * RATIO_TO_REPORT(NVL(SUM(fe.Total_Factura), 0)) OVER (), 2) AS Porcentaje_Del_Cierre
  FROM METODOS_PAGO mp
  LEFT JOIN FACTURAS_ENCABEZADO fe
         ON fe.ID_Metodo_Pago = mp.ID_Metodo_Pago
        AND fe.Estado = 'PAGADO'
        AND fe.Fecha_Emision >= DATE '2026-07-01'
        AND fe.Fecha_Emision <  DATE '2026-10-01'
 GROUP BY mp.Nombre_Metodo
 ORDER BY Total_Cobrado DESC;


/* ------------------------------------------------------------------
   CONSULTA 6 (adicional): CLIENTES Y PROVEEDORES SIN OPERACIONES
   LEFT JOIN + HAVING COUNT = 0 para detectar registros sin movimiento.
   Esperado: 7 filas (4 clientes y 3 proveedores).
   ------------------------------------------------------------------ */
SELECT 'CLIENTE' AS Tipo, cl.Nombre_Completo AS Nombre, COUNT(fe.ID_Factura) AS Operaciones
  FROM CLIENTES cl
  LEFT JOIN FACTURAS_ENCABEZADO fe ON fe.ID_Cliente = cl.ID_Cliente
 GROUP BY cl.ID_Cliente, cl.Nombre_Completo
HAVING COUNT(fe.ID_Factura) = 0
UNION ALL
SELECT 'PROVEEDOR', pr.Nombre_Empresa, COUNT(ce.ID_Compra)
  FROM PROVEEDORES pr
  LEFT JOIN COMPRAS_ENCABEZADO ce ON ce.ID_Proveedor = pr.ID_Proveedor
 GROUP BY pr.ID_Proveedor, pr.Nombre_Empresa
HAVING COUNT(ce.ID_Compra) = 0
 ORDER BY 1, 2;


/* ------------------------------------------------------------------
   CONSULTA 7 (adicional): DESEMPENO DE VENDEDORES
   Facturas pagadas, total vendido, promedio, mayor y menor venta por
   empleado. HAVING: solo quienes tienen 2 o mas facturas.
   ------------------------------------------------------------------ */
SELECT e.ID_Empleado,
       e.Nombre_Completo,
       e.Puesto,
       COUNT(fe.ID_Factura)              AS Facturas,
       SUM(fe.Total_Factura)             AS Total_Vendido,
       ROUND(AVG(fe.Total_Factura), 2)   AS Promedio_Factura,
       MAX(fe.Total_Factura)             AS Mayor_Venta,
       MIN(fe.Total_Factura)             AS Menor_Venta
  FROM EMPLEADOS e
 INNER JOIN FACTURAS_ENCABEZADO fe ON fe.ID_Empleado = e.ID_Empleado
 WHERE fe.Estado = 'PAGADO'
 GROUP BY e.ID_Empleado, e.Nombre_Completo, e.Puesto
HAVING COUNT(fe.ID_Factura) >= 2
 ORDER BY Total_Vendido DESC;

/* ------------------------------------------------------------------
   CONSULTA 8: PRODUCTOS CON BAJO STOCK
   Productos cuyo stock actual es igual o menor a su minimo
   (Stock_Minimo), con su categoria y su proveedor para poder
   reabastecer. Faltante = unidades que faltan para llegar al minimo.
   Esperado con los datos iniciales: 7 productos; el primero es el
   casco de seguridad (stock 0, agotado).
   ------------------------------------------------------------------ */
SELECT p.ID_Producto,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       pr.Nombre_Empresa                AS Proveedor,
       p.Stock_Actual,
       p.Stock_Minimo,
       p.Stock_Minimo - p.Stock_Actual  AS Faltante
  FROM PRODUCTOS p
 INNER JOIN CATEGORIAS c   ON c.ID_Categoria  = p.ID_Categoria
 INNER JOIN PROVEEDORES pr ON pr.ID_Proveedor = p.ID_Proveedor
 WHERE p.Stock_Actual <= p.Stock_Minimo
 ORDER BY p.Stock_Actual, p.Nombre_Producto;


/* ------------------------------------------------------------------
   CONSULTA 9: LISTADO DE PRODUCTOS CON CATEGORIA Y PROVEEDOR
   INNER JOIN de PRODUCTOS con CATEGORIAS y PROVEEDORES: el catalogo
   completo con sus precios y su existencia.
   Esperado: 30 filas (los 30 productos del catalogo).
   ------------------------------------------------------------------ */
SELECT p.ID_Producto,
       p.Codigo_Barras,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       pr.Nombre_Empresa AS Proveedor,
       p.Precio_Compra,
       p.Precio_Venta,
       p.Stock_Actual
  FROM PRODUCTOS p
 INNER JOIN CATEGORIAS c   ON c.ID_Categoria  = p.ID_Categoria
 INNER JOIN PROVEEDORES pr ON pr.ID_Proveedor = p.ID_Proveedor
 ORDER BY c.Nombre_Categoria, p.Nombre_Producto;


/* ------------------------------------------------------------------
   CONSULTA 10: FACTURA COMPLETA
   Encabezado, cliente y detalle linea por linea con sus subtotales.
   Ejemplo con la factura FAC-0003; cambiar el numero para ver otra.
   Esperado: 3 lineas (cemento 60, cal 20 y clavos 15); subtotal
   6980.00, IVA 837.60 y total 7817.60.
   ------------------------------------------------------------------ */
SELECT fe.Numero_Factura,
       fe.Fecha_Emision,
       cl.NIT,
       cl.Nombre_Completo      AS Cliente,
       p.Nombre_Producto,
       fd.Cantidad,
       fd.Precio_Unitario,
       fd.Subtotal             AS Subtotal_Linea,
       fe.Subtotal             AS Subtotal_Factura,
       fe.Impuesto             AS IVA,
       fe.Total_Factura
  FROM FACTURAS_ENCABEZADO fe
 INNER JOIN CLIENTES cl          ON cl.ID_Cliente  = fe.ID_Cliente
 INNER JOIN FACTURAS_DETALLE fd  ON fd.ID_Factura  = fe.ID_Factura
 INNER JOIN PRODUCTOS p          ON p.ID_Producto  = fd.ID_Producto
 WHERE fe.Numero_Factura = 'FAC-0003'
 ORDER BY fd.ID_Detalle;


/* ------------------------------------------------------------------
   CONSULTA 11: PRODUCTOS NUNCA VENDIDOS (con subconsulta)
   NOT EXISTS con una subconsulta correlacionada: productos que no
   aparecen en ninguna factura PAGADO.
   Esperado con los datos iniciales: 10 filas (los productos 21 al 30,
   que solo tienen compra y todavia no se han facturado).
   ------------------------------------------------------------------ */
SELECT p.ID_Producto,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       p.Stock_Actual,
       p.Precio_Venta
  FROM PRODUCTOS p
 INNER JOIN CATEGORIAS c ON c.ID_Categoria = p.ID_Categoria
 WHERE NOT EXISTS (SELECT 1
                     FROM FACTURAS_DETALLE fd
                    INNER JOIN FACTURAS_ENCABEZADO fe ON fe.ID_Factura = fd.ID_Factura
                    WHERE fd.ID_Producto = p.ID_Producto
                      AND fe.Estado = 'PAGADO')
 ORDER BY c.Nombre_Categoria, p.Nombre_Producto;


/* ------------------------------------------------------------------
   CONSULTA 12: VENTAS POR RANGO DE FECHAS (por mes)
   Facturas PAGADO del 1 de junio al 31 de octubre de 2026, agrupadas
   por mes (cambiar las fechas para otro periodo).
   Esperado (facturas, total con IVA): 2026-06 3 / 10077.76,
   2026-07 3 / 5722.08, 2026-08 3 / 16226.56, 2026-09 2 / 17516.80,
   2026-10 1 / 4005.12.
   ------------------------------------------------------------------ */
SELECT TO_CHAR(fe.Fecha_Emision, 'YYYY-MM') AS Mes,
       COUNT(fe.ID_Factura)                 AS Facturas,
       SUM(fe.Subtotal)                     AS Total_Sin_IVA,
       SUM(fe.Impuesto)                     AS IVA,
       SUM(fe.Total_Factura)                AS Total_Vendido
  FROM FACTURAS_ENCABEZADO fe
 WHERE fe.Estado = 'PAGADO'
   AND fe.Fecha_Emision >= DATE '2026-06-01'
   AND fe.Fecha_Emision <  DATE '2026-11-01'
 GROUP BY TO_CHAR(fe.Fecha_Emision, 'YYYY-MM')
 ORDER BY Mes;
