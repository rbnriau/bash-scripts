#!/bin/bash
# Descripción: Backup comprimido del directorio bytepath en el VPS
# Uso: sudo ./crear_copia_seguridad.sh
# Salida: /var/www/bytepath_chronicles_backup_YYYYMMDD.tar.gz
# Requiere root (sudo) por permisos de archivos del sistema
# Nota: No incluye rotación ni limpieza de backups antiguos.
#       Añade find + -mtime si se acumulan con el tiempo.
set -e

BACKUP_DIR="/var/www"
SOURCE="bytepath"
FILENAME="bytepath_chronicles_backup_$(date +%Y%m%d).tar.gz"

cd "$BACKUP_DIR"
tar -czvf "$FILENAME" "$SOURCE"
echo "Backup creado: $BACKUP_DIR/$FILENAME"
