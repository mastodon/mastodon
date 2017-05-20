#!/bin/sh
addgroup -g ${GID} mastodon && adduser -h /mastodon -s /bin/sh -D -G mastodon -u ${UID} mastodon
find /mastodon -path /mastodon/public/system -prune -o -not -user mastodon -not -group mastodon -print0 | xargs -0 chown -f mastodon:mastodon
su-exec mastodon:mastodon /sbin/tini -- "$@"
