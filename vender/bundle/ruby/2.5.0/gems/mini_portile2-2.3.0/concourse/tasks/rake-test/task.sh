#! /usr/bin/env bash

set -e -x -u

apt-get update
apt-get install -y cmake

pushd mini_portile

  bundle install
  bundle exec rake test

popd
