#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"



# Import all functions
source "${CURRENT_DIR}/libs/main.sh"

root_checker
clear

sleep .5 &
spinner 

echo -e "${GREEN}Welcome to the Arch Linux installer${NC}"
echo -e "Current disks: \n "
fdisk -l
read -p "Press enter to continue..."
clear

select_disk SELECTED_DISK
clear
echo -e "${GREEN}Selected disk: $SELECTED_DISK${NC}"

echo -e "Select the boot partition \nAvailable partitions:"
select_partition $SELECTED_DISK BOOT_PARTITION "EF00"
clear
echo -e "${GREEN}Selected boot partition: $BOOT_PARTITION${NC}"

echo -e "Select the root partition \nAvailable partitions:"
select_partition $SELECTED_DISK ROOT_PARTITION "8300"
clear
echo -e "${GREEN}Selected root partition: $ROOT_PARTITION${NC}"

echo -e "Select the swap partition \nAvailable partitions:"
select_partition $SELECTED_DISK SWAP_PARTITION "8200"
echo -e "${GREEN}Selected swap partition: $SWAP_PARTITION${NC}"
clear

echo "Your selected configuration is:"
echo "Boot partition: $BOOT_PARTITION"
echo "Root partition: $ROOT_PARTITION"
echo "Swap partition: $SWAP_PARTITION"


read -p "Do you want to continue? [Y/n] " -n 1 -r

format_partition $BOOT_PARTITION "fat32"
clear
format_partition $ROOT_PARTITION "ext4"
clear
format_partition $SWAP_PARTITION "linux-swap"
clear

echo -e "${GREEN}Mounting partitions${NC}"
mount $ROOT_PARTITION /mnt
mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot
swapon $SWAP_PARTITION
clear



exit 1

