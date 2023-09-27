#!/bin/bash

get_free_space() {
  local partition=$1
  local free_space=$2
  # Mount the partition to /mnt and check if mount gives wrong fs type error
  mount "$partition" /mnt 2>&1 | grep "wrong fs type, bad option, bad superblock" > /dev/null
  if [[ $? -eq 0 ]]; then
    # If the error is given, partition is not formatted so its free space is the partition size
    local free_space=$(lsblk -n -o SIZE "$partition")
  else
    # If the error is not given, partition is formatted so its free space is the available space
    local free_space=$(df -h | grep "$partition" | awk '{print $4}')
    # Unmount the partition
    umount "$partition"
  fi



  # Assign the free space to the variable passed as parameter
  eval "$free_space='$free_space'"
}