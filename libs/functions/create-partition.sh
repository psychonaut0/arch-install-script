#!/bin/bash

# Create a new partition

create_partition() {
  local selected_disk=$1
  local selected_partition_var=$2
  local partition_type_check=$3
  local start_sector=$4

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
      new_partition_type="fat32"
      ;;
    "8300")
      new_partition_type="ext4"
      ;;
    "8200")
      new_partition_type="linux-swap"
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
  local free_space=$(parted -s "$selected_disk" unit GiB print free | grep "Free Space" | tail -n 1 | awk '{print $3}' | sed 's/GiB//g')

  echo -e "${CYAN}Creating new $new_partition_name partition${NC}"
  echo -e "Free space: ${GREEN}$free_space GiB${NC}"

  read -p "Insert the size of the partition with the unit (eg. 100GiB, 100MiB, etc.): " partition_size

   # Check for valid number if not empty
  if [[ "$partition_size" != "" ]]; then
    # Check if the number with unit is valid
    if [[ ! "$partition_size" =~ ^[0-9.]+[a-zA-Z]+$ ]]; then
      clear
      echo -e "${RED}Invalid number${NC}"
      create_partition "$selected_disk" "$selected_partition_var" "$partition_type_check" "$start_sector"
    fi
    # split the number and the unit
    local partition_size_number=$(echo "$partition_size" | sed 's/[a-zA-Z]//g')
    local partition_size_unit=$(echo "$partition_size" | sed 's/[0-9.]//g')
    # If the unit is not GiB or MiB, reask for the partition size
    if [[ "$partition_size_unit" != "GiB" ]] && [[ "$partition_size_unit" != "MiB" ]]; then
      clear
      echo -e "${RED}Invalid unit${NC}"
      create_partition "$selected_disk" "$selected_partition_var" "$partition_type_check" "$start_sector"
    fi
    if [[ "$partition_size_unit" == "GiB" ]]; then
      local partition_size_bytes=$(echo "$partition_size_number * 1024 * 1024 * 1024" | bc)
    elif [[ "$partition_size_unit" == "MiB" ]]; then
      local partition_size_bytes=$(echo "$partition_size_number * 1024 * 1024" | bc)
    fi

    local free_space_bytes=$(echo "$free_space * 1024 * 1024 * 1024" | bc)
    # If the number is greater than the free space, reask for the partition size
    if [[ "$partition_size_unit" == "GiB" ]]; then
      local partition_size_bytes=$(echo "$partition_size_number * 1024 * 1024 * 1024" | bc)
    elif [[ "$partition_size_unit" == "MiB" ]]; then
      local partition_size_bytes=$(echo "$partition_size_number * 1024 * 1024" | bc)
    fi

    local free_space_bytes=$(echo "$free_space * 1024 * 1024 * 1024" | bc | awk '{printf "%.0f", $1}')

    if (( $partition_size_bytes > $free_space_bytes )); then
      clear
      echo -e "${RED}The number is greater than the free space${NC}"
      create_partition "$selected_disk" "$selected_partition_var" "$partition_type_check" "$start_sector"
    fi
  fi

  # If partition size is empty, use all the free space
  if [[ "$partition_size" == "" ]]; then
    partition_size="100%"
  fi

  # If no start sector is passed as parameter, set the start sector to 0
  if [[ "$start_sector" == "" ]]; then
    start_sector="0%"
  fi

  # Split the start sector and the unit
  local start_sector_number=$(echo "$start_sector" | sed 's/[a-zA-Z]//g')
  local start_sector_unit=$(echo "$start_sector" | sed 's/[0-9.]//g')

  # Get the end sector. If the partition size is 100%, set the end sector to 100% else calculate the end sector based on the partition size + the start sector
  local end_sector
  if [[ "$partition_size" == "100%" ]]; then
    end_sector="100%"
  else
    # If the start sector is 0%, set the end sector to the partition size 
    if [[ "$start_sector" == "0%" ]]; then
      end_sector="$partition_size"
    else
      # Check if the same unit is used for the start sector and the partition size
      if [[ "$start_sector_unit" != "$partition_size_unit" ]]; then
        # Convert the start sector to the same unit as the partition size and change the start sector unit
        if [[ "$start_sector_unit" == "GiB" ]]; then
          start_sector_number=$(echo "$start_sector_number * 1024" | bc)
          start_sector_unit="MiB"
        elif [[ "$start_sector_unit" == "MiB" ]]; then
          start_sector_number=$(echo "scale=2;$start_sector_number / 1024" | bc)
          start_sector_unit="GiB"
        fi
      fi
      end_sector=$(echo "$partition_size_number + $start_sector_number" | bc)"$partition_size_unit"
    fi 
  fi 


  # Create the partition 
  echo -e "${CYAN}Creating new $new_partition_name partition...${NC}"
  # Print all variables
  echo -e "Selected disk: ${GREEN}$selected_disk${NC}"
  echo -e "Partition name: ${GREEN}$new_partition_name${NC}"
  echo -e "Partition type: ${GREEN}$new_partition_type${NC}"
  echo -e "Partition size: ${GREEN}$partition_size${NC}"
  echo -e "Start sector: ${GREEN}$start_sector${NC}"
  echo -e "End sector: ${GREEN}$end_sector${NC}"

  # Confirm the creation of the partition
  read -p "Confirm the creation of the partition (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    clear
    echo -e "${RED}Partition creation aborted${NC}"
    create_partition "$selected_disk" "$selected_partition_var" "$partition_type_check" "$start_sector"
  fi  
  
  echo -e "${CYAN}Creating new $new_partition_name partition...${NC}"
  parted -s "$selected_disk" mkpart "$new_partition_name" "$new_partition_type" "$start_sector" "$end_sector" &
  spinner
  sleep .5 &
  spinner

  # Get the new partition number (eg. 1, 2, 3, etc.)
  local new_partition_number=$(parted -s "$selected_disk" unit MB print free | grep "$new_partition_name" | awk '{print $1}')

  # If the partition type is fat32, set the boot flag
  if [[ "$partition_type_check" == "EF00" ]]; then
    echo -e "${CYAN}Setting boot flag...${NC}"
    parted -s "$selected_disk" set "$new_partition_number" esp  on &
    spinner
  fi



  # Get the new created partition (eg. /dev/sda1)
  local new_partition=$(blkid -o device -t PARTLABEL="$new_partition_name" | grep "$selected_disk")

  # Print the new partition
  echo -e "${GREEN}New partition: $new_partition${NC}"

  # Press enter to continue
  read -p "Press enter to continue..."
  clear


  # Set the new partition
  eval "$selected_partition_var=$new_partition"
}