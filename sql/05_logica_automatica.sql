/* ==================================================================
   UNIVERSIDAD MARIANO GALVEZ DE GUATEMALA - BASE DE DATOS I
   PROYECTO FINAL: SISTEMA DE INVENTARIO Y FACTURACION (FERRETERIA)
   SGBD: Oracle Database 21c XE | Esquema: FERRETERIADB
   ------------------------------------------------------------------
   05_logica_automatica.sql
   Automatiza el calculo de totales y la actualizacion del stock:
   3 triggers, 4 tipos de coleccion, 2 procedimientos almacenados
   (registrar factura y registrar compra) y 2 vistas.
   Ejecutar conectado como FERRETERIADB, despues de 03_dml_datos_prueba.sql.
   Los bloques PL/SQL terminan con una linea que solo contiene "/".
   Es re-ejecutable (CREATE OR REPLACE).
   ================================================================== */

/* ##################################################################
   SECCION 4A: TRIGGERS
   ################################################################## */
/* ==================================================================
   SECCION 4A: TRIGGERS (disparadores)
   ------------------------------------------------------------------
   DIVISION DE TRABAJO
   - Procedimientos (siguiente parte): descuentan/suman el stock y
     registran el kardex.
   - TRG_FACTDET_VALIDA_STOCK: SOLO impide vender mas del stock
     disponible. No modifica el stock (asi no se descuenta dos veces).
   - TRG_FACTDET_TOTALES y TRG_COMPDET_TOTALES: SOLO recalculan los
     totales del encabezado (subtotal, IVA 12 % y total).

   NOTA TECNICA: los triggers de totales son COMPOUND TRIGGER. Un
   trigger normal por fila que consulte su propia tabla de detalle
   produce el error ORA-04091 (tabla mutante). El compound guarda los
   IDs afectados fila por fila y recalcula una sola vez al terminar la
   sentencia (AFTER STATEMENT), cuando la tabla ya es consultable.
   ================================================================== */


/* ------------------------------------------------------------------
   TRIGGER 1: Control de stock preventivo (facturas)
   Se dispara al insertar o modificar cantidad/producto en el detalle
   de venta. Si Cantidad > Stock_Actual, cancela la operacion.
   ------------------------------------------------------------------ */
CREATE OR REPLACE TRIGGER TRG_FACTDET_VALIDA_STOCK
BEFORE INSERT OR UPDATE OF Cantidad, ID_Producto ON FACTURAS_DETALLE
FOR EACH ROW
DECLARE
    v_stock   PRODUCTOS.Stock_Actual%TYPE;
    v_nombre  PRODUCTOS.Nombre_Producto%TYPE;
BEGIN
    SELECT Stock_Actual, Nombre_Producto
      INTO v_stock, v_nombre
      FROM PRODUCTOS
     WHERE ID_Producto = :NEW.ID_Producto;
    IF :NEW.Cantidad > v_stock THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Stock insuficiente para "' || v_nombre || '": solicitado '
            || :NEW.Cantidad || ', disponible ' || v_stock);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;  -- producto inexistente: lo rechaza la llave foranea
END;
/


/* ------------------------------------------------------------------
   TRIGGER 2: Calculo dinamico de totales (facturas)
   Ante INSERT, UPDATE o DELETE en FACTURAS_DETALLE recalcula
   Subtotal, Impuesto (12 %) y Total_Factura del encabezado.
   Si la factura se queda sin detalles no se recalcula (los CHECK
   exigen subtotal > 0) y tampoco interfiere con el borrado en cascada.
   ------------------------------------------------------------------ */
CREATE OR REPLACE TRIGGER TRG_FACTDET_TOTALES
FOR INSERT OR UPDATE OR DELETE ON FACTURAS_DETALLE
COMPOUND TRIGGER
    TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    g_ids t_ids;
    AFTER EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            g_ids(:NEW.ID_Factura) := 1;
        END IF;
        IF DELETING OR UPDATING THEN
            g_ids(:OLD.ID_Factura) := 1;
        END IF;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        v_id   PLS_INTEGER;
        v_sub  NUMBER;
        v_imp  NUMBER;
        v_cnt  NUMBER;
    BEGIN
        v_id := g_ids.FIRST;
        WHILE v_id IS NOT NULL LOOP
            SELECT NVL(SUM(Subtotal), 0), COUNT(*)
              INTO v_sub, v_cnt
              FROM FACTURAS_DETALLE
             WHERE ID_Factura = v_id;
            IF v_cnt > 0 THEN
                v_imp := ROUND(v_sub * 0.12, 2);
                UPDATE FACTURAS_ENCABEZADO
                   SET Subtotal      = v_sub,
                       Impuesto      = v_imp,
                       Total_Factura = v_sub + v_imp
                 WHERE ID_Factura = v_id;
            END IF;
            v_id := g_ids.NEXT(v_id);
        END LOOP;
        g_ids.DELETE;
    END AFTER STATEMENT;
END TRG_FACTDET_TOTALES;
/


/* ------------------------------------------------------------------
   TRIGGER 3: Calculo dinamico de totales (compras)
   Igual que el anterior, sobre COMPRAS_DETALLE / COMPRAS_ENCABEZADO.
   ------------------------------------------------------------------ */
CREATE OR REPLACE TRIGGER TRG_COMPDET_TOTALES
FOR INSERT OR UPDATE OR DELETE ON COMPRAS_DETALLE
COMPOUND TRIGGER
    TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    g_ids t_ids;
    AFTER EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            g_ids(:NEW.ID_Compra) := 1;
        END IF;
        IF DELETING OR UPDATING THEN
            g_ids(:OLD.ID_Compra) := 1;
        END IF;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        v_id   PLS_INTEGER;
        v_sub  NUMBER;
        v_imp  NUMBER;
        v_cnt  NUMBER;
    BEGIN
        v_id := g_ids.FIRST;
        WHILE v_id IS NOT NULL LOOP
            SELECT NVL(SUM(Subtotal), 0), COUNT(*)
              INTO v_sub, v_cnt
              FROM COMPRAS_DETALLE
             WHERE ID_Compra = v_id;
            IF v_cnt > 0 THEN
                v_imp := ROUND(v_sub * 0.12, 2);
                UPDATE COMPRAS_ENCABEZADO
                   SET Subtotal     = v_sub,
                       Impuesto     = v_imp,
                       Total_Compra = v_sub + v_imp
                 WHERE ID_Compra = v_id;
            END IF;
            v_id := g_ids.NEXT(v_id);
        END LOOP;
        g_ids.DELETE;
    END AFTER STATEMENT;
END TRG_COMPDET_TOTALES;
/


/* ------------------------------------------------------------------
   VERIFICACION: los 3 triggers deben aparecer VALID y ENABLED
   ------------------------------------------------------------------ */
SELECT o.object_name AS trigger_name, o.status AS compilacion, t.status AS estado
  FROM user_objects o
  JOIN user_triggers t ON t.trigger_name = o.object_name
 WHERE o.object_type = 'TRIGGER'
 ORDER BY o.object_name;


/* ##################################################################
   SECCION 4B: TIPOS Y PROCEDIMIENTOS ALMACENADOS
   ################################################################## */
/* ==================================================================
   SECCION 4B: PROCEDIMIENTOS ALMACENADOS
   ------------------------------------------------------------------
   DIVISION DE TRABAJO (ver Seccion 4A de triggers)
   - Los procedimientos descuentan/suman el stock y registran el kardex.
   - TRG_FACTDET_VALIDA_STOCK vuelve a validar el stock en cada linea
     (doble seguridad) y los triggers de totales mantienen el
     encabezado al insertar el detalle.
   - Los procedimientos NO hacen COMMIT: lo hace quien los llama. Si
     ocurre un error, Oracle deshace todo lo que hizo la llamada.

   CODIGOS DE ERROR PROPIOS
   -20001 stock insuficiente         -20002 documento sin lineas
   -20003 cantidad o precio invalido -20004 producto repetido en lineas
   -20005 producto inexistente       -20006 producto de otro proveedor
   ================================================================== */


/* ------------------------------------------------------------------
   TIPOS DE COLECCION: reciben el detalle del documento como lista
   (el DROP de la Seccion 1 ya los elimina con DROP TYPE)
   ------------------------------------------------------------------ */
CREATE OR REPLACE TYPE T_LINEA_VENTA AS OBJECT (
    ID_Producto  NUMBER,
    Cantidad     NUMBER
);
/

CREATE OR REPLACE TYPE T_LINEAS_VENTA AS TABLE OF T_LINEA_VENTA;
/

CREATE OR REPLACE TYPE T_LINEA_COMPRA AS OBJECT (
    ID_Producto      NUMBER,
    Cantidad         NUMBER,
    Precio_Unitario  NUMBER      -- NULL = usar Precio_Compra del producto
);
/

CREATE OR REPLACE TYPE T_LINEAS_COMPRA AS TABLE OF T_LINEA_COMPRA;
/


/* ------------------------------------------------------------------
   PROCEDIMIENTO 1: PROCESO DE FACTURACION
   Recibe encabezado (cliente, empleado, metodo de pago) y detalle
   (lista de producto/cantidad). Pasos:
     1. Valida lineas y verifica disponibilidad de inventario.
     2. Calcula subtotal, IVA (12 %) y total con el Precio_Venta vigente.
     3. Inserta el encabezado (estado PAGADO) y sus lineas.
     4. Descuenta Stock_Actual y registra la SALIDA en el kardex.
   Devuelve el ID y el numero de la factura creada.
   ------------------------------------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_FACTURA (
    p_id_cliente      IN  NUMBER,
    p_id_empleado     IN  NUMBER,
    p_id_metodo_pago  IN  NUMBER,
    p_lineas          IN  T_LINEAS_VENTA,
    p_id_factura      OUT NUMBER,
    p_numero_factura  OUT VARCHAR2
) AS
    c_iva       CONSTANT NUMBER := 0.12;
    v_subtotal  NUMBER := 0;
    v_impuesto  NUMBER;
    v_id_prod   NUMBER;
    v_cant      NUMBER;
    v_nombre    PRODUCTOS.Nombre_Producto%TYPE;
    v_precio    PRODUCTOS.Precio_Venta%TYPE;
    v_stock     PRODUCTOS.Stock_Actual%TYPE;
    v_saldo     PRODUCTOS.Stock_Actual%TYPE;
    v_sig       NUMBER;
BEGIN
    IF p_lineas IS NULL OR p_lineas.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'La factura debe tener al menos una linea de detalle');
    END IF;
    -- PASADA 1: validar lineas, bloquear productos y verificar stock
    FOR i IN 1 .. p_lineas.COUNT LOOP
        v_id_prod := p_lineas(i).ID_Producto;
        v_cant    := p_lineas(i).Cantidad;
        IF v_cant IS NULL OR v_cant <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La cantidad de la linea ' || i || ' debe ser mayor a cero');
        END IF;
        FOR j IN 1 .. i - 1 LOOP
            IF p_lineas(j).ID_Producto = v_id_prod THEN
                RAISE_APPLICATION_ERROR(-20004, 'El producto ' || v_id_prod || ' esta repetido en el detalle');
            END IF;
        END LOOP;
        BEGIN
            SELECT Nombre_Producto, Precio_Venta, Stock_Actual
              INTO v_nombre, v_precio, v_stock
              FROM PRODUCTOS
             WHERE ID_Producto = v_id_prod
               FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20005, 'El producto ' || v_id_prod || ' no existe');
        END;
        IF v_cant > v_stock THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Stock insuficiente para "' || v_nombre || '": solicitado '
                || v_cant || ', disponible ' || v_stock);
        END IF;
        v_subtotal := v_subtotal + v_precio * v_cant;
    END LOOP;
    -- Totales y numero correlativo (FAC-0001, FAC-0002, ...)
    v_impuesto := ROUND(v_subtotal * c_iva, 2);
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(Numero_Factura, 5))), 0) + 1
      INTO v_sig
      FROM FACTURAS_ENCABEZADO;
    p_numero_factura := 'FAC-' || LPAD(v_sig, 4, '0');
    -- Encabezado
    INSERT INTO FACTURAS_ENCABEZADO
           (Numero_Factura, Fecha_Emision, Subtotal, Impuesto, Total_Factura,
            Estado, ID_Cliente, ID_Empleado, ID_Metodo_Pago)
    VALUES (p_numero_factura, SYSDATE, v_subtotal, v_impuesto, v_subtotal + v_impuesto,
            'PAGADO', p_id_cliente, p_id_empleado, p_id_metodo_pago)
    RETURNING ID_Factura INTO p_id_factura;
    -- PASADA 2: detalle, descuento de stock y kardex
    FOR i IN 1 .. p_lineas.COUNT LOOP
        v_id_prod := p_lineas(i).ID_Producto;
        v_cant    := p_lineas(i).Cantidad;
        SELECT Precio_Venta INTO v_precio
          FROM PRODUCTOS WHERE ID_Producto = v_id_prod;
        INSERT INTO FACTURAS_DETALLE
               (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Subtotal)
        VALUES (p_id_factura, v_id_prod, v_cant, v_precio, v_precio * v_cant);
        UPDATE PRODUCTOS
           SET Stock_Actual = Stock_Actual - v_cant
         WHERE ID_Producto = v_id_prod
        RETURNING Stock_Actual INTO v_saldo;
        INSERT INTO MOVIMIENTOS_INVENTARIO
               (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad,
                Saldo_Resultante, ID_Compra, ID_Factura, Observacion)
        VALUES (v_id_prod, SYSDATE, 'SALIDA', v_cant,
                v_saldo, NULL, p_id_factura, 'Venta factura ' || p_numero_factura);
    END LOOP;
END SP_REGISTRAR_FACTURA;
/


/* ------------------------------------------------------------------
   PROCEDIMIENTO 2: PROCESO DE COMPRA E INVENTARIO
   Registra el ingreso de mercaderia a un proveedor:
     1. Valida lineas (cantidad > 0, producto existente y que
        pertenezca al proveedor de la compra).
     2. Calcula subtotal, IVA (12 %) y total.
     3. Inserta el encabezado (estado RECIBIDA) y sus lineas.
     4. Incrementa Stock_Actual y registra la ENTRADA en el kardex.
   Si Precio_Unitario viene NULL se usa el Precio_Compra del producto.
   ------------------------------------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_COMPRA (
    p_id_proveedor   IN  NUMBER,
    p_id_empleado    IN  NUMBER,
    p_lineas         IN  T_LINEAS_COMPRA,
    p_id_compra      OUT NUMBER,
    p_numero_compra  OUT VARCHAR2
) AS
    c_iva       CONSTANT NUMBER := 0.12;
    v_subtotal  NUMBER := 0;
    v_impuesto  NUMBER;
    v_id_prod   NUMBER;
    v_cant      NUMBER;
    v_precio    NUMBER;
    v_nombre    PRODUCTOS.Nombre_Producto%TYPE;
    v_pcompra   PRODUCTOS.Precio_Compra%TYPE;
    v_prov      PRODUCTOS.ID_Proveedor%TYPE;
    v_saldo     PRODUCTOS.Stock_Actual%TYPE;
    v_sig       NUMBER;
BEGIN
    IF p_lineas IS NULL OR p_lineas.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'La compra debe tener al menos una linea de detalle');
    END IF;
    -- PASADA 1: validar lineas y calcular subtotal
    FOR i IN 1 .. p_lineas.COUNT LOOP
        v_id_prod := p_lineas(i).ID_Producto;
        v_cant    := p_lineas(i).Cantidad;
        IF v_cant IS NULL OR v_cant <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La cantidad de la linea ' || i || ' debe ser mayor a cero');
        END IF;
        FOR j IN 1 .. i - 1 LOOP
            IF p_lineas(j).ID_Producto = v_id_prod THEN
                RAISE_APPLICATION_ERROR(-20004, 'El producto ' || v_id_prod || ' esta repetido en el detalle');
            END IF;
        END LOOP;
        BEGIN
            SELECT Nombre_Producto, Precio_Compra, ID_Proveedor
              INTO v_nombre, v_pcompra, v_prov
              FROM PRODUCTOS
             WHERE ID_Producto = v_id_prod
               FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20005, 'El producto ' || v_id_prod || ' no existe');
        END;
        IF v_prov <> p_id_proveedor THEN
            RAISE_APPLICATION_ERROR(-20006,
                'El producto "' || v_nombre || '" no pertenece al proveedor ' || p_id_proveedor);
        END IF;
        v_precio := NVL(p_lineas(i).Precio_Unitario, v_pcompra);
        IF v_precio <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'El precio de la linea ' || i || ' debe ser mayor a cero');
        END IF;
        v_subtotal := v_subtotal + v_precio * v_cant;
    END LOOP;
    -- Totales y numero correlativo (COMP-0001, COMP-0002, ...)
    v_impuesto := ROUND(v_subtotal * c_iva, 2);
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(Numero_Compra, 6))), 0) + 1
      INTO v_sig
      FROM COMPRAS_ENCABEZADO;
    p_numero_compra := 'COMP-' || LPAD(v_sig, 4, '0');
    -- Encabezado
    INSERT INTO COMPRAS_ENCABEZADO
           (Numero_Compra, Fecha_Compra, Subtotal, Impuesto, Total_Compra,
            Estado, ID_Proveedor, ID_Empleado)
    VALUES (p_numero_compra, SYSDATE, v_subtotal, v_impuesto, v_subtotal + v_impuesto,
            'RECIBIDA', p_id_proveedor, p_id_empleado)
    RETURNING ID_Compra INTO p_id_compra;
    -- PASADA 2: detalle, incremento de stock y kardex
    FOR i IN 1 .. p_lineas.COUNT LOOP
        v_id_prod := p_lineas(i).ID_Producto;
        v_cant    := p_lineas(i).Cantidad;
        SELECT NVL(p_lineas(i).Precio_Unitario, Precio_Compra) INTO v_precio
          FROM PRODUCTOS WHERE ID_Producto = v_id_prod;
        INSERT INTO COMPRAS_DETALLE
               (ID_Compra, ID_Producto, Cantidad, Precio_Unitario, Subtotal)
        VALUES (p_id_compra, v_id_prod, v_cant, v_precio, v_precio * v_cant);
        UPDATE PRODUCTOS
           SET Stock_Actual = Stock_Actual + v_cant
         WHERE ID_Producto = v_id_prod
        RETURNING Stock_Actual INTO v_saldo;
        INSERT INTO MOVIMIENTOS_INVENTARIO
               (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad,
                Saldo_Resultante, ID_Compra, ID_Factura, Observacion)
        VALUES (v_id_prod, SYSDATE, 'ENTRADA', v_cant,
                v_saldo, p_id_compra, NULL, 'Ingreso por compra ' || p_numero_compra);
    END LOOP;
END SP_REGISTRAR_COMPRA;
/


/* ------------------------------------------------------------------
   VERIFICACION: los 2 procedimientos y los 4 tipos deben ser VALID
   ------------------------------------------------------------------ */
SELECT object_type, object_name, status
  FROM user_objects
 WHERE object_type IN ('PROCEDURE','TYPE')
 ORDER BY object_type, object_name;


/* ##################################################################
   SECCION 4C: VISTAS
   ################################################################## */
/* ==================================================================
   SECCION 4C: VISTAS
   ------------------------------------------------------------------
   Son sentencias SQL simples (sin PL/SQL): se pueden ejecutar con
   Alt+X en DBeaver sin problemas.
   ================================================================== */


/* ------------------------------------------------------------------
   VISTA 1: HISTORIAL CONSOLIDADO DE OPERACIONES
   Una sola vista con dos tipos de fila:
     - COMPRA: cada compra a un proveedor (Tercero = proveedor).
     - VENTA : cada factura emitida a un cliente (Tercero = cliente).
   Acumulado = total acumulado por tercero en orden cronologico.
   Solo suman al acumulado las operaciones efectivas (compras
   RECIBIDA y facturas PAGADO); las PENDIENTE y ANULADA/ANULADO se
   muestran en el historial pero no acumulan.
   ------------------------------------------------------------------ */
CREATE OR REPLACE VIEW VW_HISTORIAL_OPERACIONES AS
SELECT 'COMPRA'                 AS Tipo_Operacion,
       pr.ID_Proveedor          AS ID_Tercero,
       pr.Nombre_Empresa        AS Tercero,
       ce.Numero_Compra         AS Documento,
       ce.Fecha_Compra          AS Fecha,
       ce.Estado                AS Estado,
       ce.Total_Compra          AS Total,
       SUM(CASE WHEN ce.Estado = 'RECIBIDA' THEN ce.Total_Compra ELSE 0 END)
           OVER (PARTITION BY pr.ID_Proveedor
                 ORDER BY ce.Fecha_Compra, ce.ID_Compra) AS Acumulado
  FROM COMPRAS_ENCABEZADO ce
 INNER JOIN PROVEEDORES pr ON pr.ID_Proveedor = ce.ID_Proveedor
UNION ALL
SELECT 'VENTA'                  AS Tipo_Operacion,
       cl.ID_Cliente            AS ID_Tercero,
       cl.Nombre_Completo       AS Tercero,
       fe.Numero_Factura        AS Documento,
       fe.Fecha_Emision         AS Fecha,
       fe.Estado                AS Estado,
       fe.Total_Factura         AS Total,
       SUM(CASE WHEN fe.Estado = 'PAGADO' THEN fe.Total_Factura ELSE 0 END)
           OVER (PARTITION BY cl.ID_Cliente
                 ORDER BY fe.Fecha_Emision, fe.ID_Factura) AS Acumulado
  FROM FACTURAS_ENCABEZADO fe
 INNER JOIN CLIENTES cl ON cl.ID_Cliente = fe.ID_Cliente;


/* ------------------------------------------------------------------
   VISTA 2: CONTROL DE INVENTARIO CRITICO
   Productos con Stock_Actual <= Stock_Minimo, con los datos del
   proveedor para reabastecer. Faltante = unidades que faltan para
   llegar al minimo (0 si esta justo en el minimo).
   ------------------------------------------------------------------ */
CREATE OR REPLACE VIEW VW_INVENTARIO_CRITICO AS
SELECT p.ID_Producto,
       p.Codigo_Barras,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       pr.Nombre_Empresa  AS Proveedor,
       pr.Telefono        AS Telefono_Proveedor,
       p.Stock_Actual,
       p.Stock_Minimo,
       p.Stock_Minimo - p.Stock_Actual AS Faltante,
       CASE WHEN p.Stock_Actual = 0 THEN 'AGOTADO' ELSE 'BAJO MINIMO' END AS Nivel
  FROM PRODUCTOS p
 INNER JOIN CATEGORIAS c  ON c.ID_Categoria  = p.ID_Categoria
 INNER JOIN PROVEEDORES pr ON pr.ID_Proveedor = p.ID_Proveedor
 WHERE p.Stock_Actual <= p.Stock_Minimo;


/* ------------------------------------------------------------------
   VERIFICACION
   Ejecutar cada SELECT por separado: clic dentro y Ctrl+Enter.
   ------------------------------------------------------------------ */
-- V0) Las 2 vistas deben aparecer VALID
SELECT object_name, status FROM user_objects WHERE object_type = 'VIEW' ORDER BY object_name;

-- V1) Compras del proveedor 7 con su acumulado.
-- Esperado: COMP-0007 total 15254.40 acumulado 15254.40; COMP-0013 total 8736.00 acumulado 23990.40
SELECT Documento, Fecha, Estado, Total, Acumulado
  FROM VW_HISTORIAL_OPERACIONES
 WHERE Tipo_Operacion = 'COMPRA' AND ID_Tercero = 7
 ORDER BY Fecha;

-- V2) Operaciones que NO acumulan (pendientes y anuladas): su acumulado no suma el total
SELECT Tipo_Operacion, Tercero, Documento, Estado, Total, Acumulado
  FROM VW_HISTORIAL_OPERACIONES
 WHERE Estado IN ('PENDIENTE', 'ANULADA', 'ANULADO')
 ORDER BY Tipo_Operacion, Documento;

-- V3) Inventario critico. Con la carga inicial (script 03) se esperan 7 productos.
SELECT ID_Producto, Nombre_Producto, Proveedor, Stock_Actual, Stock_Minimo, Faltante, Nivel
  FROM VW_INVENTARIO_CRITICO
 ORDER BY Stock_Actual;


