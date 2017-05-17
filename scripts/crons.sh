#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

/usr/local/bin/docker-compose run --rm web rake mastodon:daily > /dev/null
/usr/bin/docker exec mastodon_db_1 pg_dump --clean postgres -U postgres | gzip > /home/mastodon/backup/mastodon-backup-$(date +"%Y-%m-%d").sql.gz
