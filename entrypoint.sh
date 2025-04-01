#!/bin/sh

# Create cron job with environment variables
echo "CLEAN_DIR=${CLEAN_DIR}" > /etc/cleanup_env
echo "CLEAN_OLDER_THAN=${CLEAN_OLDER_THAN}" >> /etc/cleanup_env

# Add cron job with proper environment
echo "$CLEAN_SCHEDULE /bin/sh -c '. /etc/cleanup_env; /cleanup.sh >> /var/log/cron.log 2>&1'" > /etc/crontabs/root

# Verify cron configuration
echo "=== Current Cron Configuration ==="
cat /etc/crontabs/root
echo "================================"

# Start cron and tail logs to stdout
crond -L /var/log/cron.log
tail -F /var/log/cron.log