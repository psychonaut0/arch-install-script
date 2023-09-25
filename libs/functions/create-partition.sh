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
    # Check if the disk label is GPT now
    disk_label=$(fdisk -l $selected_disk | grep -w "Disklabel type:" | awk '{print $3}')
  fi

  # If the disk label is not GPT, exit
  if [[ "$disk_label" != "gpt" ]]; then
    echo -e "${RED}The disk label is not GPT. Exiting${NC}"
    exit 1
  fi

  # If the disk label is GPT, create a new partition with the type passed as parameter
  local new_partition_type
  case "$partition_type_check" in
    "EF00")
      new_partition_type="C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
      ;;
    "8300")
      new_partition_type="0FC63DAF-8483-4772-8E79-3D69D8477DE4"
      ;;
    "8200")
      new_partition_type="0657FD6D-A4AB-43C4-84E5-0933C84B4F4F"
      ;;
    *)
      # If no partition type is passed as parameter, return invalid
      echo -e "${RED}Invalid partition type${NC}"
      exit 1
      ;;
  esac

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
      # If no partition type is passed as parameter, return invalid
      echo -e "${RED}Invalid partition type${NC}"
      exit 1
      ;;
  esac


  # Get the free space
  local free_space=$(parted -s "$selected_disk" unit GB print free | grep "Free Space" | awk '{print $3}' | sed 's/GB//g')

  echo -e "${CYAN}Creating new $new_partition_name partition${NC}"
  echo -e "Free space: ${GREEN}$free_space GB${NC}"
  read -p "Insert the size of the partition in GB or leave blank for all the free space: " partition_size

   # Check for valid number if not empty
  if [[ "$partition_size" != "" ]]; then
    if ! [[ "$partition_size" =~ ^[0-9]+$ ]]; then
      clear
      echo -e "${RED}Insert a valid number.${NC}"
      create_partition "$selected_disk" "$selected_partition_var" "$partition_type_check"
      return
    fi
  # Check if partition size is greater than free space if not empty
    if ((partition_size > free_space)); then
      clear
      echo -e "${RED}Partition size is greater than free space. Choose a size less than $free_space GB${NC}"
      create_partition "$selected_disk" "$selected_partition_var" "$partition_type_check"
      return
    fi
  fi

  # If partition size is empty, use all the free space
  if [[ "$partition_size" == "" ]]; then
    partition_size="100%"
  fi

  # Create the partition
  parted -s "$selected_disk" mkpart "$new_partition_name" "$new_partition_type" 0% "$partition_size" &





  # Set the new partition
  eval "$selected_partition_var=$new_partition_name"
}