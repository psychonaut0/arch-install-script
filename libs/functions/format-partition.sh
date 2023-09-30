#!/bin/bash

format_partition() {
  local selected_partition=$1
  local partition_type=$2

  # Format the partition with the specified type
  echo -e "Formatting partition ${GREEN}$selected_partition${NC} with type ${GREEN}$partition_type${NC}"
  get_free_space "$selected_partition" free_space

  local selected_partition_free_space
  get_free_space "$selected_partition" selected_partition_free_space

  # Get the selected partition size and remove spaces
  local selected_partition_size=$(lsblk -n -o SIZE "$selected_partition" | sed 's/ //g')
  # Remove the unit from the size
  selected_partition_size=$(echo "$selected_partition_size" | sed 's/[a-zA-Z]//g')
  selected_partition_free_space=$(echo "$selected_partition_free_space" | sed 's/[a-zA-Z]//g')




  if [[ "$selected_partition_free_space" != "$selected_partition_size" ]]; then
    read -p "$(echo -e ${YELLOW}The selected partition is not empty. Do you want to format it? [y/N]${NC}) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      return
    fi
  fi
  clear
  echo -e "${GREEN}Free space: $selected_partition_free_space${NC}"
  echo -e "${GREEN}Partition size: $selected_partition_size${NC}"1
  # Ask for confirmation anyway
  read -p "$(echo -e ${YELLOW}Are you sure you want to format the partition? [y/N]${NC}) " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    return
  fi
  echo -e "Formatting partition ${GREEN}$selected_partition${NC} with type ${GREEN}$partition_type${NC}"
  
  case "$partition_type" in
    "fat32")
      mkfs.fat -F32 "$selected_partition" &
      ;;
    "ext4")
      mkfs.ext4 "$selected_partition" &
      ;;
    "linux-swap")
      mkswap "$selected_partition" &
      ;;
    *)
      echo -e "${RED}Invalid partition type${NC}"
      exit 1
      ;;
  esac

  spinner
}