#!/bin/bash

select_partition() {
  local selected_disk=$1
  local selected_partition_var=$2
  local partition_type_check=$3
  local count=0

  # Print headers
  printf "%-3s%-25s%-11s%s\n" "#" "Device" "Size" "Type"

  # Loop through the partitions and print information
  for device in $(fdisk -l $selected_disk | sed -n '/^[/]/p' | awk '{print $1}'); do
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
    clear
    echo -e "${RED}Insert a valid number.${NC}"
    select_partition "$selected_disk" "$selected_partition_var"
    return
  fi

  # check if the number is in range
  if ((partition_number < 1 || partition_number > ${#dev[@]})); then
    clear
    echo -e "${RED}Invalid number. choose a number from the list${NC}"
    select_partition "$selected_disk" "$selected_partition_var" 
    return
  fi

  # check if the number is the last one
  if ((partition_number == ${#dev[@]})); then
    clear
    echo -e "${GREEN}Creating new partition${NC}"
    sleep .5 &
    spinner
    echo -e "\n"
    create_partition "$selected_disk" "$selected_partition_var" "$partition_type_check"
    return
  fi

  # Check if selected partition match the type code using gdisk
  if [[ "$partition_type_check" != "" ]]; then
    local selected_partition_type=$(gdisk -l "$selected_disk" | awk -v partition_number="$partition_number" '$1 == partition_number {print $6}' | grep -o '[[:alnum:]]\+')
    echo "Selected partition type: $selected_partition_type"
    if [[ "$selected_partition_type" != "$partition_type_check" ]]; then
      clear
      echo -e "${RED}Invalid partition type. Choose a partition with type $partition_type_check ${NC}"
      select_partition "$selected_disk" "$selected_partition_var" "$partition_type_check"
      return
    fi
  fi

  # If partition is non empty, ask for confirmation
  local selected_partition_size=$(lsblk -n -o SIZE "${dev[partition_number]}")
  if [[ "$selected_partition_size" != "0B" ]]; then
    read -p "$(echo -e ${YELLOW}The selected partition is not empty. Are you sure you want to use it? [y/N]${NC}) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      select_partition "$selected_disk" "$selected_partition_var" "$partition_type_check"
      return
    fi
  fi

  local selected_partition="${dev[partition_number]}"
  eval "$selected_partition_var=$selected_partition"
}