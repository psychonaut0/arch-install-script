#!/bin/bash

# Create a new partition

create_partition() {
  local selected_disk=$1
  local selected_partition_var=$2
  local partition_type_check=$3

  # Get the disk label
  local disk_label=$(fdisk -l $selected_disk | grep -w "Disklabel type:" | awk '{print $3}')

  # If no disk label create a new one in GPT format
  if [[ "$disk_label" == "" ]]; then
    echo -e "${GREEN}Creating new partition table${NC}"
    parted -s "$selected_disk" mklabel gpt
  fi

  # If the disk label is not GPT, exit
  if [[ "$disk_label" != "gpt" ]]; then
    echo -e "${RED}The disk label is not GPT. Exiting${NC}"
    exit 1
  fi

  

  # Set the new partition
  eval "$selected_partition_var=$new_partition_name"
}