#!/bin/sh

LINK=/mastodon/public/assets
test -d $LINK && test ! -L $LINK && rm -rf $LINK
ln -sf /volumes/catgram-assets/assets $LINK

LINK=/mastodon/public/packs
test -d $LINK && test ! -L $LINK && rm -rf $LINK
ln -sf /volumes/catgram-assets/packs $LINK

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1

$@
