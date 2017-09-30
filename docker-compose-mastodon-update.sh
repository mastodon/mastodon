#!/bin/bash
#####################################################
# This script is intended for unattended upgrades 
# of a standard Mastodon installation. 
# Uncommited changes i.e. in config files 
# will be stashed and restored. 
# This script is not intended for forks with commits 
# as the latest release will be checked out.
# Database migrations and asset-precompilation will 
# run automatically.
# Contributed my @Halest
#####################################################
echo "Stashing changes, fetching and pulling latest tag"
git stash
git fetch --tags
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
git checkout $latestTag
git stash pop
echo "Recreating images and containers"
docker-compose build
docker-compose up -d
echo "Running migrations and precompilations"
docker-compose run --rm web rails assets:precompile
docker-compose run --rm web rails db:migrate
echo "Unattended upgrade finished"
