#!/bin/sh

### 1. Adds local user (UID and GID are provided from environment variables).
### 2. If the required volumes are mounted, moves precompiled assets into them.
### 3. Updates permissions, except for ./public/system (should be chown on previous installations).
###    NOTE : this can take a long time if overlay2 is the storage-driver (issue #3194).
### 4. If $RUN_DB_MIGRATIONS is set to true, runs the database migrations task.
### 5. Executes the command as that user.

echo "
---------------------------------------------
     _____         _         _
    |     |___ ___| |_ ___ _| |___ ___
    | | | | .'|_ -|  _| . | . | . |   |
    |_|_|_|__,|___|_| |___|___|___|_|_|

A GNU Social-compatible microblogging server
   https://github.com/tootsuite/mastodon
    17j2g7vpgHhLuXhN4bueZFCvdxxieyRVWd
---------------------------------------------
User  ID : ${UID}
Group ID : ${GID}
---------------------------------------------
"

echo "Creating mastodon user..."
addgroup -g ${GID} mastodon && adduser -h /mastodon -s /bin/sh -D -G mastodon -u ${UID} mastodon

if [ -d public/assets ] && [ -d public/packs ]; then
  echo "Moving assets to volumes..."
  mv /tmp/assets/* public/assets &>/dev/null
  mv /tmp/packs/* public/packs &>/dev/null
fi

echo "Updating permissions, this can take a while..."
find /mastodon -path /mastodon/public/system -prune -o -not -user mastodon -not -group mastodon -print0 | xargs -0 chown -f mastodon:mastodon

if [ "$RUN_DB_MIGRATIONS" == "true" ]; then
  echo "Running database migrations task..."
  su-exec mastodon:mastodon rake db:migrate
fi

echo "Executing process..."
exec su-exec mastodon:mastodon /sbin/tini -- "$@"
