-- Nueva base de datos para pruebas de replicacion
CREATE DATABASE TestDB;
GO

-- Base de datos recien creada
USE TestDB;
GO

-- Tabla de ejemplo para replicar
CREATE TABLE TestTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50)
);
GO

-- Datos de ejemplo
INSERT INTO TestTable (ID, Name) VALUES (1, 'Dato1'), (2, 'Dato2');
GO

-- Configuracion de la replica
USE [master];
GO

ALTER DATABASE TestDB SET HADR AVAILABILITY GROUP = [YourAvailabilityGroup];
GO

CREATE AVAILABILITY GROUP [YourAvailabilityGroup]
FOR DATABASE TestDB
REPLICA ON 
    N'mssql_primary' WITH (
        ENDPOINT_URL = N'TCP://mssql_primary:5022',
        AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
        FAILOVER_MODE = AUTOMATIC
    ),
    N'mssql_replica' WITH (
        ENDPOINT_URL = N'TCP://mssql_replica:5022',
        AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
        FAILOVER_MODE = AUTOMATIC
    );
GO
