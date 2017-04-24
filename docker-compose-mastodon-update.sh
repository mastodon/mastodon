#!/bin/bash
git stash
git pull
git stash pop
docker-compose build
docker-compose up -d
docker-compose run --rm web rails assets:precompile
docker-compose run --rm web rails db:migrate
