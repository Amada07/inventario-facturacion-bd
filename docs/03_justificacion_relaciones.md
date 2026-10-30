# Justificación de las relaciones

Todas las relaciones son de uno a muchos (1:N) y se implementan con una llave foránea en la tabla del lado «muchos». Diagrama completo: [modelo_er.png](img/modelo_er.png) y [modelo_relacional.png](img/modelo_relacional.png).

| # | Relación (1 → N) | Llave foránea | Cardinalidad | Regla de negocio que la origina |
|---|---|---|---|---|
| 1 | `CATEGORIAS` → `PRODUCTOS` | `PRODUCTOS.ID_Categoria` | Una categoría agrupa muchos productos; cada producto tiene una sola categoría | Los productos se organizan por tipo |
| 2 | `MARCAS` → `PRODUCTOS` | `PRODUCTOS.ID_Marca` | Una marca identifica muchos productos; cada producto tiene una marca | Evita repetir el nombre y el país de la marca en cada producto |
| 3 | `UNIDADES_MEDIDA` → `PRODUCTOS` | `PRODUCTOS.ID_Unidad` | Una unidad mide muchos productos; cada producto se vende en una unidad | Cada producto se vende por unidad, metro, galón, etc. |
| 4 | `PROVEEDORES` → `PRODUCTOS` | `PRODUCTOS.ID_Proveedor` | Un proveedor suministra muchos productos; cada producto tiene un proveedor | Se sabe a quién reabastecer cada producto |
| 5 | `PROVEEDORES` → `COMPRAS_ENCABEZADO` | `COMPRAS_ENCABEZADO.ID_Proveedor` | Un proveedor puede tener muchas compras; cada compra es de un proveedor | Cada compra se hace a un solo proveedor |
| 6 | `EMPLEADOS` → `COMPRAS_ENCABEZADO` | `COMPRAS_ENCABEZADO.ID_Empleado` | Un empleado registra muchas compras | Se deja constancia de quién registró la compra |
| 7 | `COMPRAS_ENCABEZADO` → `COMPRAS_DETALLE` | `COMPRAS_DETALLE.ID_Compra` | Una compra tiene una o más líneas (`ON DELETE CASCADE`) | El detalle no existe sin su encabezado |
| 8 | `PRODUCTOS` → `COMPRAS_DETALLE` | `COMPRAS_DETALLE.ID_Producto` | Un producto aparece en muchas líneas de compra | Se compra el mismo producto en distintas fechas |
| 9 | `CLIENTES` → `FACTURAS_ENCABEZADO` | `FACTURAS_ENCABEZADO.ID_Cliente` | Un cliente puede tener muchas facturas; cada factura es de un cliente | Se factura a un cliente identificado por su NIT |
| 10 | `EMPLEADOS` → `FACTURAS_ENCABEZADO` | `FACTURAS_ENCABEZADO.ID_Empleado` | Un empleado emite muchas facturas | Se deja constancia de quién vendió |
| 11 | `METODOS_PAGO` → `FACTURAS_ENCABEZADO` | `FACTURAS_ENCABEZADO.ID_Metodo_Pago` | Una forma de pago se usa en muchas facturas | Permite el cierre de caja por forma de pago |
| 12 | `FACTURAS_ENCABEZADO` → `FACTURAS_DETALLE` | `FACTURAS_DETALLE.ID_Factura` | Una factura tiene una o más líneas (`ON DELETE CASCADE`) | El detalle no existe sin su encabezado |
| 13 | `PRODUCTOS` → `FACTURAS_DETALLE` | `FACTURAS_DETALLE.ID_Producto` | Un producto aparece en muchas líneas de factura | Un producto se vende muchas veces |
| 14 | `PRODUCTOS` → `MOVIMIENTOS_INVENTARIO` | `MOVIMIENTOS_INVENTARIO.ID_Producto` | Un producto tiene muchos movimientos de kárdex | Se conserva el historial de cada producto |
| 15 | `COMPRAS_ENCABEZADO` → `MOVIMIENTOS_INVENTARIO` | `MOVIMIENTOS_INVENTARIO.ID_Compra` (opcional) | Una compra origina uno o más movimientos de ENTRADA | Cada entrada de inventario nace de una compra |
| 16 | `FACTURAS_ENCABEZADO` → `MOVIMIENTOS_INVENTARIO` | `MOVIMIENTOS_INVENTARIO.ID_Factura` (opcional) | Una factura origina uno o más movimientos de SALIDA | Cada salida de inventario nace de una factura |
| 17 | `EMPLEADOS` → `USUARIOS` | `USUARIOS.ID_Empleado` | Un empleado puede tener cuentas de usuario (en los datos de prueba, una por empleado; `ON DELETE CASCADE`) | La cuenta de acceso pertenece a un empleado |

## Por qué `FACTURAS_DETALLE` es la tabla puente

Entre facturas y productos hay una relación **muchos a muchos**: una factura incluye varios productos y un producto se vende en muchas facturas. Una relación así no se puede guardar con una sola llave foránea, por eso se descompone en dos relaciones 1:N a través de `FACTURAS_DETALLE`:

- `FACTURAS_ENCABEZADO` 1:N `FACTURAS_DETALLE` (relación 12).
- `PRODUCTOS` 1:N `FACTURAS_DETALLE` (relación 13).

Cada fila del detalle es una pareja (factura, producto) y guarda lo que pertenece a esa pareja: cantidad, precio unitario y subtotal. La restricción `UNIQUE (ID_Factura, ID_Producto)` impide repetir el producto dentro de una misma factura. El precio unitario se guarda en la línea porque es el precio **al momento de la venta**: si el precio de venta del producto cambia después, las facturas anteriores no se alteran.

`COMPRAS_DETALLE` cumple el mismo papel entre `COMPRAS_ENCABEZADO` y `PRODUCTOS`.

## Tabla `MOVIMIENTOS_INVENTARIO` (kárdex)

Tiene dos llaves foráneas opcionales, `ID_Compra` e `ID_Factura`. La restricción `CK_MOV_ORIGEN` obliga a que una ENTRADA tenga compra y no factura, y que una SALIDA tenga factura y no compra. Así cada movimiento tiene exactamente un documento de origen y es posible auditar el stock de cualquier producto.

## Tablas agregadas respecto al modelo mínimo

| Tabla | Por qué se agrega |
|---|---|
| `COMPRAS_ENCABEZADO` y `COMPRAS_DETALLE` | Registran las entradas de inventario por proveedor; permiten el reporte «compras por proveedor» con datos reales |
| `METODOS_PAGO` | Catálogo de formas de pago; evita escribir el texto en cada factura |
| `MARCAS` y `UNIDADES_MEDIDA` | Catálogos que evitan repetir texto en `PRODUCTOS` |
| `MOVIMIENTOS_INVENTARIO` | Historial de entradas y salidas con su saldo |
| `EMPLEADOS` y `USUARIOS` | Registran quién compra y vende, y el acceso al sistema |
