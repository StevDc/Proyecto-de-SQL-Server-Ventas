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

-- Creación de trigger para actualizar monto total en la tabla VENTA
CREATE TRIGGER tr_actualizar_total_venta
ON DETALLE_VENTA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT 1 FROM INSERTED)
	BEGIN
		UPDATE VENTA
		SET total= (SELECT ISNULL(SUM(subtotal),0) FROM DETALLE_VENTA WHERE id_venta = V.id_venta)
		FROM VENTA V
		INNER JOIN (SELECT DISTINCT id_venta FROM INSERTED)I ON V.id_venta = I.id_venta;
	END;

	IF EXISTS(SELECT 1 FROM DELETED)
	BEGIN
		UPDATE VENTA
		SET total= (SELECT ISNULL(SUM(subtotal),0) FROM DETALLE_VENTA WHERE id_venta = V.id_venta)
		FROM VENTA V
		INNER JOIN (SELECT DISTINCT id_venta FROM DELETED)I ON V.id_venta = I.id_venta;
	END;

END; 
GO

-- INGRESAMOS NUESTRA DATA UTILIZANDO LOS PROCEDURE CREADOS

EXEC pr_insertarcategoria 'Bebidas';
EXEC pr_insertarcategoria 'Snacks';

EXEC pr_insertarproducto 'Coca Cola 500ml', 2.50, 50, 1;
EXEC pr_insertarproducto 'Papas Fritas Lays', 1.80, 30, 2;

EXEC pr_insertarciudad 'Lima';
EXEC pr_insertarciudad 'Arequipa';

EXEC pr_insertarcliente 'Carlos Ramos', 'carlos.ramos@gmail.com', 1, '2025-07-01';
EXEC pr_insertarcliente 'María Pérez', 'maria.perez@gmail.com', 2, '2025-07-05';
EXEC pr_insertarcliente 'Luis Fernández', 'luis.fernandez@gmail.com', 1, '2025-07-08';
EXEC pr_insertarcliente 'Ana Castillo', 'ana.castillo@gmail.com', 2, '2025-07-09';

EXEC pr_insertarsucursal 'Sucursal Lima Centro', 1;
EXEC pr_insertarsucursal 'Sucursal Arequipa', 2;

EXEC pr_insertarcargo 'Vendedor';
EXEC pr_insertarcargo 'Supervisor';

EXEC pr_insertarempleado 'Juan Torres', 1, 1, 1, '999888777';
EXEC pr_insertarempleado 'Lucía Gómez', 2, 2, 2, '998877665';

EXEC pr_insertarmetodo_pago 'Efectivo';
EXEC pr_insertarmetodo_pago 'Tarjeta';

EXEC pr_insertarventa 1, 1, 1, '2025-07-01 10:00:00';
EXEC pr_insertarventa 1, 2, 2, '2025-07-02 11:00:00';
EXEC pr_insertarventa 1, 1, 1, '2025-07-03 12:00:00';
EXEC pr_insertarventa 1, 2, 2, '2025-07-04 13:00:00';
EXEC pr_insertarventa 1, 1, 1, '2025-07-05 14:00:00';
EXEC pr_insertarventa 1, 2, 2, '2025-07-06 15:00:00';
EXEC pr_insertarventa 1, 1, 1, '2025-07-07 16:00:00';
EXEC pr_insertarventa 1, 2, 2, '2025-07-08 17:00:00';
EXEC pr_insertarventa 1, 1, 1, '2025-07-09 18:00:00';
EXEC pr_insertarventa 1, 2, 2, '2025-07-10 19:00:00';
EXEC pr_insertarventa 1, 1, 1, '2025-07-11 20:00:00';
EXEC pr_insertarventa 1, 2, 2, '2025-07-12 21:00:00';
EXEC pr_insertarventa 2, 1, 1, '2025-07-01 10:30:00';
EXEC pr_insertarventa 2, 2, 2, '2025-07-02 11:30:00';
EXEC pr_insertarventa 2, 1, 1, '2025-07-03 12:30:00';
EXEC pr_insertarventa 2, 2, 2, '2025-07-04 13:30:00';
EXEC pr_insertarventa 2, 1, 1, '2025-07-05 14:30:00';
EXEC pr_insertarventa 2, 2, 2, '2025-07-06 15:30:00';
EXEC pr_insertarventa 2, 1, 1, '2025-07-07 16:30:00';
EXEC pr_insertarventa 2, 2, 2, '2025-07-08 17:30:00';
EXEC pr_insertarventa 2, 1, 1, '2025-07-09 18:30:00';
EXEC pr_insertarventa 3, 1, 1, '2025-07-01 09:00:00';
EXEC pr_insertarventa 3, 2, 2, '2025-07-02 10:00:00';
EXEC pr_insertarventa 3, 1, 1, '2025-07-03 11:00:00';
EXEC pr_insertarventa 3, 2, 2, '2025-07-04 12:00:00';
EXEC pr_insertarventa 3, 1, 1, '2025-07-05 13:00:00';
EXEC pr_insertarventa 4, 1, 1, '2025-07-01 08:00:00';
EXEC pr_insertarventa 4, 2, 2, '2025-07-02 09:00:00';
EXEC pr_insertarventa 4, 1, 1, '2025-07-03 10:00:00';

EXEC pr_insertardetalle_venta 1, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 1, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 2, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 2, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 3, 1, 1, 2.50;
EXEC pr_insertardetalle_venta 3, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 3, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 4, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 4, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 5, 1, 4, 2.50;
EXEC pr_insertardetalle_venta 5, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 6, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 6, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 7, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 7, 2, 3, 1.80;
EXEC pr_insertardetalle_venta 8, 1, 5, 2.50;
EXEC pr_insertardetalle_venta 8, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 9, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 9, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 10, 1, 4, 2.50;
EXEC pr_insertardetalle_venta 10, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 11, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 11, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 12, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 12, 2, 3, 1.80;
EXEC pr_insertardetalle_venta 13, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 13, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 14, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 14, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 15, 1, 4, 2.50;
EXEC pr_insertardetalle_venta 15, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 16, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 16, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 17, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 17, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 18, 1, 5, 2.50;
EXEC pr_insertardetalle_venta 18, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 19, 1, 4, 2.50;
EXEC pr_insertardetalle_venta 19, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 20, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 20, 2, 3, 1.80;
EXEC pr_insertardetalle_venta 21, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 21, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 22, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 22, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 23, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 23, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 24, 1, 4, 2.50;
EXEC pr_insertardetalle_venta 24, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 25, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 25, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 26, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 26, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 27, 1, 2, 2.50;
EXEC pr_insertardetalle_venta 27, 2, 1, 1.80;
EXEC pr_insertardetalle_venta 28, 1, 3, 2.50;
EXEC pr_insertardetalle_venta 28, 2, 2, 1.80;
EXEC pr_insertardetalle_venta 29, 1, 4, 2.50;
EXEC pr_insertardetalle_venta 29, 2, 2, 1.80;

-- Verificamos nuestra vista 
SELECT * FROM vw_ventas_general;


	