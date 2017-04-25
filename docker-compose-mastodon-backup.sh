#!/bin/bash
###############################################################################
# This script is intended run an unattended backup of a 
# standard docker-compose installation of Mastodon.
# It automatically finds the db-mountpoint and backs up db and folder structure
# to a configurable folder.
# It should be run from the usual Mastodon-installation-folder.
# Contributed by @Halest
###############################################################################

# Configure this:
backupLocation=/root/backup
# This is usually correct unless multiple instances are run
dbContainerName=mastodon_db_1

echo "Preparing Mastodon-backup..."
target=${backupLocation%/}
mkdir -p "$target/mastodon/db"
mkdir -p "$target/mastodon/data"

echo "Backing up Database..."
volume=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/postgresql/data" }}{{ .Source }}{{ end }}{{ end }}' $dbContainerName)
if [ -n "$volume" ]; then
    docker-compose exec db bash -c "mkdir -p /var/lib/postgresql/data/backup/ && rm /var/lib/postgresql/data/backup/mastodon.sql"
    docker-compose exec db bash -c "pg_dump -U postgres postgres > /var/lib/postgresql/data/backup/mastodon.sql"
    rm "$target/mastodon/db/mastodon.sql"
    cp "$volume/backup/mastodon.sql" "$target/mastodon/db/"
else
    echo "Couldn't determine mountpoint, not backing up database"
fi

if [ -f "Rakefile" ]; then
echo "Backing up folder structure..."
    rm "$target/mastodon/data/mastodon.tar.gz"
    tar -zcf "$target/mastodon/data/mastodon.tar.gz" .
else
    echo "Script was not run from Mastodon-folder, not backing up folder structure"
fi
echo "Backup finished"
