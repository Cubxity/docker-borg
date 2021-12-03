FROM alpine:3.13.6

# Cron interval to run backups, default: every day at 2AM.
ENV CRON_INTERVAL="0 2 * * *"

# The borg repository to use, see: https://borgbackup.readthedocs.io/en/stable/usage/general.html#repository-urls.
# Note that SSH is not supported since openssh is not installed.
ENV BORG_REPO="/home/borg/repo"

# Authentication password for the repository.
ENV BORG_PASSPHRASE=""

# Compression to use, supported values: lz4, zstd, zlib, and lzma.
ENV BORG_COMPRESSION="lz4"

# List of files to include, separated by spaces.
ENV BORG_FILES="/home/borg/data"

# The prefix used for archives.
ENV BORG_ARCHIVE_PREFIX="{hostname}-"

# The name used for archives, after the prefix.
ENV BORG_ARCHIVE_NAME="{now}"

# List of arguments to pass to 'borg prune'.
ENV BORG_PRUNE_ARGUMENTS="--keep-daily 7 --keep-weekly 4 --keep-monthly 6"

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=048b95b48b708983effb2e5c935a1ef8483d9e3e

RUN addgroup -g 1000 borg \
  && adduser -Ss /bin/false -u 1000 -G borg -h /home/borg borg \
  && mkdir -m 775 /home/borg/repo \
  && chown borg:borg /home/borg/repo \
  && apk add --no-cache borgbackup \
  && wget -O /usr/local/bin/supercronic "$SUPERCRONIC_URL" \
  && echo "${SUPERCRONIC_SHA1SUM}  /usr/local/bin/supercronic" | sha1sum -c - \
  && chmod +x /usr/local/bin/supercronic
COPY bin/ /home/borg

USER borg
WORKDIR /home/borg
CMD ["/home/borg/start.sh"]
