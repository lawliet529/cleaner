#!/bin/sh

if [ -n "${LOG_FILE}" ]; then
    exec >> "${LOG_FILE}" 2>&1 || exit 1
else
    exec 2>&1
fi

# Create cron job with environment variables
echo "CLEAN_DIR=${CLEAN_DIR}" > /etc/cleanup_env
echo "CLEAN_OLDER_THAN=${CLEAN_OLDER_THAN}" >> /etc/cleanup_env

# Add cron job with proper environment
echo "$CLEAN_SCHEDULE /bin/sh -c '. /etc/cleanup_env; /cleanup.sh >> /proc/$$/fd/1 2>&1'" > /etc/crontabs/root

# Verify cron configuration
echo "=== Current Cron Configuration ==="
cat /etc/crontabs/root
echo "================================"

# Keep cron in the foreground and use the selected log destination
exec crond -f -L /dev/stdout