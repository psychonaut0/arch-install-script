#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"



# Import all functions
source "${CURRENT_DIR}/libs/main.sh"

root_checker


select_disk SELECTED_DISK
echo "Selected disk: $SELECTED_DISK"

select_partition $SELECTED_DISK BOOT_PARTITION

# Esempio di come utilizzare la variabile BOOT_PARTITION
echo "Selected boot partition: $BOOT_PARTITION"

