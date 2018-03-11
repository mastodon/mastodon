#!/bin/sh
chown mastodon:mastodon /mastodon/public/system
exec su mastodon -c "exec /sbin/tini -- $*"
