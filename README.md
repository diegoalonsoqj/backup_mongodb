# backup_mongodb
El script realiza respaldos automatizados de bases de datos MongoDB en archivos comprimidos utilizando mongodump, guarda los backups en un directorio específico y mantiene un registro de las operaciones en un archivo de log. También se encarga de eliminar backups antiguos para liberar espacio de almacenamiento.

A continuación, se detallan los pasos que realiza el script:

Se establecen las variables de configuración para el directorio de almacenamiento de backups, el nombre de usuario y contraseña de MongoDB, y el host y puerto del servidor MongoDB.

Se obtiene la fecha y hora actual en el formato "YYYYMMDD_HHMM" y se almacena en la variable "current_datetime".

Se crea el directorio de backups especificado en la variable "backup_dir" si este no existe previamente.

Se crea el directorio para guardar el archivo de log especificado en la variable "log_dir" si este no existe previamente.

Se establece la ubicación y nombre del archivo de log en la variable "log_file".

Se define la función "log_message" que toma un mensaje como argumento y registra el mensaje en el archivo de log junto con la fecha y hora actual en el formato "[YYYY-MM-DD HH:MM:SS] mensaje".

Se registra el inicio del script en el archivo de log mediante la función "log_message".

Se utiliza el comando "mongo" para obtener la lista de bases de datos existentes en el servidor MongoDB. Se excluyen las bases de datos "admin" y "config" del resultado. La lista de bases de datos se almacena en la variable "database_list".

Se verifica si se encontraron bases de datos válidas para respaldar. Si la lista de bases de datos está vacía, se registra un mensaje en el archivo de log indicando que no se encontraron bases de datos válidas y se finaliza el script con un código de salida 1.

Se convierte la lista de bases de datos en un array utilizando el comando "readarray" y se almacena en la variable "databases".

Se itera a través de cada base de datos en el array "databases" y se realiza el respaldo de cada una de ellas.

Para cada base de datos, se establece el nombre del archivo de backup utilizando el nombre de la base de datos, la cadena "-PROD-" y la fecha y hora actual. El archivo de backup resultante se almacenará en el directorio de backups especificado por "backup_dir".

Se registra la hora de inicio del backup en el archivo de log mediante la función "log_message".

Se utiliza el comando "mongodump" para realizar el respaldo de la base de datos especificada. Se proporcionan las credenciales de acceso y se comprime el respaldo con gzip. El respaldo se almacena en el archivo de backup previamente establecido.

Se verifica si el respaldo se completó correctamente. Si el comando "mongodump" devuelve un código de salida 0 (sin errores), se registra la hora de finalización del backup y el nombre del archivo de backup en el archivo de log. También se obtiene el tamaño del backup generado y se registra en el log.

Si el respaldo falla (el comando "mongodump" devuelve un código de salida diferente de 0), se registra un mensaje de error en el archivo de log.

Se repite el proceso de respaldo para todas las bases de datos encontradas en el servidor MongoDB.

Después de respaldar todas las bases de datos, se registra un mensaje en el archivo de log indicando que se buscarán y borrarán archivos de backups con 2 o más días de antigüedad.

Se utiliza el comando "find" para buscar y eliminar archivos con extensión ".gz" (respaldos comprimidos) en el directorio de backups que tengan 2 o más días de antigüedad.

El script finaliza su ejecución, y se registra un mensaje en el archivo de log indicando que el script ha terminado.