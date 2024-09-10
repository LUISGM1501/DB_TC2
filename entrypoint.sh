# entrypoint.sh
/opt/mssql/bin/sqlservr &

echo "Esperando a que el MSSQL Server esté listo..."
sleep 60  # Ajusta a 60 segundos si es necesario

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -i /usr/config/setup.sql

wait
