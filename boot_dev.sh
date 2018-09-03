#!/bin/sh

MODE=$1

bundle install --without="" --no-deployment --path=vendor/bundle \
 && yarn --pure-lockfile


echo "Start with ${MODE} mode..."

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1

case "$MODE" in
  "web")
    bundle exec rails s -p 3000 -b '0.0.0.0'
    ;;
  "sidekiq")
    bundle exec sidekiq -q default -q mailers -q pull -q push
    ;;
  "streaming")
    yarn start
    ;;
  *)
    echo "Unknown mode: ${MODE}"
    exit 1
esac
