#!/bin/bash

# Iniciar SQL Server en segundo plano
/opt/mssql/bin/sqlservr &

# Espera a que el servidor esté completamente listo
sleep 40s

# Intentar conexión repetidamente hasta que tenga éxito
for i in {1..50}; do
    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" > /dev/null
    if [ $? -eq 0 ]; then
        echo "SQL Server está listo para aceptar conexiones."
        break
    fi
    echo "Esperando a que SQL Server esté listo..."
    sleep 10
done

# Ejecuta los scripts de configuración para habilitar Always On
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -d master -i /usr/config/enable_always_on.sql

# Ejecuta el script para crear el grupo de disponibilidad
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -d master -i /usr/config/create_ag.sql

# Mantén el contenedor corriendo indefinidamente
wait
