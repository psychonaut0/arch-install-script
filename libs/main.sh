#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${CURRENT_DIR}/const.sh"
source "${CURRENT_DIR}/functions/spinner.sh"
source "${CURRENT_DIR}/functions/progress.sh"
source "${CURRENT_DIR}/functions/create-partition.sh"
source "${CURRENT_DIR}/functions/select-disk.sh"
source "${CURRENT_DIR}/functions/select-partition.sh"
source "${CURRENT_DIR}/functions/root-checker.sh"