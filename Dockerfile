# syntax=docker/dockerfile:1.4
# This needs to be bullseye-slim because the Ruby image is built on bullseye-slim
ARG NODE_VERSION="16.18.1-bullseye-slim"

FROM ghcr.io/moritzheiber/ruby-jemalloc:3.0.4-slim as ruby
FROM node:${NODE_VERSION} as build

COPY --link --from=ruby /opt/ruby /opt/ruby

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends  \
        build-essential \
        ca-certificates \
        git \
        libicu-dev \
        libidn11-dev \
        libpq-dev \
        libjemalloc-dev \
        zlib1g-dev \
        libgdbm-dev \
        libgmp-dev \
        libssl-dev \
        libyaml-0-2 \
        ca-certificates \
        libreadline8 \
        python3 \
        shared-mime-info  \
    && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/mastodon

COPY Gemfile* package.json yarn.lock /opt/mastodon/

RUN set -eux && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle config set silence_root_warning true && \
    bundle install -j"$(nproc)" && \
    yarn install --pure-lockfile --network-timeout 600000

COPY . /opt/mastodon

# Precompile assets
RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile && \
    yarn cache clean

FROM debian:bullseye-slim as prod

ARG UID="991"
ARG GID="991"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" \
    BIND="0.0.0.0" \
    PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin"

COPY --from=build --link /usr/local/bin/node /usr/local/bin/node
COPY --from=ruby --link /opt/ruby /opt/ruby

# Ignoreing these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# hadolint ignore=DL3008
RUN apt-get update && \
    echo "Etc/UTC" > /etc/localtime && \
    groupadd -g "${GID}" mastodon && \
    useradd -l -u "$UID" -g "${GID}" -m -d /opt/mastodon mastodon && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install  \
        whois \
        wget \
        procps \
        libssl1.1 \
        libpq5 \
        imagemagick \
        ffmpeg \
        libjemalloc2 \
        libicu67 \
        libidn11 \
        libyaml-0-2 \
        file \
        ca-certificates \
        tzdata \
        libreadline8 \
        tini  \
    && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /opt/mastodon /mastodon

# Set the run user
USER mastodon
WORKDIR /opt/mastodon

COPY --chown=${UID}:${GID} --from=build --link /opt/mastodon /opt/mastodon

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000 4000
