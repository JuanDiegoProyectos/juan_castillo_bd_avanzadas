xquery version "1.0";

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
