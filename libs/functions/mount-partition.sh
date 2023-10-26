#!/bin/bash

function mount_other_partition() {

  local $disk = $1
  
  fdisk -l $disk 
  local $mount_point
  local $partition
  read -p "Insert the mount point: " mount_point
  read -p "Insert the partition: " partition

  # Check if the partition exists
  if [[ ! -e "$partition" ]]; then
    echo -e "${RED}Partition does not exist${NC}"
    exit 1
  fi

  # Mount the partition
  mount --mkdir "$partition" "$mount_point"

  # ask if the user wants to mount another partition
  read -p "$(echo -e ${YELLOW}Do you want to mount another partition? [y/N]${NC}) " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    clear
    mount_other_partition "$selected_partition" "$mount_point" "$file_system"
  fi
}