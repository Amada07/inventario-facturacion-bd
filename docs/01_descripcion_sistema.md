# Descripción del sistema

## Negocio

El sistema controla una **ferretería**: su catálogo de productos, sus proveedores y clientes, las compras de mercadería y las ventas facturadas. La base de datos es relacional y está implementada en **Oracle Database 21c XE**, en el esquema `FERRETERIADB`.

- **Qué se vende:** herramientas manuales y eléctricas, plomería, electricidad, pinturas y acabados, tornillería y fijación, materiales de construcción y seguridad industrial (8 categorías).
- **Cómo se factura:** cada factura tiene un encabezado (número, fecha, cliente, empleado que la emite, forma de pago y totales) y un detalle línea por línea (producto, cantidad, precio unitario y subtotal). Se aplica IVA del 12 %.
- **Cómo se controla el stock:** cada producto tiene su existencia actual y una existencia mínima. Las compras recibidas suman al inventario y las facturas pagadas lo descuentan; cada movimiento queda registrado en un kárdex con su saldo.

## Reglas de negocio

1. El NIT del cliente es único y el código de barras del producto es único.
2. Un producto pertenece a una categoría, una marca, una unidad de medida y un proveedor.
3. Precios, cantidades, subtotales y totales deben ser mayores que 0; el stock no puede ser negativo.
4. No se puede vender más de lo que hay: el stock no puede quedar negativo (`CHECK (Stock_Actual >= 0)`) y cada venta pagada se descuenta del inventario. Además, el trigger `TRG_FACTDET_VALIDA_STOCK` y el procedimiento de facturación rechazan la venta con el mensaje `ORA-20001`.
5. El IVA es el 12 % del subtotal y el total es subtotal más impuesto (restricción `CHECK` en los encabezados).
6. Una factura o una compra no repite un mismo producto en dos líneas (`UNIQUE` sobre documento y producto).
7. Las facturas pasan por los estados PENDIENTE, PAGADO o ANULADO; las compras por PENDIENTE, RECIBIDA o ANULADA. Solo las compras RECIBIDA suman stock y solo las facturas PAGADO lo restan.
8. El stock actual de cada producto coincide con el saldo del último movimiento de su kárdex.
9. Cada compra incluye únicamente productos que suministra el proveedor de esa compra.
10. Al borrar un encabezado se borran sus líneas de detalle; el resto de las llaves foráneas impide borrar registros que tienen datos relacionados.

## Módulos

| Módulo | Qué cubre | Tablas |
|---|---|---|
| Catálogo | Categorías, marcas, unidades de medida, proveedores y clientes | `CATEGORIAS`, `MARCAS`, `UNIDADES_MEDIDA`, `PROVEEDORES`, `CLIENTES` |
| Control de existencias | Productos con precio de compra, precio de venta y stock; kárdex de movimientos | `PRODUCTOS`, `MOVIMIENTOS_INVENTARIO` |
| Compras | Entradas de mercadería por proveedor | `COMPRAS_ENCABEZADO`, `COMPRAS_DETALLE` |
| Facturación | Facturas con detalle y forma de pago | `METODOS_PAGO`, `FACTURAS_ENCABEZADO`, `FACTURAS_DETALLE` |
| Seguridad y operación | Empleados y cuentas de usuario | `EMPLEADOS`, `USUARIOS` |
| Reportes | Bajo stock, ventas por cliente y por producto, compras por proveedor, productos nunca vendidos, ventas por fecha | consultas de [`sql/04_consultas_reportes.sql`](../sql/04_consultas_reportes.sql) |
| Lógica automática | Validación de stock, cálculo de totales, registro de facturas y compras, vistas de apoyo | triggers, procedimientos y vistas de [`sql/05_logica_automatica.sql`](../sql/05_logica_automatica.sql) |

El modelo mínimo del enunciado tiene 6 tablas (3 de catálogo y 3 transaccionales). Esta implementación lo amplía a **14 tablas** para registrar las compras a proveedores (`COMPRAS_ENCABEZADO` y `COMPRAS_DETALLE`), las formas de pago, el kárdex, los empleados y los usuarios. Como existe la tabla de compras, el reporte «compras por proveedor» se resuelve con las compras reales y no con el inventario valorizado. Las ampliaciones se justifican en [03_justificacion_relaciones.md](03_justificacion_relaciones.md) y [04_normalizacion.md](04_normalizacion.md).

## Lógica automática

El script [`sql/05_logica_automatica.sql`](../sql/05_logica_automatica.sql) automatiza la actualización del stock y de los totales:

| Objeto | Qué hace |
|---|---|
| `TRG_FACTDET_VALIDA_STOCK` | Impide vender más unidades que el stock disponible |
| `TRG_FACTDET_TOTALES` | Recalcula subtotal, IVA y total de la factura cuando cambian sus líneas |
| `TRG_COMPDET_TOTALES` | Hace lo mismo para las compras |
| `SP_REGISTRAR_FACTURA` | Valida las líneas y el stock, calcula los totales, crea la factura, descuenta el stock y registra la salida en el kárdex |
| `SP_REGISTRAR_COMPRA` | Valida las líneas y que los productos sean del proveedor, calcula los totales, crea la compra, suma el stock y registra la entrada en el kárdex |
| `VW_HISTORIAL_OPERACIONES` | Historial de compras por proveedor y ventas por cliente, con acumulado |
| `VW_INVENTARIO_CRITICO` | Productos con stock igual o menor al mínimo y su proveedor, para reabastecer |

Los procedimientos reciben las líneas con los tipos `T_LINEAS_VENTA` y `T_LINEAS_COMPRA`. El número de factura (`FAC-0001`…) y de compra (`COMP-0001`…) se genera automáticamente.

## Datos de prueba

| Dato | Cargados | Mínimo sugerido |
|---|---|---|
| Categorías | 8 | 5 |
| Proveedores | 15 | 5 |
| Clientes | 18 | 10 |
| Productos | 30 (7 con stock igual o menor al mínimo, 1 agotado) | 30 |
| Facturas | 14 (12 PAGADO, 1 PENDIENTE, 1 ANULADO) | 10 |
| Líneas de detalle de factura | 39 | 30 |

Además se cargan 17 compras con 34 líneas (15 RECIBIDA, 1 PENDIENTE y 1 ANULADA), 66 movimientos de kárdex, 15 empleados, 15 usuarios, 8 marcas, 7 unidades de medida y 5 formas de pago. Incluyen casos límite: un producto agotado, 4 clientes sin facturas y 3 proveedores sin compras (sirven para probar `LEFT JOIN`).

## Tecnología

| Elemento | Detalle |
|---|---|
| Motor | Oracle Database 21c XE |
| Esquema | `FERRETERIADB` |
| Clientes SQL usados | DBeaver 25.2.0 y SQL*Plus 21.3 |
| Diagramas | Graphviz (fuente en [`diagramas/`](../diagramas/)) |
