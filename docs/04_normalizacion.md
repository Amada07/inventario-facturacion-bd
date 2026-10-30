# Normalización hasta la tercera forma normal (3FN)

Se analiza el modelo de 14 tablas descrito en el [diccionario de datos](02_diccionario_datos.md). En todas las tablas la llave primaria es un identificador autonumérico; además existen llaves candidatas (columnas `UNIQUE`) que se indican en cada análisis.

## Primera forma normal (1FN)

**Regla:** todos los atributos son atómicos, no hay grupos repetitivos y cada tabla tiene llave primaria.

- Todas las tablas tienen llave primaria (`GENERATED ALWAYS AS IDENTITY`).
- No hay campos multivaluados: un producto no guarda una lista de proveedores ni una factura una lista de productos. Las listas se resuelven con tablas de detalle (`FACTURAS_DETALLE`, `COMPRAS_DETALLE`), una fila por línea.
- Los datos compuestos se guardan en campos separados (`Nombre_Categoria` y `Descripcion`, `Telefono` y `Correo`, etc.).

**Cumple 1FN.**

## Segunda forma normal (2FN)

**Regla:** está en 1FN y todo atributo no clave depende de **toda** la llave, no de una parte. Solo puede violarse con llaves compuestas.

Todas las tablas usan una llave primaria de una sola columna, por lo que no hay dependencias parciales. En las tablas de detalle la llave candidata compuesta es `(ID_Factura, ID_Producto)` o `(ID_Compra, ID_Producto)`; sus atributos dependen de la pareja completa:

| Tabla | Dependencia funcional |
|---|---|
| `FACTURAS_DETALLE` | `(ID_Factura, ID_Producto)` → `Cantidad`, `Precio_Unitario`, `Subtotal` |
| `COMPRAS_DETALLE` | `(ID_Compra, ID_Producto)` → `Cantidad`, `Precio_Unitario`, `Subtotal` |

La fecha, el cliente y la forma de pago dependen solo de la factura, y por eso están en `FACTURAS_ENCABEZADO` y no en el detalle. El nombre y la categoría dependen solo del producto, y están en `PRODUCTOS`.

**Cumple 2FN.**

## Tercera forma normal (3FN)

**Regla:** está en 2FN y ningún atributo no clave depende de otro atributo no clave (no hay dependencias transitivas).

Dependencias funcionales identificadas (la llave primaria determina el resto de la fila):

| Tabla | Dependencias funcionales |
|---|---|
| `CATEGORIAS` | `ID_Categoria` → `Nombre_Categoria`, `Descripcion` |
| `MARCAS` | `ID_Marca` → `Nombre_Marca`, `Pais_Origen` |
| `UNIDADES_MEDIDA` | `ID_Unidad` → `Nombre_Unidad`, `Abreviatura` |
| `PROVEEDORES` | `ID_Proveedor` → `Nombre_Empresa`, `Telefono`, `Correo`, `Contacto_Principal` |
| `CLIENTES` | `ID_Cliente` → `NIT`, `Nombre_Completo`, `Direccion`, `Telefono`, `Correo` |
| `EMPLEADOS` | `ID_Empleado` → `Nombre_Completo`, `Puesto`, `Telefono`, `Correo`, `Fecha_Ingreso` |
| `USUARIOS` | `ID_Usuario` → `Nombre_Usuario`, `Contrasena_Hash`, `Rol`, `ID_Empleado` |
| `PRODUCTOS` | `ID_Producto` → `Codigo_Barras`, `Nombre_Producto`, `Precio_Compra`, `Precio_Venta`, `Stock_Actual`, `Stock_Minimo`, `ID_Categoria`, `ID_Marca`, `ID_Unidad`, `ID_Proveedor` |
| `METODOS_PAGO` | `ID_Metodo_Pago` → `Nombre_Metodo` |
| `COMPRAS_ENCABEZADO` | `ID_Compra` → `Numero_Compra`, `Fecha_Compra`, `Estado`, `ID_Proveedor`, `ID_Empleado` (y los totales, ver abajo) |
| `FACTURAS_ENCABEZADO` | `ID_Factura` → `Numero_Factura`, `Fecha_Emision`, `Estado`, `ID_Cliente`, `ID_Empleado`, `ID_Metodo_Pago` (y los totales, ver abajo) |
| `MOVIMIENTOS_INVENTARIO` | `ID_Movimiento` → `ID_Producto`, `Fecha_Movimiento`, `Tipo_Movimiento`, `Cantidad`, `Saldo_Resultante`, `ID_Compra`, `ID_Factura`, `Observacion` |

Los datos que dependen de otra entidad **no se repiten**; se referencian con una llave foránea:

- La categoría, la marca, la unidad y el proveedor no se escriben dentro de `PRODUCTOS`; hay una tabla para cada uno y `PRODUCTOS` guarda solo su identificador.
- El nombre y el NIT del cliente están en `CLIENTES`, no en cada factura.
- La forma de pago es un catálogo (`METODOS_PAGO`), no un texto repetido en las facturas.
- Los datos de acceso están en `USUARIOS`, separados de `EMPLEADOS`, porque dependen de la cuenta y no del empleado en sí.

**Cumple 3FN en la estructura de las entidades.**

## Valores derivados que se guardan a propósito

Hay cuatro valores que se pueden calcular a partir de otros. Se guardan por decisión de diseño (el enunciado los plantea como «calculados») y se mantienen correctos con restricciones y con una consulta de verificación. Estrictamente, son una redundancia controlada; si se quitaran, el modelo seguiría siendo 3FN sin cambiar nada más.

| Valor guardado | De dónde se deriva | Cómo se mantiene correcto |
|---|---|---|
| `Subtotal` en `FACTURAS_DETALLE` y `COMPRAS_DETALLE` | `Cantidad × Precio_Unitario` | Se carga calculado en el DML; `CHECK (Subtotal > 0)` |
| `Subtotal`, `Impuesto` y `Total_*` en los encabezados | Suma de los subtotales del detalle; IVA 12 %; subtotal más impuesto | Se cargan calculados en el DML; `CHECK (Total = Subtotal + Impuesto)` |
| `Stock_Actual` en `PRODUCTOS` | Suma de entradas menos salidas del kárdex | El DML incluye una consulta que verifica que coincida con el último saldo del kárdex (debe devolver 0 filas) |
| `Saldo_Resultante` en `MOVIMIENTOS_INVENTARIO` | Saldo anterior más o menos la cantidad | Se registra en cada movimiento del kárdex; es el estado histórico del inventario en ese momento |

Se mantienen guardados por rendimiento (consultar el stock sin recorrer todo el kárdex) y para conservar el histórico. `Precio_Unitario` en los detalles no es redundante: es el precio vigente **en el momento** de la operación y puede ser distinto del precio actual en `PRODUCTOS`.
