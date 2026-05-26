-- ================================================================
-- Archivo: 02_registro_validacion_oracle.sql
-- Autor: Juan Diego Castillo Montano
-- Asignatura: Bases de Datos Avanzadas
-- Laboratorio #1: Registro del esquema XML e inserciones validas/no validas
-- Tema aplicado: Departamento de Recursos Humanos de una ladrillera
-- ================================================================

SET SERVEROUTPUT ON
SET DEFINE OFF

PROMPT 1. Eliminacion de objetos anteriores, si existen.

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ladrillera_rh_xml PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

BEGIN
  DBMS_XMLSCHEMA.DELETESCHEMA(
    schemaurl     => 'http://www.ladrillerasuperior.com/xml/juan_castillo.xsd',
    delete_option => DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE
  );
  DBMS_OUTPUT.PUT_LINE('Esquema XML anterior eliminado.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('No existia un esquema XML previo o no fue necesario eliminarlo: ' || SQLERRM);
END;
/

PROMPT 2. Registro del esquema XML en Oracle XML DB.

BEGIN
  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    schemaurl => 'http://www.ladrillerasuperior.com/xml/juan_castillo.xsd',
    schemadoc => q'~<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
           elementFormDefault="qualified"
           attributeFormDefault="unqualified">

  <xs:element name="ladrillera">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="departamento_recursos_humanos" type="DepartamentoRecursosHumanosType"/>
      </xs:sequence>
      <xs:attribute name="nombre" type="xs:string" use="required"/>
      <xs:attribute name="fechaGeneracion" type="xs:date" use="required"/>
    </xs:complexType>
  </xs:element>

  <xs:complexType name="DepartamentoRecursosHumanosType">
    <xs:sequence>
      <xs:element name="departamento" type="DepartamentoType" minOccurs="1" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="DepartamentoType">
    <xs:sequence>
      <xs:element name="nombre" type="TextoNoVacioType"/>
      <xs:element name="ciudad" type="TextoNoVacioType"/>
      <xs:element name="direccion" type="TextoNoVacioType" minOccurs="0"/>
      <xs:element name="empleados" type="EmpleadosType"/>
    </xs:sequence>
    <xs:attribute name="id" type="xs:positiveInteger" use="required"/>
  </xs:complexType>

  <xs:complexType name="EmpleadosType">
    <xs:sequence>
      <xs:element name="empleado" type="EmpleadoType" minOccurs="1" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="EmpleadoType">
    <xs:sequence>
      <xs:element name="nombres" type="TextoNoVacioType"/>
      <xs:element name="apellidos" type="TextoNoVacioType"/>
      <xs:element name="correo" type="CorreoType"/>
      <xs:element name="telefono" type="TextoNoVacioType" minOccurs="0"/>
      <xs:element name="fecha_contratacion" type="xs:date"/>
      <xs:element name="cargo" type="TextoNoVacioType"/>
      <xs:element name="salario" type="SalarioType"/>
    </xs:sequence>
    <xs:attribute name="id" type="xs:positiveInteger" use="required"/>
  </xs:complexType>

  <xs:simpleType name="TextoNoVacioType">
    <xs:restriction base="xs:string">
      <xs:minLength value="1"/>
      <xs:whiteSpace value="collapse"/>
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="CorreoType">
    <xs:restriction base="xs:string">
      <xs:pattern value="[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}"/>
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="SalarioType">
    <xs:restriction base="xs:decimal">
      <xs:minInclusive value="0"/>
      <xs:fractionDigits value="2"/>
    </xs:restriction>
  </xs:simpleType>

</xs:schema>
~',
    local     => TRUE,
    gentypes  => FALSE,
    gentables => FALSE,
    force     => TRUE
  );
  DBMS_OUTPUT.PUT_LINE('Esquema XML registrado correctamente.');
END;
/

PROMPT 3. Creacion de tabla para almacenar documentos XML.

CREATE TABLE ladrillera_rh_xml (
  id_documento  NUMBER PRIMARY KEY,
  descripcion   VARCHAR2(120) NOT NULL,
  fecha_registro DATE DEFAULT SYSDATE NOT NULL,
  documento     XMLTYPE NOT NULL
);

PROMPT 4. Insercion valida: el XML cumple la estructura definida en juan_castillo.xsd.

DECLARE
  v_doc XMLTYPE;
BEGIN
  v_doc := XMLTYPE(q'~<?xml version="1.0" encoding="UTF-8"?>
<ladrillera nombre="Ladrillera Superior S.A.S." fechaGeneracion="2026-05-25">
  <departamento_recursos_humanos>
    <departamento id="10">
      <nombre>Administracion y Recursos Humanos</nombre>
      <ciudad>Soacha</ciudad>
      <direccion>Planta principal de produccion</direccion>
      <empleados>
        <empleado id="100">
          <nombres>Juan Diego</nombres>
          <apellidos>Castillo Montano</apellidos>
          <correo>juan.castillo@ladrillerasuperior.com</correo>
          <telefono>3125556537</telefono>
          <fecha_contratacion>2024-04-20</fecha_contratacion>
          <cargo>Analista de informacion de recursos humanos</cargo>
          <salario>4200000.00</salario>
        </empleado>
        <empleado id="101">
          <nombres>Andres</nombres>
          <apellidos>Mora</apellidos>
          <correo>andres.mora@ladrillerasuperior.com</correo>
          <telefono>3001112233</telefono>
          <fecha_contratacion>2023-08-14</fecha_contratacion>
          <cargo>Coordinador de nomina y asistencia</cargo>
          <salario>3900000.00</salario>
        </empleado>
      </empleados>
    </departamento>
    <departamento id="20">
      <nombre>Produccion y Hornos</nombre>
      <ciudad>Soacha</ciudad>
      <direccion>Zona de hornos y secado</direccion>
      <empleados>
        <empleado id="200">
          <nombres>Carlos</nombres>
          <apellidos>Ramirez</apellidos>
          <correo>carlos.ramirez@ladrillerasuperior.com</correo>
          <telefono>3017778899</telefono>
          <fecha_contratacion>2022-03-01</fecha_contratacion>
          <cargo>Jefe de turno de horno</cargo>
          <salario>3500000.00</salario>
        </empleado>
      </empleados>
    </departamento>
  </departamento_recursos_humanos>
</ladrillera>
~');
  v_doc := v_doc.createSchemaBasedXML('http://www.ladrillerasuperior.com/xml/juan_castillo.xsd');
  v_doc.schemaValidate();

  INSERT INTO ladrillera_rh_xml (id_documento, descripcion, documento)
  VALUES (1, 'Documento XML valido del departamento de recursos humanos', v_doc);

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Insercion valida realizada correctamente.');
END;
/

PROMPT 5. Insercion no valida: se fuerza error por fecha, id y salario incorrectos.

DECLARE
  v_doc XMLTYPE;
BEGIN
  v_doc := XMLTYPE(q'~
<ladrillera nombre="Ladrillera Superior S.A.S." fechaGeneracion="fecha-invalida">
  <departamento_recursos_humanos>
    <departamento id="ABC">
      <nombre>Recursos Humanos</nombre>
      <ciudad>Soacha</ciudad>
      <empleados>
        <empleado id="XYZ">
          <nombres>Empleado</nombres>
          <apellidos>No Valido</apellidos>
          <correo>correo_invalido</correo>
          <fecha_contratacion>no-es-fecha</fecha_contratacion>
          <cargo>Auxiliar</cargo>
          <salario>salario_no_numerico</salario>
        </empleado>
      </empleados>
    </departamento>
  </departamento_recursos_humanos>
</ladrillera>
~');

  v_doc := v_doc.createSchemaBasedXML('http://www.ladrillerasuperior.com/xml/juan_castillo.xsd');
  v_doc.schemaValidate();

  INSERT INTO ladrillera_rh_xml (id_documento, descripcion, documento)
  VALUES (2, 'Documento XML no valido', v_doc);

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ERROR: esta insercion no debia aceptarse.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Insercion no valida rechazada correctamente por el esquema XML.');
    DBMS_OUTPUT.PUT_LINE('Detalle tecnico: ' || SQLERRM);
END;
/

PROMPT 6. Verificacion de documentos insertados.

SELECT id_documento,
       descripcion,
       XMLCAST(
         XMLQUERY('string(/ladrillera/@nombre)'
                  PASSING documento
                  RETURNING CONTENT) AS VARCHAR2(100)
       ) AS nombre_ladrillera
FROM ladrillera_rh_xml;
