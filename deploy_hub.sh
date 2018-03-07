#!/bin/bash

set -eu -o pipefail

TAG="${TRAVIS_TAG:-latest}"

_logout() {
  docker logout
}

trap _logout EXIT TERM

docker login -u "${DOCKER_HUB_USERNAME}" -p "${DOCKER_HUB_PASSWORD}"
docker build -t "${DOCKER_HUB_USERNAME}/mastodon:${TAG}" .
docker tag "${DOCKER_HUB_USERNAME}/mastodon:${TAG}" "${DOCKER_HUB_USERNAME}/mastodon:latest"
docker push "${DOCKER_HUB_USERNAME}/mastodon:${TAG}"
docker push "${DOCKER_HUB_USERNAME}/mastodon:latest"
