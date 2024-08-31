#!/bin/bash

# Definice proměnných
SOURCE_DIR="/home/pepa/important"
BACKUP_DIR="/mnt/zalohy/pepa"
LOG_FILE="/home/pepa/logs/backups.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
BACKUP_FILE="backup_$(date "+%Y%m%d%H%M%S").tar.gz"

# Funkce pro záznam do logu
log_message() {
    echo "$TIMESTAMP - Pepa - $1" >> "$LOG_FILE"
}

# Kontrola, zda existuje zdrojový adresář
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "backup FAILED! Source directory $SOURCE_DIR does not exist."
    exit 1
fi

# Kontrola, zda existuje zálohovací adresář
if [ ! -d "$BACKUP_DIR" ]; then
    log_message "backup FAILED! Backup directory $BACKUP_DIR does not exist."
    exit 1
fi

# Kontrola volného místa na zálohovacím disku
AVAILABLE_SPACE=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4}')
REQUIRED_SPACE=$(du -s "$SOURCE_DIR" | awk '{print $1}')

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    log_message "backup FAILED! Not enough space on backup directory $BACKUP_DIR."
    exit 1
fi

# Pokus o vytvoření zálohy
if tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$SOURCE_DIR" . ; then
    log_message "backup OK"
else
    log_message "backup FAILED! Could not create backup file."
    exit 1
fi

# Ověření, že soubor byl správně vytvořen
if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    log_message "backup FAILED! Backup file was not found after creation."
    exit 1
fi

exit 0
