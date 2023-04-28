# syntax=docker/dockerfile:1.4
# This needs to be bullseye-slim because the Ruby image is built on bullseye-slim
ARG NODE_VERSION="16.20-bullseye-slim"

FROM node:${NODE_VERSION}
ARG UID="991"
ARG GID="991"

ENV DEBIAN_FRONTEND="noninteractive"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Ignoreing these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# hadolint ignore=DL3008,DL3009
RUN apt-get update && \
    echo "Etc/UTC" > /etc/localtime && \
    groupadd -g "${GID}" mastodon && \
    useradd -l -u "$UID" -g "${GID}" -m -d /opt/mastodon mastodon && \
    apt-get -y --no-install-recommends install whois \
        ca-certificates \
        tzdata \
        libreadline8 \
        tini

# Note: no, cleaning here since Debian does this automatically
# See the file /etc/apt/apt.conf.d/docker-clean within the Docker image's filesystem

COPY --chown=mastodon:mastodon . /opt/mastodon/streaming

ENV NODE_ENV="production" \
    BIND="0.0.0.0"

# Install dependencies
run yarn install --pure-lockfile --production --network-timeout 600000 && \
    yarn cache clean

# Set the run user
USER mastodon
WORKDIR /opt/mastodon/streaming

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 4000
