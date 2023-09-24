#!/bin/bash

# Create a new partition

create_partition() {
  local selected_disk=$1
  local selected_partition_var=$2
  local partition_type_check=$3

  # Get the disk label
  local disk_label=$(fdisk -l $selected_disk | grep -w "Disklabel type:" | awk '{print $3}')

  # If no disk label create a new one in GPT format and wait for job to finish
  if [[ "$disk_label" == "" ]]; then
    echo -e "No disk label found."
    echo -e "${GREEN}Creating new GPT disk label${NC}"
    parted -s "$selected_disk" mklabel gpt &
    spinner
    # Assign new disk label
    
  fi

  # If the disk label is not GPT, exit
  if [[ "$disk_label" != "gpt" ]]; then
    echo -e "${RED}The disk label is not GPT. Exiting${NC}"
    exit 1
  fi

  # If the disk label is GPT, create a new partition with the type passed as parameter
  local new_partition_name
  case "$partition_type_check" in
    "EF00")
      new_partition_name="EFI"
      ;;
    "8300")
      new_partition_name="ROOT"
      ;;
    "8200")
      new_partition_name="SWAP"
      ;;
    *)
      echo -e "${RED}Invalid partition type. Exiting${NC}"
      exit 1
      ;;
  esac


  # Set the new partition
  eval "$selected_partition_var=$new_partition_name"
}