#!/bin/bash

select_partition() {
  local selected_disk=$1
  local selected_partition_var=$2
  local count=0

  # Print headers
  printf "%-3s%-25s%-11s%s\n" "#" "Device" "Size" "Type"

  # Loop through the partitions and print information
  for device in $(fdisk -l | sed -n '/^[/]/p' | awk '{print $1}'); do
    count=$((count+1))
    dev[$count]=$device

    # Get the partition type and size
    local type=$(fdisk -l | grep -w "$device" | awk '{$2="";$1="";$3="";$4="";$5=""; print $0;}')
    local size=$(lsblk -n -o SIZE "$device")

    printf '%-2s%-24s%-8s%s\n' "$(($count)). " "$device" "$size" "$type"
  done
  # New partition option
  count=$((count+1))
  dev[$count]="New partition"

  printf '%-2s%-24s%-8s%s\n' "$(($count)). " "Create new partition" "" ""
  

  read -p "Choose the partition for the installation: " partition_number

  # check for valid number
  if ! [[ "$partition_number" =~ ^[0-9]+$ ]]; then
    echo "Insert a valid number."
    select_partition "$selected_disk" "$selected_partition_var"
    return
  fi

  # check if the number is in range
  if ((partition_number < 1 || partition_number > ${#dev[@]})); then
    echo "Invalid number. choose a number from the list"
    select_partition "$selected_disk" "$selected_partition_var"  # Richiama la funzione con lo stesso parametro
    return
  fi

  local selected_partition="${dev[partition_number]}"
  eval "$selected_partition_var=$selected_partition"
}