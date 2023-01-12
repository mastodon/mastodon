#!/bin/bash

docker login
export HELLO_VERSION=$(./hello_version.sh) 
docker build . -t hello-mastodon:latest -t hello-mastodon:${HELLO_VERSION} --build-arg HELLO_VERSION=${HELLO_VERSION}
docker tag hello-mastodon:${HELLO_VERSION} hellocoop/mastodon:${HELLO_VERSION}
docker tag hello-mastodon:lastest hellocoop/mastodon:latest
docker push hellocoop/mastodon:${HELLO_VERSION}
docker push hellocoop/mastodon:latest