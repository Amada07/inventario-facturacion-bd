/* ==================================================================
   UNIVERSIDAD MARIANO GALVEZ DE GUATEMALA - BASE DE DATOS I
   PROYECTO FINAL: SISTEMA DE INVENTARIO Y FACTURACION (FERRETERIA)
   SGBD: Oracle Database 21c XE | Esquema: FERRETERIADB
   ------------------------------------------------------------------
   02_ddl_crear_tablas.sql
   Estructura fisica: 14 tablas con llaves primarias, foraneas y
   restricciones (CHECK, UNIQUE, NOT NULL, DEFAULT).

   14 TABLAS EN 5 GRUPOS
   G1 Catalogo Base : CATEGORIAS, MARCAS, UNIDADES_MEDIDA,
                      PROVEEDORES, CLIENTES
   G2 Inventario    : PRODUCTOS, MOVIMIENTOS_INVENTARIO (kardex)
   G3 Compras       : COMPRAS_ENCABEZADO, COMPRAS_DETALLE
   G4 Ventas        : METODOS_PAGO, FACTURAS_ENCABEZADO, FACTURAS_DETALLE
   G5 Seguridad     : EMPLEADOS, USUARIOS
   ------------------------------------------------------------------
   REGLAS DE DISENO
   - Claves primarias autonumericas: GENERATED ALWAYS AS IDENTITY.
   - Claves foraneas sin clausula ON DELETE: en Oracle el
     comportamiento por defecto es restrictivo (no permite borrar un
     registro padre con hijos). Solo se usa ON DELETE CASCADE en los
     detalles (se borran junto con su encabezado) y en USUARIOS.
   - Precios, subtotales y totales: CHECK > 0. Los totales del
     encabezado NO tienen DEFAULT: se calculan al registrar el
     documento (en los datos de prueba ya vienen calculados).
   - Stock: CHECK >= 0. Estados controlados con CHECK ... IN (...).
   ================================================================== */

/* ------------------------------------------------------------------
   GRUPO 1: CATALOGO BASE
   ------------------------------------------------------------------ */
CREATE TABLE CATEGORIAS (
    ID_Categoria      NUMBER GENERATED ALWAYS AS IDENTITY
                        CONSTRAINT PK_CATEGORIAS PRIMARY KEY,
    Nombre_Categoria  VARCHAR2(60)  NOT NULL,
    Descripcion       VARCHAR2(255),
    CONSTRAINT UQ_CATEGORIAS_NOMBRE UNIQUE (Nombre_Categoria)
);

CREATE TABLE MARCAS (
    ID_Marca      NUMBER GENERATED ALWAYS AS IDENTITY
                    CONSTRAINT PK_MARCAS PRIMARY KEY,
    Nombre_Marca  VARCHAR2(60) NOT NULL,
    Pais_Origen   VARCHAR2(60),
    CONSTRAINT UQ_MARCAS_NOMBRE UNIQUE (Nombre_Marca)
);

CREATE TABLE UNIDADES_MEDIDA (
    ID_Unidad      NUMBER GENERATED ALWAYS AS IDENTITY
                     CONSTRAINT PK_UNIDADES PRIMARY KEY,
    Nombre_Unidad  VARCHAR2(30) NOT NULL,
    Abreviatura    VARCHAR2(10) NOT NULL,
    CONSTRAINT UQ_UNIDADES_NOMBRE UNIQUE (Nombre_Unidad)
);

CREATE TABLE PROVEEDORES (
    ID_Proveedor        NUMBER GENERATED ALWAYS AS IDENTITY
                          CONSTRAINT PK_PROVEEDORES PRIMARY KEY,
    Nombre_Empresa      VARCHAR2(100) NOT NULL,
    Telefono            VARCHAR2(20)  NOT NULL,
    Correo              VARCHAR2(100) NOT NULL,
    Contacto_Principal  VARCHAR2(100),
    CONSTRAINT UQ_PROVEEDORES_EMPRESA UNIQUE (Nombre_Empresa),
    CONSTRAINT UQ_PROVEEDORES_CORREO  UNIQUE (Correo),
    CONSTRAINT CK_PROVEEDORES_CORREO  CHECK (Correo LIKE '%_@_%._%')
);

CREATE TABLE CLIENTES (
    ID_Cliente       NUMBER GENERATED ALWAYS AS IDENTITY
                       CONSTRAINT PK_CLIENTES PRIMARY KEY,
    NIT              VARCHAR2(20)  NOT NULL,
    Nombre_Completo  VARCHAR2(120) NOT NULL,
    Direccion        VARCHAR2(200),
    Telefono         VARCHAR2(20),
    Correo           VARCHAR2(100),
    CONSTRAINT UQ_CLIENTES_NIT    UNIQUE (NIT),
    CONSTRAINT UQ_CLIENTES_CORREO UNIQUE (Correo),
    CONSTRAINT CK_CLIENTES_CORREO CHECK (Correo IS NULL OR Correo LIKE '%_@_%._%')
);

/* ------------------------------------------------------------------
   GRUPO 5: SEGURIDAD / OPERACION
   (se crea antes de compras y ventas porque estas referencian
    a EMPLEADOS)
   ------------------------------------------------------------------ */
CREATE TABLE EMPLEADOS (
    ID_Empleado      NUMBER GENERATED ALWAYS AS IDENTITY
                       CONSTRAINT PK_EMPLEADOS PRIMARY KEY,
    Nombre_Completo  VARCHAR2(120) NOT NULL,
    Puesto           VARCHAR2(50)  NOT NULL,
    Telefono         VARCHAR2(20),
    Correo           VARCHAR2(100) NOT NULL,
    Fecha_Ingreso    DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT UQ_EMPLEADOS_CORREO UNIQUE (Correo),
    CONSTRAINT CK_EMPLEADOS_CORREO CHECK (Correo LIKE '%_@_%._%')
);

CREATE TABLE USUARIOS (
    ID_Usuario       NUMBER GENERATED ALWAYS AS IDENTITY
                       CONSTRAINT PK_USUARIOS PRIMARY KEY,
    Nombre_Usuario   VARCHAR2(30)  NOT NULL,
    Contrasena_Hash  VARCHAR2(255) NOT NULL,
    Rol              VARCHAR2(20)  NOT NULL,
    ID_Empleado      NUMBER        NOT NULL,
    CONSTRAINT UQ_USUARIOS_NOMBRE UNIQUE (Nombre_Usuario),
    CONSTRAINT FK_USUARIOS_EMPLEADO
        FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADOS (ID_Empleado)
        ON DELETE CASCADE,
    CONSTRAINT CK_USUARIOS_ROL CHECK (Rol IN ('Admin','Vendedor','Bodeguero'))
);

/* ------------------------------------------------------------------
   GRUPO 2: INVENTARIO
   ------------------------------------------------------------------ */
CREATE TABLE PRODUCTOS (
    ID_Producto      NUMBER GENERATED ALWAYS AS IDENTITY
                       CONSTRAINT PK_PRODUCTOS PRIMARY KEY,
    Codigo_Barras    VARCHAR2(30)  NOT NULL,
    Nombre_Producto  VARCHAR2(120) NOT NULL,
    Precio_Compra    NUMBER(10,2)  NOT NULL,
    Precio_Venta     NUMBER(10,2)  NOT NULL,
    Stock_Actual     NUMBER(10)    DEFAULT 0 NOT NULL,
    Stock_Minimo     NUMBER(10)    DEFAULT 5 NOT NULL,
    ID_Categoria     NUMBER        NOT NULL,
    ID_Marca         NUMBER        NOT NULL,
    ID_Unidad        NUMBER        NOT NULL,
    ID_Proveedor     NUMBER        NOT NULL,
    CONSTRAINT UQ_PRODUCTOS_CODBARRAS UNIQUE (Codigo_Barras),
    CONSTRAINT FK_PRODUCTOS_CATEGORIA
        FOREIGN KEY (ID_Categoria) REFERENCES CATEGORIAS (ID_Categoria),
    CONSTRAINT FK_PRODUCTOS_MARCA
        FOREIGN KEY (ID_Marca) REFERENCES MARCAS (ID_Marca),
    CONSTRAINT FK_PRODUCTOS_UNIDAD
        FOREIGN KEY (ID_Unidad) REFERENCES UNIDADES_MEDIDA (ID_Unidad),
    CONSTRAINT FK_PRODUCTOS_PROVEEDOR
        FOREIGN KEY (ID_Proveedor) REFERENCES PROVEEDORES (ID_Proveedor),
    CONSTRAINT CK_PRODUCTOS_PCOMPRA CHECK (Precio_Compra > 0),
    CONSTRAINT CK_PRODUCTOS_PVENTA  CHECK (Precio_Venta > 0),
    CONSTRAINT CK_PRODUCTOS_STOCK   CHECK (Stock_Actual >= 0),
    CONSTRAINT CK_PRODUCTOS_STOCKMIN CHECK (Stock_Minimo >= 0)
);

/* ------------------------------------------------------------------
   GRUPO 3: COMPRAS
   ------------------------------------------------------------------ */
CREATE TABLE COMPRAS_ENCABEZADO (
    ID_Compra      NUMBER GENERATED ALWAYS AS IDENTITY
                     CONSTRAINT PK_COMPRAS_ENC PRIMARY KEY,
    Numero_Compra  VARCHAR2(20)  NOT NULL,
    Fecha_Compra   DATE          DEFAULT SYSDATE NOT NULL,
    Subtotal       NUMBER(12,2)  NOT NULL,
    Impuesto       NUMBER(12,2)  NOT NULL,
    Total_Compra   NUMBER(12,2)  NOT NULL,
    Estado         VARCHAR2(15)  DEFAULT 'PENDIENTE' NOT NULL,
    ID_Proveedor   NUMBER        NOT NULL,
    ID_Empleado    NUMBER        NOT NULL,
    CONSTRAINT UQ_COMPRAS_NUMERO UNIQUE (Numero_Compra),
    CONSTRAINT FK_COMPRAS_PROVEEDOR
        FOREIGN KEY (ID_Proveedor) REFERENCES PROVEEDORES (ID_Proveedor),
    CONSTRAINT FK_COMPRAS_EMPLEADO
        FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADOS (ID_Empleado),
    CONSTRAINT CK_COMPRAS_SUBTOTAL CHECK (Subtotal > 0),
    CONSTRAINT CK_COMPRAS_IMPUESTO CHECK (Impuesto >= 0),
    CONSTRAINT CK_COMPRAS_TOTAL    CHECK (Total_Compra > 0),
    CONSTRAINT CK_COMPRAS_COHERENTE CHECK (Total_Compra = Subtotal + Impuesto),
    CONSTRAINT CK_COMPRAS_ESTADO   CHECK (Estado IN ('PENDIENTE','RECIBIDA','ANULADA'))
);

CREATE TABLE COMPRAS_DETALLE (
    ID_Detalle_Compra  NUMBER GENERATED ALWAYS AS IDENTITY
                         CONSTRAINT PK_COMPRAS_DET PRIMARY KEY,
    ID_Compra          NUMBER        NOT NULL,
    ID_Producto        NUMBER        NOT NULL,
    Cantidad           NUMBER(8)     NOT NULL,
    Precio_Unitario    NUMBER(10,2)  NOT NULL,
    Subtotal           NUMBER(12,2)  NOT NULL,
    CONSTRAINT FK_COMPRASDET_COMPRA
        FOREIGN KEY (ID_Compra) REFERENCES COMPRAS_ENCABEZADO (ID_Compra)
        ON DELETE CASCADE,
    CONSTRAINT FK_COMPRASDET_PRODUCTO
        FOREIGN KEY (ID_Producto) REFERENCES PRODUCTOS (ID_Producto),
    CONSTRAINT CK_COMPRASDET_CANTIDAD CHECK (Cantidad > 0),
    CONSTRAINT CK_COMPRASDET_PRECIO   CHECK (Precio_Unitario > 0),
    CONSTRAINT CK_COMPRASDET_SUBTOTAL CHECK (Subtotal > 0),
    CONSTRAINT UQ_COMPRASDET_COMPRA_PROD UNIQUE (ID_Compra, ID_Producto)
);

/* ------------------------------------------------------------------
   GRUPO 4: VENTAS / FACTURACION
   ------------------------------------------------------------------ */
CREATE TABLE METODOS_PAGO (
    ID_Metodo_Pago  NUMBER GENERATED ALWAYS AS IDENTITY
                      CONSTRAINT PK_METODOS_PAGO PRIMARY KEY,
    Nombre_Metodo   VARCHAR2(30) NOT NULL,
    CONSTRAINT UQ_METODOS_PAGO_NOMBRE UNIQUE (Nombre_Metodo)
);

CREATE TABLE FACTURAS_ENCABEZADO (
    ID_Factura      NUMBER GENERATED ALWAYS AS IDENTITY
                      CONSTRAINT PK_FACTURAS_ENC PRIMARY KEY,
    Numero_Factura  VARCHAR2(20)  NOT NULL,
    Fecha_Emision   DATE          DEFAULT SYSDATE NOT NULL,
    Subtotal        NUMBER(12,2)  NOT NULL,
    Impuesto        NUMBER(12,2)  NOT NULL,
    Total_Factura   NUMBER(12,2)  NOT NULL,
    Estado          VARCHAR2(15)  DEFAULT 'PENDIENTE' NOT NULL,
    ID_Cliente      NUMBER        NOT NULL,
    ID_Empleado     NUMBER        NOT NULL,
    ID_Metodo_Pago  NUMBER        NOT NULL,
    CONSTRAINT UQ_FACTURAS_NUMERO UNIQUE (Numero_Factura),
    CONSTRAINT FK_FACTURAS_CLIENTE
        FOREIGN KEY (ID_Cliente) REFERENCES CLIENTES (ID_Cliente),
    CONSTRAINT FK_FACTURAS_EMPLEADO
        FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADOS (ID_Empleado),
    CONSTRAINT FK_FACTURAS_METODOPAGO
        FOREIGN KEY (ID_Metodo_Pago) REFERENCES METODOS_PAGO (ID_Metodo_Pago),
    CONSTRAINT CK_FACTURAS_SUBTOTAL CHECK (Subtotal > 0),
    CONSTRAINT CK_FACTURAS_IMPUESTO CHECK (Impuesto >= 0),
    CONSTRAINT CK_FACTURAS_TOTAL    CHECK (Total_Factura > 0),
    CONSTRAINT CK_FACTURAS_COHERENTE CHECK (Total_Factura = Subtotal + Impuesto),
    CONSTRAINT CK_FACTURAS_ESTADO   CHECK (Estado IN ('PENDIENTE','PAGADO','ANULADO'))
);

CREATE TABLE FACTURAS_DETALLE (
    ID_Detalle       NUMBER GENERATED ALWAYS AS IDENTITY
                       CONSTRAINT PK_FACTURAS_DET PRIMARY KEY,
    ID_Factura       NUMBER        NOT NULL,
    ID_Producto      NUMBER        NOT NULL,
    Cantidad         NUMBER(8)     NOT NULL,
    Precio_Unitario  NUMBER(10,2)  NOT NULL,
    Subtotal         NUMBER(12,2)  NOT NULL,
    CONSTRAINT FK_FACTDET_FACTURA
        FOREIGN KEY (ID_Factura) REFERENCES FACTURAS_ENCABEZADO (ID_Factura)
        ON DELETE CASCADE,
    CONSTRAINT FK_FACTDET_PRODUCTO
        FOREIGN KEY (ID_Producto) REFERENCES PRODUCTOS (ID_Producto),
    CONSTRAINT CK_FACTDET_CANTIDAD CHECK (Cantidad > 0),
    CONSTRAINT CK_FACTDET_PRECIO   CHECK (Precio_Unitario > 0),
    CONSTRAINT CK_FACTDET_SUBTOTAL CHECK (Subtotal > 0),
    CONSTRAINT UQ_FACTDET_FACTURA_PROD UNIQUE (ID_Factura, ID_Producto)
);

/* ------------------------------------------------------------------
   GRUPO 2 (continuacion): KARDEX DE INVENTARIO
   Cada ENTRADA nace de una compra y cada SALIDA de una factura.
   ------------------------------------------------------------------ */
CREATE TABLE MOVIMIENTOS_INVENTARIO (
    ID_Movimiento     NUMBER GENERATED ALWAYS AS IDENTITY
                        CONSTRAINT PK_MOVIMIENTOS PRIMARY KEY,
    ID_Producto       NUMBER        NOT NULL,
    Fecha_Movimiento  DATE          DEFAULT SYSDATE NOT NULL,
    Tipo_Movimiento   VARCHAR2(10)  NOT NULL,
    Cantidad          NUMBER(8)     NOT NULL,
    Saldo_Resultante  NUMBER(10)    NOT NULL,
    ID_Compra         NUMBER,
    ID_Factura        NUMBER,
    Observacion       VARCHAR2(200),
    CONSTRAINT FK_MOV_PRODUCTO
        FOREIGN KEY (ID_Producto) REFERENCES PRODUCTOS (ID_Producto),
    CONSTRAINT FK_MOV_COMPRA
        FOREIGN KEY (ID_Compra) REFERENCES COMPRAS_ENCABEZADO (ID_Compra),
    CONSTRAINT FK_MOV_FACTURA
        FOREIGN KEY (ID_Factura) REFERENCES FACTURAS_ENCABEZADO (ID_Factura),
    CONSTRAINT CK_MOV_TIPO     CHECK (Tipo_Movimiento IN ('ENTRADA','SALIDA')),
    CONSTRAINT CK_MOV_CANTIDAD CHECK (Cantidad > 0),
    CONSTRAINT CK_MOV_SALDO    CHECK (Saldo_Resultante >= 0),
    CONSTRAINT CK_MOV_ORIGEN CHECK (
        (Tipo_Movimiento = 'ENTRADA' AND ID_Compra IS NOT NULL AND ID_Factura IS NULL)
     OR (Tipo_Movimiento = 'SALIDA'  AND ID_Factura IS NOT NULL AND ID_Compra IS NULL))
);

/* ------------------------------------------------------------------
   VERIFICACION: debe listar las 14 tablas
   ------------------------------------------------------------------ */
SELECT table_name FROM user_tables ORDER BY table_name;
