#!/bin/sh

MODE=$1

bundle install --without="" \
 && yarn --pure-lockfile


echo "Start with ${MODE} mode..."

case "$MODE" in
  "web")
    bundle exec rails s -p 3000 -b '0.0.0.0'
    ;;
  "sidekiq")
    bundle exec sidekiq -q default -q mailers -q pull -q push
    ;;
  "streaming")
    npm run start
    ;;
  *)
    echo "Unknown mode: ${MODE}"
    exit 1
esac
