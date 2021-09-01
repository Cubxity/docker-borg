#!/bin/sh

echo "[borg] creating backup"

# shellcheck disable=SC2086
borg create \
  --verbose \
  --filter AME \
  --list \
  --stats \
  --show-rc \
  --compression "$BORG_COMPRESSION" \
  --exclude-caches \
  "::$BORG_ARCHIVE_PREFIX$BORG_ARCHIVE_NAME" \
  $BORG_FILES
backup_exit=$?

echo "[borg] pruning repository"

# shellcheck disable=SC2086
borg prune \
  --list \
  --prefix "$BORG_ARCHIVE_PREFIX" \
  --show-rc \
  $BORG_PRUNE_ARGUMENTS
prune_exit=$?

# use highest exit code as global exit code
global_exit=$((backup_exit > prune_exit ? backup_exit : prune_exit))

if [ ${global_exit} -eq 0 ]; then
  echo "[borg] backup and prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
  echo "[borg] backup and/or prune finished with warnings"
else
  echo "[borg] backup and/or prune finished with errors"
fi

exit ${global_exit}
