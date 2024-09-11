# Dockerfile

# Define una variable de construcción para la versión
ARG MSSQL_VERSION=2019-CU15-ubuntu-20.04
ARG MSSQL_SA_PASSWORD
ARG MSSQL_PID

FROM mcr.microsoft.com/mssql/server:${MSSQL_VERSION}

# Establece variables de entorno requeridas
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=${MSSQL_SA_PASSWORD}
ENV MSSQL_PID=${MSSQL_PID}

# Copia el script de configuración
COPY ./setup.sql /usr/config/setup.sql

# CMD para iniciar SQL Server y ejecutar el script de configuración
CMD /bin/bash -c "/opt/mssql/bin/sqlservr & sleep 30 && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P \"$SA_PASSWORD\" -i /usr/config/setup.sql && wait"
