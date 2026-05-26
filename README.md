# juan_castillo_bd_avanzadas

Repositorio del Laboratorio #1 de Bases de Datos Avanzadas: **Almacenamiento y validacion de ficheros XML**.

## Tema aplicado
Departamento de Recursos Humanos de una ladrillera.

## Archivos principales exigidos por el profesor

- `juan_castillo.xml`: archivo XML de la base de datos del caso de Recursos Humanos.
- `juan_castillo.xsd`: esquema XML usado para validar la estructura del documento.
- `juan_castillo.xq`: archivo con consultas XPath/XQuery.

## Scripts SQL incluidos

- `01_consulta_sql_xml.sql`: genera el XML desde el esquema Oracle HR usando SQL/XML.
- `02_registro_validacion_oracle.sql`: registra el XSD en Oracle XML DB e intenta una insercion valida y otra no valida.
- `03_consultas_xpath_xquery.sql`: ejecuta consultas XPath/XQuery sobre el XML almacenado.

## Pasos de ejecucion sugeridos

1. Abrir SQL Developer.
2. Conectarse a una base Oracle que tenga disponible el esquema `HR`.
3. Ejecutar `01_consulta_sql_xml.sql` con F5 para generar `juan_castillo.xml`.
4. Validar `juan_castillo.xml` contra `juan_castillo.xsd` en una herramienta web gratuita de validacion XML/XSD.
5. Ejecutar `02_registro_validacion_oracle.sql` para registrar el esquema XML e insertar un documento valido y uno invalido.
6. Ejecutar `03_consultas_xpath_xquery.sql` para comprobar consultas XPath y XQuery.
7. Tomar capturas del proceso y agregarlas a la memoria explicativa.
8. Subir todos los archivos a GitHub en un repositorio llamado `juan_castillo_bd_avanzadas`.

## Enlace del repositorio

Reemplazar este texto por el enlace final cuando se cree el repositorio en GitHub:

`https://github.com/TU_USUARIO/juan_castillo_bd_avanzadas`
