/* ==================================================================
   UNIVERSIDAD MARIANO GALVEZ DE GUATEMALA - BASE DE DATOS I
   PROYECTO FINAL: SISTEMA DE INVENTARIO Y FACTURACION (FERRETERIA)
   SGBD: Oracle Database 21c XE | Esquema: FERRETERIADB
   ------------------------------------------------------------------
   03_dml_datos_prueba.sql
   Ejecutar despues de 02_ddl_crear_tablas.sql. Termina con COMMIT y
   con 3 consultas de verificacion de la carga.
   ================================================================== */

/* ==================================================================
   SECCION 3: CARGA MASIVA DE DATOS DE PRUEBA (DML)
   ------------------------------------------------------------------
   Se ejecuta DESPUES del script 02 (DDL). Los IDs son autonumericos
   (GENERATED ALWAYS AS IDENTITY) y las tablas acaban de crearse, asi
   que los IDs empiezan en 1 y las llaves foraneas se escriben con
   esos valores. Orden de carga: catalogos -> empleados/usuarios ->
   productos -> compras -> facturas -> kardex.

   VOLUMENES
   - Catalogos (4 tablas)        : 5 a 8 registros
   - Entidades principales       : 15 a 30 registros
     (proveedores 15, clientes 18, empleados 15, usuarios 15,
     productos 30)
   - Compras con detalle         : 17 (14 RECIBIDA, 1 PENDIENTE, 1 ANULADA
                                   + 1 reabastecimiento)
   - Facturas con detalle        : 14 (12 PAGADO, 1 PENDIENTE, 1 ANULADO)

   REGLAS DE COHERENCIA DEL INVENTARIO
   - IVA = 12 % sobre el subtotal; Total = Subtotal + Impuesto.
   - Solo las compras RECIBIDA suman stock (ENTRADA en el kardex) y
     solo las facturas PAGADO lo restan (SALIDA en el kardex).
     PENDIENTE y ANULADA/ANULADO no mueven inventario.
   - Stock_Actual de cada producto = saldo final de su kardex.
   - Casos limite incluidos: productos con stock bajo el minimo, un
     producto agotado (stock 0), proveedores y clientes sin
     operaciones (sirven para probar LEFT JOIN).
   ================================================================== */

/* ------------------------------------------------------------------
   GRUPO 1: CATALOGO BASE
   ------------------------------------------------------------------ */
-- CATEGORIAS (8)
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Herramientas Manuales', 'Martillos, destornilladores, cintas metricas');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Herramientas Electricas', 'Taladros, esmeriladoras y accesorios');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Plomeria', 'Tuberias, llaves y mangueras');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Electricidad', 'Cables, interruptores e iluminacion');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Pinturas y Acabados', 'Pinturas, brochas y rodillos');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Tornilleria y Fijacion', 'Tornillos, clavos y anclajes');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Construccion', 'Cemento, cal y materiales de obra');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Seguridad Industrial', 'Cascos, guantes y proteccion personal');

-- MARCAS (8)
INSERT INTO MARCAS (Nombre_Marca, Pais_Origen) VALUES ('Truper', 'Mexico');
INSERT INTO MARCAS (Nombre_Marca, Pais_Origen) VALUES ('DeWalt', 'Estados Unidos');
INSERT INTO MARCAS (Nombre_Marca, Pais_Origen) VALUES ('Stanley', 'Estados Unidos');
INSERT INTO MARCAS (Nombre_Marca, Pais_Origen) VALUES ('Bosch', 'Alemania');
INSERT INTO MARCAS (Nombre_Marca, Pais_Origen) VALUES ('Pretul', 'Mexico');
INSERT INTO MARCAS (Nombre_Marca, Pais_Origen) VALUES ('Sherwin-Williams', 'Estados Unidos');
INSERT INTO MARCAS (Nombre_Marca, Pais_Origen) VALUES ('Pavco', 'Colombia');
INSERT INTO MARCAS (Nombre_Marca, Pais_Origen) VALUES ('Cemex', 'Mexico');

-- UNIDADES_MEDIDA (7)
INSERT INTO UNIDADES_MEDIDA (Nombre_Unidad, Abreviatura) VALUES ('Unidad', 'UND');
INSERT INTO UNIDADES_MEDIDA (Nombre_Unidad, Abreviatura) VALUES ('Metro', 'm');
INSERT INTO UNIDADES_MEDIDA (Nombre_Unidad, Abreviatura) VALUES ('Galon', 'gal');
INSERT INTO UNIDADES_MEDIDA (Nombre_Unidad, Abreviatura) VALUES ('Libra', 'lb');
INSERT INTO UNIDADES_MEDIDA (Nombre_Unidad, Abreviatura) VALUES ('Caja', 'cja');
INSERT INTO UNIDADES_MEDIDA (Nombre_Unidad, Abreviatura) VALUES ('Bolsa', 'bls');
INSERT INTO UNIDADES_MEDIDA (Nombre_Unidad, Abreviatura) VALUES ('Rollo', 'rll');

-- METODOS_PAGO (5)
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Efectivo');
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Tarjeta');
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Transferencia');
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Cheque');
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Deposito Bancario');

/* ------------------------------------------------------------------
   GRUPO 1: PROVEEDORES (15) - los ultimos 3 no tienen compras
   ------------------------------------------------------------------ */
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Distribuidora Ferretera Central', '2250-1100', 'ventas@ferrocentral.com.gt', 'Mario Lopez');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Herramientas y Equipos del Norte', '2331-4520', 'contacto@heninorte.com.gt', 'Sandra Giron');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Plomeria Industrial Guatemala', '2440-7788', 'pedidos@plomiguate.com.gt', 'Luis Barrios');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Electrico Mayorista S.A.', '2360-9021', 'ventas@electromayorista.com.gt', 'Karen Ruiz');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Pinturas y Acabados del Pacifico', '2478-3345', 'info@pinturaspacifico.com.gt', 'Jorge Mendez');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Tornillos y Fijaciones Industriales', '2290-6612', 'comercial@tornifix.com.gt', 'Ana Cifuentes');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Materiales de Construccion El Roble', '2210-5530', 'ventas@elroble.com.gt', 'Pedro Castillo');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Seguridad Industrial Total', '2385-4410', 'atencion@segutotal.com.gt', 'Daniela Pineda');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Importadora de Medicion y Precision', '2412-8890', 'ventas@imprecision.com.gt', 'Oscar Herrera');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Abrasivos y Discos Guatemala', '2305-7741', 'pedidos@abrasivosgt.com.gt', 'Claudia Morales');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Riegos y Mangueras Centroamerica', '2467-2203', 'info@riegoscentro.com.gt', 'Fernando Lemus');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Iluminacion LED Americana', '2321-9904', 'ventas@ledamericana.com.gt', 'Patricia Solis');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Cerrajeria y Candados Express', '2455-6120', 'contacto@cerrexpress.com.gt', 'Ricardo Paiz');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Adhesivos y Selladores Quimicos', '2278-3319', 'ventas@adhequimicos.com.gt', 'Gabriela Ordonez');
INSERT INTO PROVEEDORES (Nombre_Empresa, Telefono, Correo, Contacto_Principal) VALUES ('Maquinaria Ligera Mixco', '2432-5507', 'info@maqligera.com.gt', 'Hector Samayoa');

/* ------------------------------------------------------------------
   GRUPO 1: CLIENTES (18) - los ultimos 4 no tienen facturas
   ------------------------------------------------------------------ */
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('CF', 'Consumidor Final', NULL, NULL, NULL);
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('1234567-8', 'Carlos Eduardo Ajanel Tzoc', 'Calle Real 4-15, zona 1, San Juan Sacatepequez', '5512-3401', 'carlos.ajanel@gmail.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('2345678-9', 'Constructora Los Pinos, S.A.', 'Km 28 Carretera a San Juan, Sacatepequez', '2450-1188', 'compras@lospinos.com.gt');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('3456789-0', 'Maria Fernanda Lopez Perez', 'Barrio El Centro 2-30, San Juan Sacatepequez', '5523-9012', 'mferlopez@hotmail.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('4567890-1', 'Jose Luis Xiquin Cumes', 'Aldea Pachali, San Juan Sacatepequez', '4098-2231', NULL);
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('5678901-2', 'Ferreteria Don Chepe', '3a avenida 5-20, zona 2, Mixco', '2431-7765', 'donchepe@gmail.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('6789012-3', 'Ana Lucia Garcia Tun', 'Colonia Monte Verde, zona 3', '5534-7788', 'analucia.garcia@yahoo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('7890123-4', 'Inmobiliaria Altos del Valle', 'Boulevard Principal 12-45, zona 10', '2366-0043', 'admin@altosdelvalle.com.gt');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('8901234-5', 'Pedro Antonio Mendoza Raxon', 'Caserio San Antonio, San Juan Sacatepequez', '5545-3320', NULL);
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('9012345-6', 'Taller Mecanico El Rapido', 'Calzada Roosevelt 15-80, zona 7', '2471-9912', 'tallerrapido@gmail.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('1122334-5', 'Sofia Alejandra Cojti Sac', 'Residenciales Los Cedros, casa 14', '5556-4410', 'sofia.cojti@gmail.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('2233445-6', 'Hotel Vista Hermosa', 'Km 25 Carretera Interamericana', '7832-1155', 'gerencia@vistahermosa.com.gt');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('3344556-7', 'Roberto Carlos Tzunun Ixcoy', 'Lotificacion La Esperanza, lote 8', '4122-8873', NULL);
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('4455667-8', 'Escuela Oficial Rural Mixta', 'Aldea Sacsuy, San Juan Sacatepequez', '7721-0066', 'eorm.sacsuy@mineduc.edu.gt');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('5566778-9', 'Julia Marisol Chile Batz', 'Colonia Las Flores 3-12', '5567-2290', 'juliachile@gmail.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('6677889-0', 'Maderas y Acabados Hernandez', 'Zona Industrial, bodega 6', '2299-3347', 'info@maderashdez.com.gt');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('7788990-1', 'Luis Fernando Rodas Tucux', 'Barrio San Sebastian 1-09', '5578-1045', 'lfrodas@outlook.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('8899001-2', 'Condominio Jardines del Sol', 'Boulevard Los Proceres 20-50, zona 10', '2388-7701', 'admin@jardinesdelsol.com.gt');

/* ------------------------------------------------------------------
   GRUPO 5: EMPLEADOS (15)
   ------------------------------------------------------------------ */
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Roberto Alvarado Mejia', 'Gerente General', '5510-3000', 'roberto.alvarado@ferreteriaumg.com.gt', TO_DATE('2022-01-10','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Amanda Escobar Lima', 'Administrador de Sistemas', '5511-3137', 'amanda.escobar@ferreteriaumg.com.gt', TO_DATE('2022-03-01','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Kevin Sipac Tohom', 'Vendedor', '5512-3274', 'kevin.sipac@ferreteriaumg.com.gt', TO_DATE('2022-06-15','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Brenda Cotzal Yac', 'Vendedor', '5513-3411', 'brenda.cotzal@ferreteriaumg.com.gt', TO_DATE('2023-02-20','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Walter Chavez Ixcoy', 'Vendedor', '5514-3548', 'walter.chavez@ferreteriaumg.com.gt', TO_DATE('2023-05-08','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Rosa Maria Tzoc Pop', 'Vendedor', '5515-3685', 'rosa.maria@ferreteriaumg.com.gt', TO_DATE('2023-09-12','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Diego Armando Say Ajpop', 'Vendedor', '5516-3822', 'diego.armando@ferreteriaumg.com.gt', TO_DATE('2024-01-15','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Jorge Mario Batz Coy', 'Bodeguero', '5517-3959', 'jorge.mario@ferreteriaumg.com.gt', TO_DATE('2022-02-01','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Elvia Marina Choc Xol', 'Bodeguero', '5518-4096', 'elvia.marina@ferreteriaumg.com.gt', TO_DATE('2023-07-03','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Samuel Ordonez Tun', 'Bodeguero', '5519-4233', 'samuel.ordonez@ferreteriaumg.com.gt', TO_DATE('2024-03-18','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Lucrecia Fuentes Rivas', 'Contador', '5520-4370', 'lucrecia.fuentes@ferreteriaumg.com.gt', TO_DATE('2022-04-25','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Andrea Paola Gomez Ramos', 'Cajero', '5521-4507', 'andrea.paola@ferreteriaumg.com.gt', TO_DATE('2024-06-10','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Marvin Estuardo Lux Cuc', 'Cajero', '5522-4644', 'marvin.estuardo@ferreteriaumg.com.gt', TO_DATE('2025-01-13','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Silvia Patricia Reyes Orozco', 'Asistente de Compras', '5523-4781', 'silvia.patricia@ferreteriaumg.com.gt', TO_DATE('2023-11-06','YYYY-MM-DD'));
INSERT INTO EMPLEADOS (Nombre_Completo, Puesto, Telefono, Correo, Fecha_Ingreso) VALUES ('Hugo Rene Cabrera Soto', 'Supervisor de Ventas', '5524-4918', 'hugo.rene@ferreteriaumg.com.gt', TO_DATE('2022-08-22','YYYY-MM-DD'));

/* ------------------------------------------------------------------
   GRUPO 5: USUARIOS (15) - un usuario por empleado
   Contrasena_Hash = SHA-256 de datos de prueba (no son contrasenas reales)
   ------------------------------------------------------------------ */
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('ralvarado', '2bbc4f2050e69534855ca3e14286568e08d707ce3a7ff6709fa1cb67b8062621', 'Admin', 1);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('aescobar', 'dca25fcde87b4bd71d5736d6a6221f2a5b3f936eca8d62cef999392ba916f22b', 'Admin', 2);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('ksipac', 'bbb7e9fba3f49f71b7ee6648d71555bf92d93dc71f395d5fa69ed88e52dceb0c', 'Vendedor', 3);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('bcotzal', '936952fad7c9c5bb07de3a56535ae305deb3906644f6205f664894414330f350', 'Vendedor', 4);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('wchavez', '21f6479d440c47af42176150b2039b6ebff3ff13e108d223d4d8f7693cfdd2fc', 'Vendedor', 5);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('rmaria', '2a5f62c54ae3f4d5690fd2f182326537c2d23831e5b254b17622d7aa4c97232b', 'Vendedor', 6);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('darmando', '687540fa40c7f03661b946c33aa0a63e08a9e83183048fac538a5c8ebabf5139', 'Vendedor', 7);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('jmario', 'ec64ad01625a56c91b43604f75550558e6dd16791ecc8a659e6c0c049b4851c6', 'Bodeguero', 8);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('emarina', '5d6438ce5ee81df86aece584973eb97a27452b63bc40bc772c02ea4536d9b469', 'Bodeguero', 9);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('sordonez', '3a3cc6c52eacf24453bc0caff4f4de355bfb5c3ba71656461ce7e98488ea4684', 'Bodeguero', 10);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('lfuentes', '595f5e79b0f7a53918364972e367a557cc85ed58ed1ea884da8615f2ee700ee1', 'Admin', 11);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('apaola', 'd8327092cd8a7091c31d6fe910e7850d65de15b685edddd04532780e3fac30b9', 'Vendedor', 12);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('mestuardo', '2af23c44ef4c24acd93dddf722b105e69710894c646913f851a82b2e120742a4', 'Vendedor', 13);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('spatricia', '532e15021e28453627f6929536ec1c50e8ee7d92973dc7620b19d6763154fe7b', 'Bodeguero', 14);
INSERT INTO USUARIOS (Nombre_Usuario, Contrasena_Hash, Rol, ID_Empleado) VALUES ('hrene', '5d705a6915961a8b994cbd21cf54288258587275d05f400ae20ebb16c08e6200', 'Vendedor', 15);

/* ------------------------------------------------------------------
   GRUPO 2: PRODUCTOS (30)
   Stock_Actual ya refleja el saldo final del kardex (ver Seccion de kardex)
   ------------------------------------------------------------------ */
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401001000011', 'Martillo de una 16 oz', 38.00, 55.00, 37, 10, 1, 1, 1, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401001000028', 'Destornillador Phillips #2', 12.50, 22.00, 45, 15, 1, 3, 1, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401002000035', 'Taladro percutor 1/2 pulg 650W', 520.00, 749.00, 3, 4, 2, 4, 1, 2);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401002000042', 'Esmeriladora angular 4-1/2 pulg', 480.00, 695.00, 3, 4, 2, 2, 1, 2);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401003000059', 'Tubo PVC 1/2 pulg x 6 m', 22.00, 34.50, 70, 20, 3, 7, 1, 3);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401003000066', 'Llave de chorro 1/2 pulg cromada', 28.00, 45.00, 36, 12, 3, 1, 1, 3);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401004000073', 'Cable THHN #12 (rollo 100 m)', 310.00, 420.00, 4, 6, 4, 5, 7, 4);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401004000080', 'Interruptor sencillo blanco', 9.00, 16.00, 80, 25, 4, 5, 1, 4);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401005000097', 'Pintura latex blanca galon', 135.00, 185.00, 24, 10, 5, 6, 3, 5);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401005000103', 'Brocha 3 pulg', 14.00, 25.00, 34, 15, 5, 1, 1, 5);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401006000110', 'Tornillo drywall 1-1/4 pulg (caja 100)', 18.00, 30.00, 70, 20, 6, 5, 5, 6);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401006000127', 'Clavo de acero 3 pulg (libra)', 7.50, 12.00, 65, 30, 6, 1, 4, 6);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401007000134', 'Cemento gris 42.5 kg', 78.00, 98.00, 35, 40, 7, 8, 6, 7);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401007000141', 'Cal hidratada 25 kg', 32.00, 46.00, 30, 20, 7, 8, 6, 7);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401008000158', 'Casco de seguridad amarillo', 45.00, 72.00, 0, 8, 8, 1, 1, 8);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401008000165', 'Guantes de carnaza', 18.00, 30.00, 12, 15, 8, 1, 1, 8);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401001000172', 'Cinta metrica 5 m', 24.00, 40.00, 25, 10, 1, 3, 1, 9);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401002000189', 'Disco de corte metal 4-1/2 pulg', 11.00, 19.50, 82, 25, 2, 2, 1, 10);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401003000196', 'Manguera de jardin 1/2 pulg (metro)', 6.50, 11.00, 40, 50, 3, 7, 2, 11);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401004000202', 'Lampara LED 9W', 7.00, 13.50, 96, 30, 4, 5, 1, 12);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401001000219', 'Alicate universal 8 pulg', 32.00, 48.00, 30, 10, 1, 1, 1, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401001000226', 'Serrucho de costilla 14 pulg', 28.00, 42.00, 20, 8, 1, 5, 1, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401001000233', 'Llave ajustable 10 pulg', 55.00, 82.00, 18, 6, 1, 3, 1, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401001000240', 'Nivel de burbuja 24 pulg', 42.00, 65.00, 15, 5, 1, 3, 1, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401001000257', 'Juego de llaves Allen 9 piezas', 26.00, 40.00, 25, 8, 1, 1, 5, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401003000264', 'Codo PVC 1/2 pulg', 2.50, 4.50, 200, 60, 3, 7, 1, 3);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401003000271', 'Cinta teflon 3/4 pulg', 3.00, 6.00, 150, 50, 3, 1, 7, 3);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401003000288', 'Pegamento para PVC galon', 95.00, 135.00, 20, 8, 3, 7, 3, 3);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401003000295', 'Tubo PVC 3/4 pulg x 6 m', 35.00, 52.00, 50, 20, 3, 7, 1, 3);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Marca, ID_Unidad, ID_Proveedor) VALUES ('7401003000301', 'Llave de paso 1/2 pulg bronce', 48.00, 75.00, 24, 10, 3, 1, 1, 3);

/* ------------------------------------------------------------------
   GRUPO 3: COMPRAS_ENCABEZADO (17)
   ------------------------------------------------------------------ */
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0001', TO_DATE('2026-05-04 08:30:00','YYYY-MM-DD HH24:MI:SS'), 2270.00, 272.40, 2542.40, 'RECIBIDA', 1, 14);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0002', TO_DATE('2026-05-06 08:30:00','YYYY-MM-DD HH24:MI:SS'), 11040.00, 1324.80, 12364.80, 'RECIBIDA', 2, 9);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0003', TO_DATE('2026-05-08 08:30:00','YYYY-MM-DD HH24:MI:SS'), 2880.00, 345.60, 3225.60, 'RECIBIDA', 3, 2);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0004', TO_DATE('2026-05-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 5550.00, 666.00, 6216.00, 'RECIBIDA', 4, 14);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0005', TO_DATE('2026-05-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 4610.00, 553.20, 5163.20, 'RECIBIDA', 5, 9);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0006', TO_DATE('2026-05-14 08:30:00','YYYY-MM-DD HH24:MI:SS'), 2340.00, 280.80, 2620.80, 'RECIBIDA', 6, 14);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0007', TO_DATE('2026-05-16 08:30:00','YYYY-MM-DD HH24:MI:SS'), 13620.00, 1634.40, 15254.40, 'RECIBIDA', 7, 2);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0008', TO_DATE('2026-05-18 08:30:00','YYYY-MM-DD HH24:MI:SS'), 2025.00, 243.00, 2268.00, 'RECIBIDA', 8, 9);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0009', TO_DATE('2026-05-20 08:30:00','YYYY-MM-DD HH24:MI:SS'), 720.00, 86.40, 806.40, 'RECIBIDA', 9, 14);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0010', TO_DATE('2026-05-22 08:30:00','YYYY-MM-DD HH24:MI:SS'), 1100.00, 132.00, 1232.00, 'RECIBIDA', 10, 9);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0011', TO_DATE('2026-05-24 08:30:00','YYYY-MM-DD HH24:MI:SS'), 1300.00, 156.00, 1456.00, 'RECIBIDA', 11, 2);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0012', TO_DATE('2026-05-26 08:30:00','YYYY-MM-DD HH24:MI:SS'), 840.00, 100.80, 940.80, 'RECIBIDA', 12, 14);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0013', TO_DATE('2026-08-20 08:30:00','YYYY-MM-DD HH24:MI:SS'), 7800.00, 936.00, 8736.00, 'RECIBIDA', 7, 9);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0014', TO_DATE('2026-09-15 08:30:00','YYYY-MM-DD HH24:MI:SS'), 6200.00, 744.00, 6944.00, 'ANULADA', 4, 14);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0015', TO_DATE('2026-10-05 08:30:00','YYYY-MM-DD HH24:MI:SS'), 9040.00, 1084.80, 10124.80, 'PENDIENTE', 2, 14);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0016', TO_DATE('2026-10-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 3790.00, 454.80, 4244.80, 'RECIBIDA', 1, 2);
INSERT INTO COMPRAS_ENCABEZADO (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra, Estado, ID_Proveedor, ID_Empleado) VALUES ('COMP-0017', TO_DATE('2026-10-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 5752.00, 690.24, 6442.24, 'RECIBIDA', 3, 9);

/* ------------------------------------------------------------------
   GRUPO 3: COMPRAS_DETALLE
   ------------------------------------------------------------------ */
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (1, 1, 40, 38.00, 1520.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (1, 2, 60, 12.50, 750.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (2, 3, 12, 520.00, 6240.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (2, 4, 10, 480.00, 4800.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (3, 5, 80, 22.00, 1760.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (3, 6, 40, 28.00, 1120.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (4, 7, 15, 310.00, 4650.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (4, 8, 100, 9.00, 900.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (5, 9, 30, 135.00, 4050.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (5, 10, 40, 14.00, 560.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (6, 11, 80, 18.00, 1440.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (6, 12, 120, 7.50, 900.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (7, 13, 150, 78.00, 11700.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (7, 14, 60, 32.00, 1920.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (8, 15, 25, 45.00, 1125.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (8, 16, 50, 18.00, 900.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (9, 17, 30, 24.00, 720.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (10, 18, 100, 11.00, 1100.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (11, 19, 200, 6.50, 1300.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (12, 20, 120, 7.00, 840.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (13, 13, 100, 78.00, 7800.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (14, 7, 20, 310.00, 6200.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (15, 3, 10, 520.00, 5200.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (15, 4, 8, 480.00, 3840.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (16, 21, 30, 32.00, 960.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (16, 22, 20, 28.00, 560.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (16, 23, 18, 55.00, 990.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (16, 24, 15, 42.00, 630.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (16, 25, 25, 26.00, 650.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (17, 26, 200, 2.50, 500.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (17, 27, 150, 3.00, 450.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (17, 28, 20, 95.00, 1900.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (17, 29, 50, 35.00, 1750.00);
INSERT INTO COMPRAS_DETALLE (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (17, 30, 24, 48.00, 1152.00);

/* ------------------------------------------------------------------
   GRUPO 4: FACTURAS_ENCABEZADO (14)
   ------------------------------------------------------------------ */
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0001', TO_DATE('2026-06-03 08:30:00','YYYY-MM-DD HH24:MI:SS'), 325.00, 39.00, 364.00, 'PAGADO', 1, 3, 1);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0002', TO_DATE('2026-06-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 1693.00, 203.16, 1896.16, 'PAGADO', 2, 4, 2);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0003', TO_DATE('2026-06-18 08:30:00','YYYY-MM-DD HH24:MI:SS'), 6980.00, 837.60, 7817.60, 'PAGADO', 3, 3, 3);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0004', TO_DATE('2026-07-02 08:30:00','YYYY-MM-DD HH24:MI:SS'), 855.00, 102.60, 957.60, 'PAGADO', 4, 5, 1);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0005', TO_DATE('2026-07-09 08:30:00','YYYY-MM-DD HH24:MI:SS'), 1510.00, 181.20, 1691.20, 'PAGADO', 5, 6, 2);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0006', TO_DATE('2026-07-21 08:30:00','YYYY-MM-DD HH24:MI:SS'), 2744.00, 329.28, 3073.28, 'PAGADO', 6, 4, 3);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0007', TO_DATE('2026-08-05 08:30:00','YYYY-MM-DD HH24:MI:SS'), 2601.00, 312.12, 2913.12, 'PAGADO', 7, 7, 1);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0008', TO_DATE('2026-08-14 08:30:00','YYYY-MM-DD HH24:MI:SS'), 8300.00, 996.00, 9296.00, 'PAGADO', 8, 5, 4);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0009', TO_DATE('2026-08-25 08:30:00','YYYY-MM-DD HH24:MI:SS'), 3587.00, 430.44, 4017.44, 'PAGADO', 9, 3, 2);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0010', TO_DATE('2026-09-03 08:30:00','YYYY-MM-DD HH24:MI:SS'), 9260.00, 1111.20, 10371.20, 'PAGADO', 10, 6, 3);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0011', TO_DATE('2026-09-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 6380.00, 765.60, 7145.60, 'PAGADO', 11, 7, 1);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0012', TO_DATE('2026-09-22 08:30:00','YYYY-MM-DD HH24:MI:SS'), 2423.00, 290.76, 2713.76, 'PENDIENTE', 12, 4, 5);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0013', TO_DATE('2026-10-01 08:30:00','YYYY-MM-DD HH24:MI:SS'), 1140.00, 136.80, 1276.80, 'ANULADO', 13, 5, 4);
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura, Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago) VALUES ('FAC-0014', TO_DATE('2026-10-08 08:30:00','YYYY-MM-DD HH24:MI:SS'), 3576.00, 429.12, 4005.12, 'PAGADO', 14, 3, 1);

/* ------------------------------------------------------------------
   GRUPO 4: FACTURAS_DETALLE
   ------------------------------------------------------------------ */
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (1, 1, 3, 55.00, 165.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (1, 2, 5, 22.00, 110.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (1, 10, 2, 25.00, 50.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (2, 3, 2, 749.00, 1498.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (2, 18, 10, 19.50, 195.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (3, 13, 60, 98.00, 5880.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (3, 14, 20, 46.00, 920.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (3, 12, 15, 12.00, 180.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (4, 5, 10, 34.50, 345.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (4, 6, 4, 45.00, 180.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (4, 19, 30, 11.00, 330.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (5, 9, 6, 185.00, 1110.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (5, 10, 4, 25.00, 100.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (5, 11, 10, 30.00, 300.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (6, 7, 5, 420.00, 2100.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (6, 8, 20, 16.00, 320.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (6, 20, 24, 13.50, 324.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (7, 4, 3, 695.00, 2085.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (7, 18, 8, 19.50, 156.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (7, 16, 12, 30.00, 360.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (8, 13, 80, 98.00, 7840.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (8, 14, 10, 46.00, 460.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (9, 3, 3, 749.00, 2247.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (9, 15, 10, 72.00, 720.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (9, 16, 14, 30.00, 420.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (9, 17, 5, 40.00, 200.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (10, 13, 75, 98.00, 7350.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (10, 19, 130, 11.00, 1430.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (10, 12, 40, 12.00, 480.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (11, 7, 6, 420.00, 2520.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (11, 4, 4, 695.00, 2780.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (11, 15, 15, 72.00, 1080.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (12, 3, 2, 749.00, 1498.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (12, 9, 5, 185.00, 925.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (13, 5, 20, 34.50, 690.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (13, 6, 10, 45.00, 450.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (14, 3, 4, 749.00, 2996.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (14, 16, 12, 30.00, 360.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES (14, 2, 10, 22.00, 220.00);

/* ------------------------------------------------------------------
   GRUPO 2: MOVIMIENTOS_INVENTARIO (kardex) - en orden cronologico
   ENTRADA por cada compra RECIBIDA, SALIDA por cada factura PAGADO
   ------------------------------------------------------------------ */
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (1, TO_DATE('2026-05-04 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 40, 40, 1, NULL, 'Ingreso por compra COMP-0001');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (2, TO_DATE('2026-05-04 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 60, 60, 1, NULL, 'Ingreso por compra COMP-0001');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (3, TO_DATE('2026-05-06 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 12, 12, 2, NULL, 'Ingreso por compra COMP-0002');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (4, TO_DATE('2026-05-06 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 10, 10, 2, NULL, 'Ingreso por compra COMP-0002');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (5, TO_DATE('2026-05-08 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 80, 80, 3, NULL, 'Ingreso por compra COMP-0003');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (6, TO_DATE('2026-05-08 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 40, 40, 3, NULL, 'Ingreso por compra COMP-0003');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (7, TO_DATE('2026-05-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 15, 15, 4, NULL, 'Ingreso por compra COMP-0004');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (8, TO_DATE('2026-05-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 100, 100, 4, NULL, 'Ingreso por compra COMP-0004');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (9, TO_DATE('2026-05-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 30, 30, 5, NULL, 'Ingreso por compra COMP-0005');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (10, TO_DATE('2026-05-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 40, 40, 5, NULL, 'Ingreso por compra COMP-0005');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (11, TO_DATE('2026-05-14 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 80, 80, 6, NULL, 'Ingreso por compra COMP-0006');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (12, TO_DATE('2026-05-14 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 120, 120, 6, NULL, 'Ingreso por compra COMP-0006');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (13, TO_DATE('2026-05-16 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 150, 150, 7, NULL, 'Ingreso por compra COMP-0007');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (14, TO_DATE('2026-05-16 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 60, 60, 7, NULL, 'Ingreso por compra COMP-0007');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (15, TO_DATE('2026-05-18 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 25, 25, 8, NULL, 'Ingreso por compra COMP-0008');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (16, TO_DATE('2026-05-18 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 50, 50, 8, NULL, 'Ingreso por compra COMP-0008');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (17, TO_DATE('2026-05-20 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 30, 30, 9, NULL, 'Ingreso por compra COMP-0009');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (18, TO_DATE('2026-05-22 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 100, 100, 10, NULL, 'Ingreso por compra COMP-0010');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (19, TO_DATE('2026-05-24 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 200, 200, 11, NULL, 'Ingreso por compra COMP-0011');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (20, TO_DATE('2026-05-26 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 120, 120, 12, NULL, 'Ingreso por compra COMP-0012');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (1, TO_DATE('2026-06-03 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 3, 37, NULL, 1, 'Venta factura FAC-0001');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (2, TO_DATE('2026-06-03 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 5, 55, NULL, 1, 'Venta factura FAC-0001');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (10, TO_DATE('2026-06-03 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 2, 38, NULL, 1, 'Venta factura FAC-0001');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (3, TO_DATE('2026-06-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 2, 10, NULL, 2, 'Venta factura FAC-0002');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (18, TO_DATE('2026-06-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 10, 90, NULL, 2, 'Venta factura FAC-0002');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (13, TO_DATE('2026-06-18 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 60, 90, NULL, 3, 'Venta factura FAC-0003');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (14, TO_DATE('2026-06-18 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 20, 40, NULL, 3, 'Venta factura FAC-0003');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (12, TO_DATE('2026-06-18 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 15, 105, NULL, 3, 'Venta factura FAC-0003');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (5, TO_DATE('2026-07-02 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 10, 70, NULL, 4, 'Venta factura FAC-0004');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (6, TO_DATE('2026-07-02 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 4, 36, NULL, 4, 'Venta factura FAC-0004');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (19, TO_DATE('2026-07-02 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 30, 170, NULL, 4, 'Venta factura FAC-0004');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (9, TO_DATE('2026-07-09 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 6, 24, NULL, 5, 'Venta factura FAC-0005');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (10, TO_DATE('2026-07-09 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 4, 34, NULL, 5, 'Venta factura FAC-0005');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (11, TO_DATE('2026-07-09 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 10, 70, NULL, 5, 'Venta factura FAC-0005');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (7, TO_DATE('2026-07-21 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 5, 10, NULL, 6, 'Venta factura FAC-0006');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (8, TO_DATE('2026-07-21 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 20, 80, NULL, 6, 'Venta factura FAC-0006');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (20, TO_DATE('2026-07-21 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 24, 96, NULL, 6, 'Venta factura FAC-0006');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (4, TO_DATE('2026-08-05 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 3, 7, NULL, 7, 'Venta factura FAC-0007');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (18, TO_DATE('2026-08-05 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 8, 82, NULL, 7, 'Venta factura FAC-0007');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (16, TO_DATE('2026-08-05 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 12, 38, NULL, 7, 'Venta factura FAC-0007');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (13, TO_DATE('2026-08-14 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 80, 10, NULL, 8, 'Venta factura FAC-0008');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (14, TO_DATE('2026-08-14 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 10, 30, NULL, 8, 'Venta factura FAC-0008');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (13, TO_DATE('2026-08-20 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 100, 110, 13, NULL, 'Ingreso por compra COMP-0013');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (3, TO_DATE('2026-08-25 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 3, 7, NULL, 9, 'Venta factura FAC-0009');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (15, TO_DATE('2026-08-25 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 10, 15, NULL, 9, 'Venta factura FAC-0009');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (16, TO_DATE('2026-08-25 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 14, 24, NULL, 9, 'Venta factura FAC-0009');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (17, TO_DATE('2026-08-25 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 5, 25, NULL, 9, 'Venta factura FAC-0009');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (13, TO_DATE('2026-09-03 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 75, 35, NULL, 10, 'Venta factura FAC-0010');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (19, TO_DATE('2026-09-03 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 130, 40, NULL, 10, 'Venta factura FAC-0010');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (12, TO_DATE('2026-09-03 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 40, 65, NULL, 10, 'Venta factura FAC-0010');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (7, TO_DATE('2026-09-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 6, 4, NULL, 11, 'Venta factura FAC-0011');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (4, TO_DATE('2026-09-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 4, 3, NULL, 11, 'Venta factura FAC-0011');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (15, TO_DATE('2026-09-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 15, 0, NULL, 11, 'Venta factura FAC-0011');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (3, TO_DATE('2026-10-08 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 4, 3, NULL, 14, 'Venta factura FAC-0014');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (16, TO_DATE('2026-10-08 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 12, 12, NULL, 14, 'Venta factura FAC-0014');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (2, TO_DATE('2026-10-08 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'SALIDA', 10, 45, NULL, 14, 'Venta factura FAC-0014');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (21, TO_DATE('2026-10-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 30, 30, 16, NULL, 'Ingreso por compra COMP-0016');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (22, TO_DATE('2026-10-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 20, 20, 16, NULL, 'Ingreso por compra COMP-0016');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (23, TO_DATE('2026-10-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 18, 18, 16, NULL, 'Ingreso por compra COMP-0016');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (24, TO_DATE('2026-10-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 15, 15, 16, NULL, 'Ingreso por compra COMP-0016');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (25, TO_DATE('2026-10-10 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 25, 25, 16, NULL, 'Ingreso por compra COMP-0016');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (26, TO_DATE('2026-10-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 200, 200, 17, NULL, 'Ingreso por compra COMP-0017');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (27, TO_DATE('2026-10-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 150, 150, 17, NULL, 'Ingreso por compra COMP-0017');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (28, TO_DATE('2026-10-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 20, 20, 17, NULL, 'Ingreso por compra COMP-0017');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (29, TO_DATE('2026-10-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 50, 50, 17, NULL, 'Ingreso por compra COMP-0017');
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, ID_Compra, ID_Factura, Observacion) VALUES (30, TO_DATE('2026-10-12 08:30:00','YYYY-MM-DD HH24:MI:SS'), 'ENTRADA', 24, 24, 17, NULL, 'Ingreso por compra COMP-0017');

COMMIT;


/* ------------------------------------------------------------------
   VERIFICACION DE LA CARGA
   ------------------------------------------------------------------ */
-- 1) Conteo de registros por tabla
SELECT 'CATEGORIAS' tabla, COUNT(*) filas FROM CATEGORIAS UNION ALL
SELECT 'MARCAS', COUNT(*) FROM MARCAS UNION ALL
SELECT 'UNIDADES_MEDIDA', COUNT(*) FROM UNIDADES_MEDIDA UNION ALL
SELECT 'METODOS_PAGO', COUNT(*) FROM METODOS_PAGO UNION ALL
SELECT 'PROVEEDORES', COUNT(*) FROM PROVEEDORES UNION ALL
SELECT 'CLIENTES', COUNT(*) FROM CLIENTES UNION ALL
SELECT 'EMPLEADOS', COUNT(*) FROM EMPLEADOS UNION ALL
SELECT 'USUARIOS', COUNT(*) FROM USUARIOS UNION ALL
SELECT 'PRODUCTOS', COUNT(*) FROM PRODUCTOS UNION ALL
SELECT 'COMPRAS_ENCABEZADO', COUNT(*) FROM COMPRAS_ENCABEZADO UNION ALL
SELECT 'COMPRAS_DETALLE', COUNT(*) FROM COMPRAS_DETALLE UNION ALL
SELECT 'FACTURAS_ENCABEZADO', COUNT(*) FROM FACTURAS_ENCABEZADO UNION ALL
SELECT 'FACTURAS_DETALLE', COUNT(*) FROM FACTURAS_DETALLE UNION ALL
SELECT 'MOVIMIENTOS_INVENTARIO', COUNT(*) FROM MOVIMIENTOS_INVENTARIO;

-- 2) Coherencia: el stock de cada producto debe coincidir con el saldo
--    de su ultimo movimiento del kardex (debe devolver 0 filas)
SELECT p.ID_Producto, p.Nombre_Producto, p.Stock_Actual
  FROM PRODUCTOS p
 WHERE p.Stock_Actual <> NVL((SELECT m.Saldo_Resultante
                                FROM MOVIMIENTOS_INVENTARIO m
                               WHERE m.ID_Movimiento = (SELECT MAX(m2.ID_Movimiento)
                                                          FROM MOVIMIENTOS_INVENTARIO m2
                                                         WHERE m2.ID_Producto = p.ID_Producto)), 0);

-- 3) Casos limite: productos en o bajo el stock minimo
SELECT ID_Producto, Nombre_Producto, Stock_Actual, Stock_Minimo
  FROM PRODUCTOS
 WHERE Stock_Actual <= Stock_Minimo
 ORDER BY Stock_Actual;
