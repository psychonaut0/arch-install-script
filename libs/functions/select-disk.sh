#!/bin/bash

# Lists all disks on the system
list_disks() {
  local disks
  disks=($(lsblk -dplnx size -o name | grep -Ev "boot|rpmb|loop"))
  
  for ((i=0; i<${#disks[@]}; i++)); do
    echo "$((i+1)). ${disks[i]}"
  done
}

select_disk() {
  local selected_disk_var=$1 
  echo "Available disks:"
  list_disks

  read -p "Choose the installation disk for Arch Linux: " disk_number

  # check for valid number
  if ! [[ "$disk_number" =~ ^[0-9]+$ ]]; then
    clear
    echo -e "${RED}Insert a valid number.${NC}"
    select_disk "$selected_disk_var"
    return
  fi

  local disks
  disks=($(lsblk -dplnx size -o name | grep -Ev "boot|rpmb|loop"))

  # check if the number is in range
  if ((disk_number < 1 || disk_number > ${#disks[@]})); then
    clear
    echo -e "${RED}Invalid number. choose a number from the list${NC}"
    select_disk "$selected_disk_var"  # Richiama la funzione con lo stesso parametro
    return
  fi

  local selected_disk="${disks[disk_number-1]}"

  # Assign the selected disk to the variable passed as parameter
  eval "$selected_disk_var=$selected_disk"
}
