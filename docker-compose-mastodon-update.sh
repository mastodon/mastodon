#!/bin/bash
git stash
git fetch --tags
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
git checkout $latestTag
git stash pop
docker-compose build
docker-compose up -d
docker-compose run --rm web rails assets:precompile
docker-compose run --rm web rails db:migrate
