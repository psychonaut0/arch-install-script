#!/bin/bash

function root_checker() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
  fi
}