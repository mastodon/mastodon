#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

/usr/bin/docker exec mastodon_db_1 pg_dump --clean postgres -U postgres | gzip > /home/mastodon/backup/mastodon-backup-upgrade-snapshot.sql.gz
git checkout master && git pull
/usr/local/bin/docker-compose build
./restart.sh
/usr/bin/docker image prune -f
