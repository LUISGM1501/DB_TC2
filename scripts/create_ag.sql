-- Asegúrate de que la base de datos esté en FULL recovery model
ALTER DATABASE TestDB SET RECOVERY FULL;

-- Backup inicial de la base de datos
BACKUP DATABASE TestDB TO DISK = '/var/opt/mssql/data/TestDB.bak' WITH INIT;

-- Crear el grupo de disponibilidad
CREATE AVAILABILITY GROUP [TestAvailabilityGroup]
WITH (CLUSTER_TYPE = NONE)
FOR DATABASE TestDB
REPLICA ON 
    N'mssql_primary' WITH (
        ENDPOINT_URL = N'TCP://mssql_primary:5022',
        AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
        FAILOVER_MODE = MANUAL,
        SEEDING_MODE = AUTOMATIC,
        SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
    ),
    N'mssql_replica' WITH (
        ENDPOINT_URL = N'TCP://mssql_replica:5022',
        AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
        FAILOVER_MODE = MANUAL,
        SEEDING_MODE = AUTOMATIC,
        SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
    );
