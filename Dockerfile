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

# Comando para iniciar SQL Server
CMD /opt/mssql/bin/sqlservr
