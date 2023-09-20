# Lists all disks on the system
list_disks() {
  local disks
  disks=($(lsblk -dplnx size -o name | grep -Ev "boot|rpmb|loop"))
  
  for ((i=0; i<${#disks[@]}; i++)); do
    echo "$((i+1)). ${disks[i]}"
  done
}

select_disk() {
  local selected_disk_var=$1  # Il nome del parametro in cui verrà salvato il disco selezionato

  echo "Available disks:"
  list_disks

  read -p "Choose the installation disk for Arch Linux: " disk_number

  # Verifica se l'input è un numero valido
  if ! [[ "$disk_number" =~ ^[0-9]+$ ]]; then
    echo "Insert a valid number."
    select_disk "$selected_disk_var"  # Richiama la funzione con lo stesso parametro
    return
  fi

  local disks
  disks=($(lsblk -dplnx size -o name | grep -Ev "boot|rpmb|loop"))

  # Verifica se il numero selezionato è valido
  if ((disk_number < 1 || disk_number > ${#disks[@]})); then
    echo "Invalid number. choose a number from the list"
    select_disk "$selected_disk_var"  # Richiama la funzione con lo stesso parametro
    return
  fi

  local selected_disk="${disks[disk_number-1]}"

  # Assegna il valore alla variabile passata come parametro
  eval "$selected_disk_var=$selected_disk"
}
