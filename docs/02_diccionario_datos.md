# Diccionario de datos

Base de datos **FERRETERIADB** (Oracle Database 21c XE). Una tabla por entidad con campo, tipo de dato, longitud, llave, restricciones y descripción. Todas las llaves primarias son autonuméricas (`GENERATED ALWAYS AS IDENTITY`). Los nombres de restricciones están en [`sql/02_ddl_crear_tablas.sql`](../sql/02_ddl_crear_tablas.sql).

**Notación:** PK = llave primaria · FK = llave foránea · UQ = valor único · NN = NOT NULL. En `NUMBER(p,s)`, *p* es el total de dígitos y *s* los decimales.

| # | Tabla | Para qué sirve |
|---|---|---|
| 1 | [`CATEGORIAS`](#categorias) | Agrupa los productos por tipo (herramientas manuales, plomería, etc.). |
| 2 | [`MARCAS`](#marcas) | Marcas comerciales de los productos. |
| 3 | [`UNIDADES_MEDIDA`](#unidades_medida) | Unidades en que se vende cada producto (unidad, metro, galón, etc.). |
| 4 | [`PROVEEDORES`](#proveedores) | Empresas que abastecen la ferretería. |
| 5 | [`CLIENTES`](#clientes) | Clientes a quienes se factura. |
| 6 | [`EMPLEADOS`](#empleados) | Personal que registra compras y emite facturas. |
| 7 | [`USUARIOS`](#usuarios) | Cuentas de acceso al sistema, una por empleado. |
| 8 | [`PRODUCTOS`](#productos) | Catálogo de productos con su precio y existencia. |
| 9 | [`COMPRAS_ENCABEZADO`](#compras_encabezado) | Encabezado de cada compra de mercadería a un proveedor. |
| 10 | [`COMPRAS_DETALLE`](#compras_detalle) | Líneas de cada compra; tabla puente entre compras y productos. |
| 11 | [`METODOS_PAGO`](#metodos_pago) | Formas de pago aceptadas. |
| 12 | [`FACTURAS_ENCABEZADO`](#facturas_encabezado) | Encabezado de cada factura de venta. |
| 13 | [`FACTURAS_DETALLE`](#facturas_detalle) | Líneas de cada factura; tabla puente entre facturas y productos. |
| 14 | [`MOVIMIENTOS_INVENTARIO`](#movimientos_inventario) | Kárdex: cada entrada o salida de inventario con su saldo. |

## CATEGORIAS

Agrupa los productos por tipo (herramientas manuales, plomería, etc.).

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Categoria` | NUMBER | — | PK | NN | Identificador autonumérico de la categoría. |
| `Nombre_Categoria` | VARCHAR2 | 60 | UQ | NN<br>UNIQUE | Nombre de la categoría; no se repite. |
| `Descripcion` | VARCHAR2 | 255 | — | — | Texto breve con ejemplos de lo que incluye. |

## MARCAS

Marcas comerciales de los productos.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Marca` | NUMBER | — | PK | NN | Identificador autonumérico de la marca. |
| `Nombre_Marca` | VARCHAR2 | 60 | UQ | NN<br>UNIQUE | Nombre de la marca; no se repite. |
| `Pais_Origen` | VARCHAR2 | 60 | — | — | País de origen de la marca. |

## UNIDADES_MEDIDA

Unidades en que se vende cada producto (unidad, metro, galón, etc.).

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Unidad` | NUMBER | — | PK | NN | Identificador autonumérico de la unidad. |
| `Nombre_Unidad` | VARCHAR2 | 30 | UQ | NN<br>UNIQUE | Nombre de la unidad; no se repite. |
| `Abreviatura` | VARCHAR2 | 10 | — | NN | Abreviatura para mostrar (UND, m, gal...). |

## PROVEEDORES

Empresas que abastecen la ferretería.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Proveedor` | NUMBER | — | PK | NN | Identificador autonumérico del proveedor. |
| `Nombre_Empresa` | VARCHAR2 | 100 | UQ | NN<br>UNIQUE | Nombre de la empresa; no se repite. |
| `Telefono` | VARCHAR2 | 20 | — | NN | Teléfono de contacto. |
| `Correo` | VARCHAR2 | 100 | UQ | NN<br>UNIQUE<br>`CHECK (Correo LIKE '%_@_%._%')` | Correo electrónico; único y con formato válido (usuario@dominio.ext). |
| `Contacto_Principal` | VARCHAR2 | 100 | — | — | Persona de contacto en la empresa. |

## CLIENTES

Clientes a quienes se factura.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Cliente` | NUMBER | — | PK | NN | Identificador autonumérico del cliente. |
| `NIT` | VARCHAR2 | 20 | UQ | NN<br>UNIQUE | Número de identificación tributaria; único (CF = consumidor final). |
| `Nombre_Completo` | VARCHAR2 | 120 | — | NN | Nombre o razón social del cliente. |
| `Direccion` | VARCHAR2 | 200 | — | — | Dirección del cliente. |
| `Telefono` | VARCHAR2 | 20 | — | — | Teléfono del cliente. |
| `Correo` | VARCHAR2 | 100 | UQ | UNIQUE<br>`CHECK (Correo IS NULL OR Correo LIKE '%_@_%._%')` | Correo electrónico; único y con formato válido cuando se registra. |

## EMPLEADOS

Personal que registra compras y emite facturas.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Empleado` | NUMBER | — | PK | NN | Identificador autonumérico del empleado. |
| `Nombre_Completo` | VARCHAR2 | 120 | — | NN | Nombre completo del empleado. |
| `Puesto` | VARCHAR2 | 50 | — | NN | Cargo que desempeña. |
| `Telefono` | VARCHAR2 | 20 | — | — | Teléfono del empleado. |
| `Correo` | VARCHAR2 | 100 | UQ | NN<br>UNIQUE<br>`CHECK (Correo LIKE '%_@_%._%')` | Correo electrónico; único y con formato válido. |
| `Fecha_Ingreso` | DATE | — | — | NN<br>`DEFAULT SYSDATE` | Fecha de ingreso; por defecto la fecha del sistema. |

## USUARIOS

Cuentas de acceso al sistema, una por empleado.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Usuario` | NUMBER | — | PK | NN | Identificador autonumérico del usuario. |
| `Nombre_Usuario` | VARCHAR2 | 30 | UQ | NN<br>UNIQUE | Nombre de usuario; único. |
| `Contrasena_Hash` | VARCHAR2 | 255 | — | NN | Contraseña guardada como hash (nunca en texto plano); en los datos de prueba son hashes ficticios. |
| `Rol` | VARCHAR2 | 20 | — | NN<br>`CHECK (Rol IN ('Admin','Vendedor','Bodeguero'))` | Perfil de acceso: Admin, Vendedor o Bodeguero. |
| `ID_Empleado` | NUMBER | — | FK → `EMPLEADOS` | NN<br>ON DELETE CASCADE | Empleado dueño de la cuenta. |

## PRODUCTOS

Catálogo de productos con su precio y existencia.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Producto` | NUMBER | — | PK | NN | Identificador autonumérico del producto. |
| `Codigo_Barras` | VARCHAR2 | 30 | UQ | NN<br>UNIQUE | Código de barras; único. |
| `Nombre_Producto` | VARCHAR2 | 120 | — | NN | Nombre descriptivo del producto. |
| `Precio_Compra` | NUMBER | 10,2 | — | NN<br>`CHECK (Precio_Compra > 0)` | Precio al que se compra al proveedor (mayor que 0). |
| `Precio_Venta` | NUMBER | 10,2 | — | NN<br>`CHECK (Precio_Venta > 0)` | Precio de venta al público (mayor que 0). |
| `Stock_Actual` | NUMBER | 10 | — | NN<br>`DEFAULT 0`<br>`CHECK (Stock_Actual >= 0)` | Existencia actual; nunca negativa. Coincide con el saldo del último movimiento del kárdex. |
| `Stock_Minimo` | NUMBER | 10 | — | NN<br>`DEFAULT 5`<br>`CHECK (Stock_Minimo >= 0)` | Existencia mínima deseada; con una existencia igual o menor se considera stock bajo. |
| `ID_Categoria` | NUMBER | — | FK → `CATEGORIAS` | NN | Categoría del producto. |
| `ID_Marca` | NUMBER | — | FK → `MARCAS` | NN | Marca del producto. |
| `ID_Unidad` | NUMBER | — | FK → `UNIDADES_MEDIDA` | NN | Unidad de medida en que se vende. |
| `ID_Proveedor` | NUMBER | — | FK → `PROVEEDORES` | NN | Proveedor que suministra el producto. |

## COMPRAS_ENCABEZADO

Encabezado de cada compra de mercadería a un proveedor.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Compra` | NUMBER | — | PK | NN | Identificador autonumérico de la compra. |
| `Numero_Compra` | VARCHAR2 | 20 | UQ | NN<br>UNIQUE | Número del documento (COMP-0001...); único. |
| `Fecha_Compra` | DATE | — | — | NN<br>`DEFAULT SYSDATE` | Fecha de la compra; por defecto la del sistema. |
| `Subtotal` | NUMBER | 12,2 | — | NN<br>`CHECK (Subtotal > 0)` | Suma de los subtotales del detalle (sin IVA). |
| `Impuesto` | NUMBER | 12,2 | — | NN<br>`CHECK (Impuesto >= 0)` | IVA del 12 % sobre el subtotal. |
| `Total_Compra` | NUMBER | 12,2 | — | NN<br>`CHECK (Total_Compra > 0)` | Subtotal más impuesto. |
| `Estado` | VARCHAR2 | 15 | — | NN<br>`DEFAULT 'PENDIENTE'`<br>`CHECK (Estado IN ('PENDIENTE','RECIBIDA','ANULADA'))` | PENDIENTE, RECIBIDA o ANULADA. Solo RECIBIDA suma stock. |
| `ID_Proveedor` | NUMBER | — | FK → `PROVEEDORES` | NN | Proveedor al que se compra. |
| `ID_Empleado` | NUMBER | — | FK → `EMPLEADOS` | NN | Empleado que registra la compra. |

**Restricciones de tabla:**

- `CHECK (Total_Compra = Subtotal + Impuesto)`

## COMPRAS_DETALLE

Líneas de cada compra; tabla puente entre compras y productos.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Detalle_Compra` | NUMBER | — | PK | NN | Identificador autonumérico de la línea. |
| `ID_Compra` | NUMBER | — | FK → `COMPRAS_ENCABEZADO` | NN<br>ON DELETE CASCADE | Compra a la que pertenece la línea (se borra junto con ella). |
| `ID_Producto` | NUMBER | — | FK → `PRODUCTOS` | NN | Producto comprado. |
| `Cantidad` | NUMBER | 8 | — | NN<br>`CHECK (Cantidad > 0)` | Unidades compradas (mayor que 0). |
| `Precio_Unitario` | NUMBER | 10,2 | — | NN<br>`CHECK (Precio_Unitario > 0)` | Precio de compra por unidad en esa compra (mayor que 0). |
| `Subtotal` | NUMBER | 12,2 | — | NN<br>`CHECK (Subtotal > 0)` | Cantidad por precio unitario. |

**Restricciones de tabla:**

- `UNIQUE (ID_Compra, ID_Producto)`: una misma combinación no puede repetirse.

## METODOS_PAGO

Formas de pago aceptadas.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Metodo_Pago` | NUMBER | — | PK | NN | Identificador autonumérico de la forma de pago. |
| `Nombre_Metodo` | VARCHAR2 | 30 | UQ | NN<br>UNIQUE | Nombre de la forma de pago; no se repite. |

## FACTURAS_ENCABEZADO

Encabezado de cada factura de venta.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Factura` | NUMBER | — | PK | NN | Identificador autonumérico de la factura. |
| `Numero_Factura` | VARCHAR2 | 20 | UQ | NN<br>UNIQUE | Número del documento (FAC-0001...); único. |
| `Fecha_Emision` | DATE | — | — | NN<br>`DEFAULT SYSDATE` | Fecha de emisión; por defecto la del sistema. |
| `Subtotal` | NUMBER | 12,2 | — | NN<br>`CHECK (Subtotal > 0)` | Suma de los subtotales del detalle (sin IVA). |
| `Impuesto` | NUMBER | 12,2 | — | NN<br>`CHECK (Impuesto >= 0)` | IVA del 12 % sobre el subtotal. |
| `Total_Factura` | NUMBER | 12,2 | — | NN<br>`CHECK (Total_Factura > 0)` | Subtotal más impuesto. |
| `Estado` | VARCHAR2 | 15 | — | NN<br>`DEFAULT 'PENDIENTE'`<br>`CHECK (Estado IN ('PENDIENTE','PAGADO','ANULADO'))` | PENDIENTE, PAGADO o ANULADO. Solo PAGADO descuenta stock. |
| `ID_Cliente` | NUMBER | — | FK → `CLIENTES` | NN | Cliente al que se factura. |
| `ID_Empleado` | NUMBER | — | FK → `EMPLEADOS` | NN | Empleado que emite la factura. |
| `ID_Metodo_Pago` | NUMBER | — | FK → `METODOS_PAGO` | NN | Forma de pago utilizada. |

**Restricciones de tabla:**

- `CHECK (Total_Factura = Subtotal + Impuesto)`

## FACTURAS_DETALLE

Líneas de cada factura; tabla puente entre facturas y productos.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Detalle` | NUMBER | — | PK | NN | Identificador autonumérico de la línea. |
| `ID_Factura` | NUMBER | — | FK → `FACTURAS_ENCABEZADO` | NN<br>ON DELETE CASCADE | Factura a la que pertenece la línea (se borra junto con ella). |
| `ID_Producto` | NUMBER | — | FK → `PRODUCTOS` | NN | Producto vendido. |
| `Cantidad` | NUMBER | 8 | — | NN<br>`CHECK (Cantidad > 0)` | Unidades vendidas (mayor que 0). |
| `Precio_Unitario` | NUMBER | 10,2 | — | NN<br>`CHECK (Precio_Unitario > 0)` | Precio de venta por unidad al momento de la venta (mayor que 0). |
| `Subtotal` | NUMBER | 12,2 | — | NN<br>`CHECK (Subtotal > 0)` | Cantidad por precio unitario. |

**Restricciones de tabla:**

- `UNIQUE (ID_Factura, ID_Producto)`: una misma combinación no puede repetirse.

## MOVIMIENTOS_INVENTARIO

Kárdex: cada entrada o salida de inventario con su saldo.

| Campo | Tipo | Longitud | Llave | Restricciones | Descripción |
|---|---|---|---|---|---|
| `ID_Movimiento` | NUMBER | — | PK | NN | Identificador autonumérico del movimiento. |
| `ID_Producto` | NUMBER | — | FK → `PRODUCTOS` | NN | Producto que se movió. |
| `Fecha_Movimiento` | DATE | — | — | NN<br>`DEFAULT SYSDATE` | Fecha del movimiento; por defecto la del sistema. |
| `Tipo_Movimiento` | VARCHAR2 | 10 | — | NN<br>`CHECK (Tipo_Movimiento IN ('ENTRADA','SALIDA'))` | ENTRADA (por compra) o SALIDA (por venta). |
| `Cantidad` | NUMBER | 8 | — | NN<br>`CHECK (Cantidad > 0)` | Unidades que entran o salen (mayor que 0). |
| `Saldo_Resultante` | NUMBER | 10 | — | NN<br>`CHECK (Saldo_Resultante >= 0)` | Existencia del producto después del movimiento (nunca negativa). |
| `ID_Compra` | NUMBER | — | FK → `COMPRAS_ENCABEZADO` | — | Compra que originó la ENTRADA (vacío en una SALIDA). |
| `ID_Factura` | NUMBER | — | FK → `FACTURAS_ENCABEZADO` | — | Factura que originó la SALIDA (vacío en una ENTRADA). |
| `Observacion` | VARCHAR2 | 200 | — | — | Texto libre con el detalle del movimiento. |

**Restricciones de tabla:**

- `CHECK ((Tipo_Movimiento = 'ENTRADA' AND ID_Compra IS NOT NULL AND ID_Factura IS NULL) OR (Tipo_Movimiento = 'SALIDA' AND ID_Factura IS NOT NULL AND ID_Compra IS NULL))`
