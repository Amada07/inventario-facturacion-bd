/* ==================================================================
   UNIVERSIDAD MARIANO GALVEZ DE GUATEMALA - BASE DE DATOS I
   PROYECTO FINAL: SISTEMA DE INVENTARIO Y FACTURACION (FERRETERIA)
   SGBD: Oracle Database 21c XE | Esquema: FERRETERIADB
   ------------------------------------------------------------------
   01_ddl_crear_base_datos.sql
   En Oracle la "base de datos" de trabajo es el esquema FERRETERIADB,
   que ya debe existir. Ejecutar este script conectado como
   FERRETERIADB: deja el esquema limpio (borra vistas, procedimientos,
   tablas y tipos de este proyecto) para poder repetir toda la
   instalacion desde cero las veces que se quiera.
   ================================================================== */

BEGIN
   -- Vistas, procedimientos y funciones (DROP VIEW / DROP PROCEDURE)
   FOR o IN (SELECT object_name, object_type
               FROM user_objects
              WHERE object_type IN ('VIEW','PROCEDURE','FUNCTION')) LOOP
      EXECUTE IMMEDIATE 'DROP ' || o.object_type || ' ' || o.object_name;
   END LOOP;
   -- Tablas (DROP TABLE ... CASCADE CONSTRAINTS: el orden no importa)
   FOR t IN (SELECT table_name
               FROM user_tables
              WHERE table_name IN
                    ('MOVIMIENTOS_INVENTARIO','FACTURAS_DETALLE',
                     'FACTURAS_ENCABEZADO','METODOS_PAGO',
                     'COMPRAS_DETALLE','COMPRAS_ENCABEZADO',
                     'PRODUCTOS','USUARIOS','EMPLEADOS','CLIENTES',
                     'PROVEEDORES','UNIDADES_MEDIDA','MARCAS',
                     'CATEGORIAS')) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name
                        || ' CASCADE CONSTRAINTS PURGE';
   END LOOP;
   -- Tipos de coleccion usados por los procedimientos (DROP TYPE)
   FOR ty IN (SELECT type_name FROM user_types) LOOP
      EXECUTE IMMEDIATE 'DROP TYPE ' || ty.type_name || ' FORCE';
   END LOOP;
END;
/
