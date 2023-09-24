#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"



# Import all functions
source "${CURRENT_DIR}/libs/main.sh"

root_checker
clear

sleep 2 &
spinner 


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


