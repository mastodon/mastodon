#!/bin/bash

/usr/local/bin/docker-compose up -d
/usr/local/bin/docker-compose run --rm web rails db:migrate
/usr/local/bin/docker-compose run --rm web rails assets:precompile
/usr/local/bin/docker-compose run --rm web rake mastodon:media:clear
/usr/local/bin/docker-compose run --rm web rake mastodon:users:clear
/usr/local/bin/docker-compose restart web streaming sidekiq
