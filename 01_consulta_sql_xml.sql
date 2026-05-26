-- ================================================================
-- Archivo: 01_consulta_sql_xml.sql
-- Autor: Juan Diego Castillo Montano
-- Asignatura: Bases de Datos Avanzadas
-- Laboratorio #1: Almacenamiento y validacion de ficheros XML
-- Tema aplicado: Departamento de Recursos Humanos de una ladrillera
-- Objetivo: recuperar informacion del esquema HR en formato XML
--           usando SQL/XML: XMLELEMENT, XMLATTRIBUTES, XMLFOREST y XMLAGG.
-- ================================================================

SET LONG 1000000
SET LONGCHUNKSIZE 32767
SET PAGESIZE 0
SET LINESIZE 32767
SET TRIMSPOOL ON
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF

SPOOL juan_castillo.xml

SELECT XMLSERIALIZE(
         DOCUMENT
         XMLELEMENT("ladrillera",
           XMLATTRIBUTES(
             'Ladrillera Superior S.A.S.' AS "nombre",
             TO_CHAR(SYSDATE, 'YYYY-MM-DD') AS "fechaGeneracion"
           ),
           XMLELEMENT("departamento_recursos_humanos",
             XMLAGG(
               XMLELEMENT("departamento",
                 XMLATTRIBUTES(d.department_id AS "id"),
                 XMLFOREST(
                   d.department_name AS "nombre",
                   l.city AS "ciudad",
                   l.street_address AS "direccion"
                 ),
                 XMLELEMENT("empleados",
                   (
                     SELECT XMLAGG(
                              XMLELEMENT("empleado",
                                XMLATTRIBUTES(e.employee_id AS "id"),
                                XMLFOREST(
                                  e.first_name AS "nombres",
                                  e.last_name AS "apellidos",
                                  LOWER(e.email) || '@ladrillerasuperior.com' AS "correo",
                                  e.phone_number AS "telefono",
                                  TO_CHAR(e.hire_date, 'YYYY-MM-DD') AS "fecha_contratacion",
                                  j.job_title AS "cargo",
                                  e.salary AS "salario"
                                )
                              )
                              ORDER BY e.last_name
                            )
                     FROM hr.employees e
                     INNER JOIN hr.jobs j
                       ON j.job_id = e.job_id
                     WHERE e.department_id = d.department_id
                   )
                 )
               )
               ORDER BY d.department_name
             )
           )
         )
         AS CLOB INDENT SIZE = 2
       ) AS documento_xml_ladrillera
FROM hr.departments d
INNER JOIN hr.locations l
  ON l.location_id = d.location_id
WHERE EXISTS (
  SELECT 1
  FROM hr.employees e
  WHERE e.department_id = d.department_id
);

SPOOL OFF

SET HEADING ON
SET FEEDBACK ON
PROMPT Archivo XML generado. Validar el resultado contra juan_castillo.xsd.
