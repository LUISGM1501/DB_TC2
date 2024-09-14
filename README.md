
# Configuración de Log Shipping con SQL Server en Docker

Este documento proporciona una guía paso a paso para configurar y probar Log Shipping con SQL Server utilizando Docker. La configuración incluye la creación de contenedores Docker para la base de datos primaria y la réplica, la configuración de Log Shipping y la verificación de la replicación de datos.

## Requisitos Previos

- Docker instalado en el sistema.
- Conocimientos básicos de comandos SQL y administración de bases de datos SQL Server.
- Herramientas como Visual Studio Code y DataGrip para la gestión y verificación de datos.

## Paso 1: Configuración de Docker

### 1.1 Crear el archivo `docker-compose.yml`

```yaml
version: '3.8'

services:
  mssql_primary:
    image: mcr.microsoft.com/mssql/server:2019-latest
    container_name: mssql_primary
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=YourStrong!Password
    ports:
      - "1435:1433"
    volumes:
      - mssql_primary_data:/var/opt/mssql

  mssql_replica:
    image: mcr.microsoft.com/mssql/server:2019-latest
    container_name: mssql_replica
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=YourStrong!Password
    ports:
      - "1436:1433"
    volumes:
      - mssql_replica_data:/var/opt/mssql

volumes:
  mssql_primary_data:
  mssql_replica_data:
```

### 1.2 Levantar los contenedores

Ejecuta el siguiente comando para iniciar los contenedores:

```bash
docker-compose up -d
```

## Paso 2: Configuración de la Base de Datos Primaria

### 2.1 Conectar a la Base de Datos Primaria (`mssql_primary`)

Ejecuta los siguientes comandos en la consola de SQL Server de la instancia primaria:

```sql
USE master;

-- Crear la base de datos primaria
CREATE DATABASE DB_TC2_PrimaryDB;

-- Cambiar el modelo de recuperación a FULL
ALTER DATABASE DB_TC2_PrimaryDB SET RECOVERY FULL;

-- Realizar un backup completo
BACKUP DATABASE DB_TC2_PrimaryDB
TO DISK = '/var/opt/mssql/data/DB_TC2_PrimaryDB.bak'
WITH INIT;

-- Configurar Log Shipping en la base de datos primaria
EXEC sp_add_log_shipping_primary_database
    @database = N'DB_TC2_PrimaryDB',
    @backup_directory = N'/var/opt/mssql/data',
    @backup_share = N'/var/opt/mssql/data',
    @backup_retention_period = 1440,
    @backup_threshold = 60,
    @history_retention_period = 1440,
    @monitor_server = N'mssql_primary';
```

## Paso 3: Copiar el Archivo de Backup a la Réplica

Después de realizar el backup en la instancia primaria, copia el archivo de backup al contenedor de la réplica.

### 3.1 Copiar el Backup desde la Primaria al Host y luego a la Réplica

Ejecuta los siguientes comandos desde tu terminal de host:

```bash
# Copiar el backup desde el contenedor primaria al host
docker cp mssql_primary:/var/opt/mssql/data/DB_TC2_PrimaryDB.bak .

# Copiar el backup desde el host al contenedor réplica
docker cp DB_TC2_PrimaryDB.bak mssql_replica:/var/opt/mssql/data/
```

## Paso 4: Configuración de la Base de Datos Réplica

### 4.1 Conectar a la Base de Datos Réplica (`mssql_replica`)

Ejecuta los siguientes comandos en la consola de SQL Server de la instancia réplica:

```sql
USE master;

-- Restaurar la base de datos en la réplica con NORECOVERY
RESTORE DATABASE DB_TC2_PrimaryDB
FROM DISK = '/var/opt/mssql/data/DB_TC2_PrimaryDB.bak'
WITH NORECOVERY;

-- Configurar la réplica para Log Shipping
EXEC sp_add_log_shipping_secondary_primary
    @primary_server = N'mssql_primary',
    @primary_database = N'DB_TC2_PrimaryDB',
    @backup_source_directory = N'/var/opt/mssql/data',
    @backup_destination_directory = N'/var/opt/mssql/data',
    @copy_job_name = N'LSCopy_DB_TC2_PrimaryDB',
    @file_retention_period = 1440;

-- Registrar la base de datos secundaria
EXEC sp_add_log_shipping_secondary_database
    @primary_server = N'mssql_primary',
    @primary_database = N'DB_TC2_PrimaryDB',
    @secondary_database = N'DB_TC2_PrimaryDB',
    @restore_mode = 1;  -- 1 para STANDBY o NORECOVERY
```

## Paso 5: Verificación y Pruebas

### 5.1 Insertar y Verificar Datos

Inserta datos de prueba en la primaria y verifica que se replican correctamente:

```sql
USE DB_TC2_PrimaryDB;

-- Crear una tabla de prueba y agregar datos
CREATE TABLE TestTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50)
);

INSERT INTO TestTable (ID, Name) VALUES (1, 'Prueba Log Shipping');

-- Forzar un backup de log
BACKUP LOG DB_TC2_PrimaryDB
TO DISK = '/var/opt/mssql/data/DB_TC2_PrimaryDB_Manual.trn'
WITH INIT;
```

### 5.2 Copiar y Restaurar el Log en la Réplica

Copia el archivo de log desde la primaria a la réplica:

```bash
# Copiar el log backup desde el contenedor primaria al host
docker cp mssql_primary:/var/opt/mssql/data/DB_TC2_PrimaryDB_Manual.trn .

# Copiar el log backup desde el host al contenedor réplica
docker cp DB_TC2_PrimaryDB_Manual.trn mssql_replica:/var/opt/mssql/data/
```

Ejecuta estos pasos en la réplica para restaurar los datos:

```sql
USE master;

-- Restaurar el log manualmente en la réplica
RESTORE LOG DB_TC2_PrimaryDB
FROM DISK = '/var/opt/mssql/data/DB_TC2_PrimaryDB_Manual.trn'
WITH NORECOVERY;

-- Completar la restauración para la verificación de los datos
RESTORE DATABASE DB_TC2_PrimaryDB WITH RECOVERY;

-- Verificar los datos replicados
USE DB_TC2_PrimaryDB;
SELECT * FROM TestTable;
```

## Conclusión

Este archivo README proporciona una guía paso a paso para configurar y probar Log Shipping en SQL Server utilizando Docker. Asegúrate de ajustar las rutas de backup y otros parámetros según tu entorno específico.
