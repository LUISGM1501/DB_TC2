-- Habilita la replicaciOn en la base de datos AdventureWorks
USE [master];
GO
ALTER DATABASE AdventureWorks SET HADR AVAILABILITY GROUP = [YourAvailabilityGroup];
GO

-- Crea un grupo de disponibilidad
CREATE AVAILABILITY GROUP [YourAvailabilityGroup]
FOR DATABASE AdventureWorks
REPLICA ON 
    N'primary_instance' WITH (
        ENDPOINT_URL = N'TCP://primary:5022',
        AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
        FAILOVER_MODE = AUTOMATIC
    ),
    N'secondary_instance' WITH (
        ENDPOINT_URL = N'TCP://replica:5022',
        AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
        FAILOVER_MODE = AUTOMATIC
    );
GO
