#!/bin/sh

### 1. Adds local user (UID and GID are provided from environment variables).
### 2. Updates permissions, except for ./public/system (should be chown on previous installations).
### 3. Executes the command as that user.

echo "Creating mastodon user (UID : ${UID} and GID : ${GID})..."
addgroup -g ${GID} mastodon && adduser -h /mastodon -s /bin/sh -D -G mastodon -u ${UID} mastodon

echo "Updating permissions..."
find /mastodon -path /mastodon/public/system -prune -o -not -user mastodon -not -group mastodon -print0 | xargs -0 chown -f mastodon:mastodon

echo "Executing process..."
exec su-exec mastodon:mastodon /sbin/tini -- "$@"
