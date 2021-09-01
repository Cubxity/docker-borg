#!/bin/sh

echo "$CRON_INTERVAL /home/borg/backup.sh" >/home/borg/crontab
supercronic -passthrough-logs /home/borg/crontab
