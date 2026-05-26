-- ================================================================
-- Archivo: 03_consultas_xpath_xquery.sql
-- Autor: Juan Diego Castillo Montano
-- Asignatura: Bases de Datos Avanzadas
-- Laboratorio #1: Consultas XPath y XQuery sobre XML almacenado
-- ================================================================

SET SERVEROUTPUT ON
SET LONG 1000000
SET LONGCHUNKSIZE 32767
SET PAGESIZE 100
SET LINESIZE 250

PROMPT Consulta XPath 1: nombre de la ladrillera almacenada en el XML.

SELECT XMLCAST(
         XMLQUERY('string(/ladrillera/@nombre)'
                  PASSING documento
                  RETURNING CONTENT) AS VARCHAR2(100)
       ) AS nombre_ladrillera
FROM ladrillera_rh_xml
WHERE id_documento = 1;

PROMPT Consulta XPath 2: nombres de departamentos contenidos en el XML.

SELECT XMLQUERY(
         '/ladrillera/departamento_recursos_humanos/departamento/nombre'
         PASSING documento
         RETURNING CONTENT
       ) AS departamentos
FROM ladrillera_rh_xml
WHERE id_documento = 1;

PROMPT Consulta XQuery: reporte de empleados prioritarios por salario.

SELECT XMLQUERY(q'~xquery version "1.0";

declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare variable $doc external;

(:
  Consulta XQuery para el laboratorio de Bases de Datos Avanzadas.
  Objetivo: obtener un resumen de empleados por departamento y listar
  los empleados con salario igual o superior a 3.800.000 en el escenario
  del Departamento de Recursos Humanos de una ladrillera.
:)

<reporte_recursos_humanos_ladrillera>
{
  for $d in $doc/ladrillera/departamento_recursos_humanos/departamento
  let $empleados := $d/empleados/empleado
  let $total := count($empleados)
  let $promedio := avg(for $e in $empleados return xs:decimal($e/salario))
  order by string($d/nombre)
  return
    <resumen_departamento id="{data($d/@id)}">
      <nombre>{data($d/nombre)}</nombre>
      <ciudad>{data($d/ciudad)}</ciudad>
      <total_empleados>{$total}</total_empleados>
      <salario_promedio>{format-number($promedio, "0.00")}</salario_promedio>
      <empleados_prioritarios>
      {
        for $e in $empleados
        where xs:decimal($e/salario) ge 3800000
        order by xs:decimal($e/salario) descending
        return
          <empleado id="{data($e/@id)}">
            <nombre_completo>{concat(data($e/nombres), " ", data($e/apellidos))}</nombre_completo>
            <cargo>{data($e/cargo)}</cargo>
            <correo>{data($e/correo)}</correo>
            <salario>{data($e/salario)}</salario>
          </empleado>
      }
      </empleados_prioritarios>
    </resumen_departamento>
}
</reporte_recursos_humanos_ladrillera>
~'
       PASSING documento AS "doc"
       RETURNING CONTENT) AS reporte_recursos_humanos
FROM ladrillera_rh_xml
WHERE id_documento = 1;
