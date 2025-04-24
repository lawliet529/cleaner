#!/bin/bash

set -eo pipefail

echo "$(date) - Starting cleanup job"
echo "Environment: CLEAN_DIR=${CLEAN_DIR}, CLEAN_OLDER_THAN=${CLEAN_OLDER_THAN}, DRY_RUN=${DRY_RUN}"

# Validate environment variables
if [ -z "${CLEAN_DIR}" ] || [ -z "${CLEAN_OLDER_THAN}" ]; then
    echo "ERROR: Missing required environment variables" >&2
    exit 1
fi

# Parse time specification
time_value=$(echo "${CLEAN_OLDER_THAN}" | grep -oE '^[0-9]+')
time_unit=$(echo "${CLEAN_OLDER_THAN}" | grep -oE '[mhd]$' || echo 'd')

case "${time_unit}" in
    m) find_args="-mmin +${time_value}" ;;
    h) find_args="-mmin +$((${time_value} * 60))" ;;
    d) find_args="-mtime +${time_value}" ;;
    *) echo "Invalid time unit: ${time_unit}"; exit 1 ;;
esac

echo "Searching in: ${CLEAN_DIR}"
echo "Deletion criteria: ${find_args}"

# Check if dry run is enabled
if [ -n "${DRY_RUN}" ]; then
    echo "=== DRY RUN RESULTS ==="
    find "${CLEAN_DIR}" -mindepth 1 ${find_args} -exec echo "[DRY RUN] Would delete: {}" \;
    echo "======================"
else
    find "${CLEAN_DIR}" -mindepth 1 ${find_args} -exec rm -rf {} \;
fi

echo "$(date) - Cleanup job completed"
echo "----------------------------------------"
