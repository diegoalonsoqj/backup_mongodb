#!/bin/bash

# Directorio de almacenamiento de backups
backup_dir="/backups/mongodb"

# Nombre de usuario y contraseña de MongoDB
db_user="tu_usuario"
db_password="tu_contraseña"

# Host y puerto del servidor MongoDB
db_host="localhost"
db_port="27017"  # Cambiar al puerto correcto si MongoDB usa uno diferente al puerto predeterminado (27017).

# Obtener la fecha y hora actual
current_datetime=$(date +"%Y%m%d_%H%M")

# Crear el directorio de backups si no existe
mkdir -p "$backup_dir"

# Directorio para guardar el archivo de log
log_dir="/var/log/scripts"
mkdir -p "$log_dir"

# Archivo de log
log_file="$log_dir/backup_mongodb.log"

# Función para registrar mensajes en el archivo de log con fecha y hora
function log_message {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$log_file"
}

# Inicio del script
log_message "Inicio del script de backup de bases de datos MongoDB."

# Obtener la lista de bases de datos existentes
database_list=$(mongo --quiet --host "$db_host" --port "$db_port" -u "$db_user" -p "$db_password" --eval "db.getMongo().getDBNames().filter(db => db !== 'admin' && db !== 'config')" | tr -d '[],')

# Verificar si se encontraron bases de datos válidas
if [ -z "$database_list" ]; then
    log_message "No se encontraron bases de datos válidas para respaldar. Saliendo del script."
    exit 1
fi

# Convertir la lista de bases de datos en un array
readarray -t databases <<< "$database_list"

# Iterar a través de cada base de datos y realizar el respaldo
for db_name in "${databases[@]}"
do
    # Nombre del archivo de backup
    backup_file="$backup_dir/${db_name}-PROD-${current_datetime}.gz"

    # Registro de hora de inicio del backup
    log_message "Inicio del backup de la base de datos $db_name."

    # Realizar el respaldo utilizando mongodump y comprimir con gzip
    echo "Ejecutando comando mongodump para respaldar la base de datos $db_name..."
    mongodump --host "$db_host" --port "$db_port" -u "$db_user" -p "$db_password" --authenticationDatabase "admin" --db "$db_name" --archive="$backup_file" --gzip

    # Verificar si el respaldo se completó correctamente
    if [ $? -eq 0 ]; then
        # Registro de hora de finalización del backup
        log_message "Backup de $db_name completado: $backup_file"

        # Obtener el peso del backup generado
        backup_size=$(du -h "$backup_file" | cut -f 1)
        log_message "Peso del backup: $backup_size"
    else
        log_message "ERROR: Fallo al respaldar $db_name"
    fi
done

# Borrar archivos con 2 o más días de antigüedad
log_message "Buscando y borrando archivos de backups con 2 o más días de antigüedad..."
find "$backup_dir" -type f -name "*.gz" -mtime
