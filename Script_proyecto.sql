
-- VERIFICAMOS SI LA BASE DE DATOS EXISTE PARA ELIMINARLA   
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SISTEMA_VENTAS')
BEGIN
    DROP DATABASE SISTEMA_VENTAS
END
GO

-- CREAMOS LA BASE DE DATOS SISTEMA_VENTAS  
CREATE DATABASE SISTEMA_VENTAS;
GO

-- USAMOS LA BASE DE DATOS 'SISTEMA_VENTAS'  
USE SISTEMA_VENTAS
GO

-- CREAMOS LA TABLA CATEGORIA  
CREATE TABLE CATEGORIA (
    id_categoria INT PRIMARY KEY IDENTITY(1,1),
    nombre_categoria VARCHAR(50) UNIQUE NOT NULL
);
GO

-- CREAMOS LA TABLA PRODUCTO  
CREATE TABLE PRODUCTO (
    id_producto INT PRIMARY KEY IDENTITY(1,1),
    nombre_producto VARCHAR(100) UNIQUE NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria)
);
GO

-- CREAMOS LA TABLA CIUDAD  
CREATE TABLE CIUDAD (
    id_ciudad INT PRIMARY KEY IDENTITY(1,1),
    nombre_ciudad VARCHAR(100) UNIQUE NOT NULL
);
GO

-- CREAMOS LA TABLA CLIENTE  
CREATE TABLE CLIENTE (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    id_ciudad INT NOT NULL,
    fecha_registro DATE NOT NULL,
    FOREIGN KEY (id_ciudad) REFERENCES CIUDAD(id_ciudad)
);
GO

-- CREAMOS LA TABLA SUCURSAL  
CREATE TABLE SUCURSAL (
    id_sucursal INT PRIMARY KEY IDENTITY(1,1),
    nombre_sucursal VARCHAR(100) NOT NULL,
    id_ciudad INT NOT NULL,
    FOREIGN KEY (id_ciudad) REFERENCES CIUDAD(id_ciudad)
);
GO

-- CREAMOS LA TABLA CARGO  
CREATE TABLE CARGO (
    id_cargo INT PRIMARY KEY IDENTITY(1,1),
    nombre_cargo VARCHAR(50) UNIQUE NOT NULL
);
GO

-- CREAMOS LA TABLA EMPLEADO  
CREATE TABLE EMPLEADO (
    id_empleado INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    id_cargo INT NOT NULL,
    id_sucursal INT NOT NULL,
    id_ciudad INT NOT NULL,
    telefono VARCHAR(15) UNIQUE NOT NULL,
    FOREIGN KEY (id_cargo) REFERENCES CARGO(id_cargo),
    FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal),
    FOREIGN KEY (id_ciudad) REFERENCES CIUDAD(id_ciudad)
);
GO

-- CREAMOS LA TABLA METODO_PAGO  
CREATE TABLE METODO_PAGO (
    id_metodo INT PRIMARY KEY IDENTITY(1,1),
    nombre_metodo VARCHAR(50) UNIQUE NOT NULL
);
GO

-- CREAMOS LA TABLA VENTA  
CREATE TABLE VENTA (
    id_venta INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    id_metodo INT NOT NULL,
    fecha_venta DATETIME NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado),
    FOREIGN KEY (id_metodo) REFERENCES METODO_PAGO(id_metodo)
);
GO

-- CREAMOS LA TABLA DETALLE_VENTA  
CREATE TABLE DETALLE_VENTA (
    id_detalle INT PRIMARY KEY IDENTITY(1,1),
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad >= 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal AS (cantidad * precio_unitario) PERSISTED,
    FOREIGN KEY (id_venta) REFERENCES VENTA(id_venta),
    FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto)
);
GO


-- CREACIÓN DE PROCEDURES PARA PODER INSERTAR DATOS A NUESTRAS TABLAS
CREATE PROCEDURE pr_insertarcategoria
    @nombre_categoria VARCHAR(50)
AS
BEGIN
    INSERT INTO CATEGORIA (nombre_categoria)
    VALUES (@nombre_categoria);
END;
GO

CREATE PROCEDURE pr_insertarproducto
    @nombre_producto VARCHAR(100),
    @precio DECIMAL(10,2),
    @stock INT,
    @id_categoria INT
AS
BEGIN
    INSERT INTO PRODUCTO (nombre_producto, precio, stock, id_categoria)
    VALUES (@nombre_producto, @precio, @stock, @id_categoria);
END;
GO

CREATE PROCEDURE pr_insertarciudad
    @nombre_ciudad VARCHAR(100)
AS
BEGIN
    INSERT INTO CIUDAD (nombre_ciudad)
    VALUES (@nombre_ciudad);
END;
GO

CREATE PROCEDURE pr_insertarcliente
    @nombre VARCHAR(100),
    @correo VARCHAR(100),
    @id_ciudad INT,
    @fecha_registro DATE
AS
BEGIN
    INSERT INTO CLIENTE (nombre, correo, id_ciudad, fecha_registro)
    VALUES (@nombre, @correo, @id_ciudad, @fecha_registro);
END;
GO

CREATE PROCEDURE pr_insertarsucursal
    @nombre_sucursal VARCHAR(100),
    @id_ciudad INT
AS
BEGIN
    INSERT INTO SUCURSAL (nombre_sucursal, id_ciudad)
    VALUES (@nombre_sucursal, @id_ciudad);
END;
GO

CREATE PROCEDURE pr_insertarcargo
    @nombre_cargo VARCHAR(50)
AS
BEGIN
    INSERT INTO CARGO (nombre_cargo)
    VALUES (@nombre_cargo);
END;
GO

CREATE PROCEDURE pr_insertarempleado
    @nombre VARCHAR(100),
    @id_cargo INT,
    @id_sucursal INT,
    @id_ciudad INT,
    @telefono VARCHAR(15)
AS
BEGIN
    INSERT INTO EMPLEADO (nombre, id_cargo, id_sucursal, id_ciudad, telefono)
    VALUES (@nombre, @id_cargo, @id_sucursal, @id_ciudad, @telefono);
END;
GO

CREATE PROCEDURE pr_insertarmetodo_pago
    @nombre_metodo VARCHAR(50)
AS
BEGIN
    INSERT INTO METODO_PAGO (nombre_metodo)
    VALUES (@nombre_metodo);
END;
GO

CREATE PROCEDURE pr_insertarventa
    @id_cliente INT,
    @id_empleado INT,
    @id_metodo INT,
    @fecha_venta DATETIME
AS
BEGIN
    INSERT INTO VENTA (id_cliente, id_empleado, id_metodo, fecha_venta, total)
    VALUES (@id_cliente, @id_empleado, @id_metodo, @fecha_venta, 0);
END;
GO

CREATE PROCEDURE pr_insertardetalle_venta
    @id_venta INT,
    @id_producto INT,
    @cantidad INT,
    @precio_unitario DECIMAL(10,2)
AS
BEGIN
    INSERT INTO DETALLE_VENTA (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (@id_venta, @id_producto, @cantidad, @precio_unitario);
END;
GO


-- CREACIÓN DE FUNCIONES PARA NUESTRA VISTA
CREATE FUNCTION fn_cliente_frecuente (@id_cliente INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @cantidad INT;
    DECLARE @resultado VARCHAR(20);

    SELECT @cantidad = COUNT(*) FROM VENTA WHERE id_cliente = @id_cliente;

    IF @cantidad >= 5
        SET @resultado = 'FRECUENTE';
    ELSE
        SET @resultado = 'OCASIONAL';

    RETURN @resultado;
END;
GO

CREATE FUNCTION fn_producto_bajo_stock (@id_producto INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @stock INT;
    DECLARE @resultado VARCHAR(20);

    SELECT @stock = stock FROM PRODUCTO WHERE id_producto = @id_producto;

    IF @stock < 10
        SET @resultado = 'BAJO STOCK';
    ELSE
        SET @resultado = 'STOCK OK';

    RETURN @resultado;
END;
GO

CREATE FUNCTION fn_venta_mayor_promedio (@id_venta INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);
    DECLARE @promedio DECIMAL(10,2);
    DECLARE @resultado VARCHAR(20);

    SELECT @total = total FROM VENTA WHERE id_venta = @id_venta;
    SELECT @promedio = AVG(total) FROM VENTA;

    IF @total >= @promedio
        SET @resultado = 'SOBRE PROMEDIO';
    ELSE
        SET @resultado = 'BAJO PROMEDIO';

    RETURN @resultado;
END;
GO


-- CREACION DE VISTA DESNORMALIZANDO Y UTILIZANDO LAS FUNCIONES TABLAS PARA ANÁLISIS

CREATE VIEW vw_ventas_general
AS
SELECT 
    V.id_venta,
    V.fecha_venta,
    C.nombre AS cliente,
    dbo.fn_cliente_frecuente(C.id_cliente) AS tipo_cliente,
    CI.nombre_ciudad AS ciudad_cliente,
    E.nombre AS empleado,
    P.nombre_producto,
    D.cantidad,
    D.precio_unitario,
    D.subtotal,
    V.total,
    dbo.fn_venta_mayor_promedio(V.id_venta) AS clasificacion_venta,
    dbo.fn_producto_bajo_stock(P.id_producto) AS estado_stock
FROM VENTA V
INNER JOIN CLIENTE C ON V.id_cliente = C.id_cliente
INNER JOIN CIUDAD CI ON C.id_ciudad = CI.id_ciudad
INNER JOIN EMPLEADO E ON V.id_empleado = E.id_empleado
INNER JOIN DETALLE_VENTA D ON V.id_venta = D.id_venta
INNER JOIN PRODUCTO P ON D.id_producto = P.id_producto;
GO
