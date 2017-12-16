#!/bin/sh

ln -sf /volumes/catgram-assets/assets /mastodon/public/assets
ln -sf /volumes/catgram-assets/packs /mastodon/public/packs

$@
