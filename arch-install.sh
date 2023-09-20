#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Import all functions
source "${CURRENT_DIR}/libs/main.sh"


select_disk SELECTED_DISK
echo "Selected disk: $SELECTED_DISK"

# Funzione per elencare le partizioni di un disco
list_partitions() {
  local selected_disk=$1
  
  echo "Elenco delle partizioni su $selected_disk:"
  lsblk -dplnx name -o name,mountpoint | grep "^$selected_disk" | grep -v "$selected_disk$"
}

# Funzione per selezionare o creare una partizione di boot
select_boot_partition() {
  local selected_disk=$1
  local boot_partition_var=$2  # Il nome del parametro in cui verrà salvata la partizione di boot

  echo "Partizione di boot attuale (se presente):"
  list_partitions "$selected_disk" | grep "/boot"

  echo "Elenco delle partizioni disponibili su $selected_disk:"
  list_partitions "$selected_disk"

  read -p "Seleziona una partizione esistente per il boot o inserisci il numero per crearne una nuova: " boot_partition_choice

  # Verifica se l'input è valido
  if [[ -z "$boot_partition_choice" ]]; then
    echo "Devi inserire un numero o il nome di una partizione valida."
    select_boot_partition "$selected_disk" "$boot_partition_var"
    return
  fi

  # Verifica se l'input è un numero
  if [[ "$boot_partition_choice" =~ ^[0-9]+$ ]]; then
    local partitions
    partitions=($(list_partitions "$selected_disk" | awk '{print $1}'))

    # Verifica se il numero selezionato è valido
    if ((boot_partition_choice >= 1 && boot_partition_choice <= ${#partitions[@]})); then
      local selected_partition="${partitions[boot_partition_choice-1]}"
      echo "Hai selezionato la partizione di boot: /dev/$selected_partition"
      eval "$boot_partition_var=/dev/$selected_partition"
      return
    fi
  fi

  # Se non è un numero valido, crea una nuova partizione
  local next_partition_number=1
  while true; do
    if [[ ! -e "/dev/${selected_disk}${next_partition_number}" ]]; then
      local new_partition="/dev/${selected_disk}${next_partition_number}"
      echo "Creazione di una nuova partizione di boot: $new_partition"
      eval "$boot_partition_var=$new_partition"
      break
    fi
    ((next_partition_number++))
  done
}

# Esegui la funzione di selezione della partizione di boot con il parametro
select_boot_partition "$SELECTED_DISK" BOOT_PARTITION

# Esempio di come utilizzare la variabile BOOT_PARTITION
echo "La partizione di boot selezionata è: $BOOT_PARTITION"