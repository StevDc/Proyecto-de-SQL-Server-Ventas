**Proyecto de Gestión de Ventas – SQL Server**

Este proyecto consiste en la creación y gestión de una base de datos de ventas utilizando SQL Server. Incluye procedimientos almacenados, funciones, vistas y triggers para mantener actualizados los totales de ventas y facilitar el análisis de datos exportados.

**Metodología de Trabajo**

- El desarrollo del proyecto se organizó utilizando la metodología ágil Kanban, permitiendo gestionar y visualizar el avance de las tareas de manera estructurada y eficiente.

**Contenidos Principales**

- Creación de base de datos y tablas principales

- Procedimientos almacenados para insertar ventas y detalles

- Funciones para obtener datos calculados

- Vistas para consolidar información de ventas

- Trigger para actualización automática del total de ventas

- Pruebas y exportación de datos a Excel

**Estructura de la Base de Datos**

- Tablas Principales:

- ventas

- detalle_venta

- productos

- empleados

- clientes

- sucursales

- Elementos Implementados:

- Procedures para insertar datos

- Funciones escalares y de tabla

- Vista consolidada: vw_ventas_general

- Trigger para actualizar automáticamente el campo total_venta en la tabla ventas al insertar o actualizar un detalle de venta.

**Flujo de Trabajo**
- Creación de las tablas necesarias.

- Creación de procedimientos almacenados para insertar registros.

- Creación de funciones para cálculos específicos.

- Creación de la vista vw_ventas_general para consolidar información de ventas, productos y empleados.

- Creación del trigger que actualiza automáticamente el total de cada venta.

- Inserción de datos de prueba mediante procedimientos.

- Validación de la vista mediante consultas.

- Exportación de la vista consolidada a Excel para análisis externo.

**Autor**

Bryan De la Cruz

Proyecto de práctica en SQL Server 
