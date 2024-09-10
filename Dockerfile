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

# Copia el script de configuración y el script de inicio
COPY ./setup.sql /usr/config/setup.sql
COPY ./entrypoint.sh /usr/config/entrypoint.sh

# Cambiar a usuario root para dar permisos de ejecución
USER root
RUN chmod +x /usr/config/entrypoint.sh

# Volver al usuario mssql
USER mssql

# Usar el script de inicio como punto de entrada
ENTRYPOINT ["/usr/config/entrypoint.sh"]
