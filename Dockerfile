# syntax=docker/dockerfile:1.4
# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# See: https://github.com/hadolint/hadolint/wiki/DL3008
# hadolint global ignore=DL3008,DL3009

# Ruby version to use, change with [--build-arg RUBY_VERSION=]
ARG RUBY_VERSION="3.2.2"

# Node version to use, change with [--build-arg NODE_VERSION=]
ARG NODE_VERSION="20.7.0"

# Image variant to use for ruby and node, change with [--build-arg IMAGE_VARIANT=]
ARG IMAGE_VARIANT="bookworm"

# Image variant to use for ruby, change with [--build-arg RUBY_IMAGE_VARIANT=]
ARG RUBY_IMAGE_VARIANT="slim-${IMAGE_VARIANT}"

# Image variant to use for node, change with [--build-arg NODE_IMAGE_VARIANT=]
ARG NODE_IMAGE_VARIANT="${IMAGE_VARIANT}-slim"

# Linux UID (user id) for the mastodon user, change with [--build-arg UID=1234]
ARG UID="991"

# Linux GID (group id) for the mastodon user, change with [--build-arg GID=1234]
ARG GID="991"

# Timezone used by the Docker container and runtime, change with [--build-arg TZ=Europe/Berlin]
#
# NOTE: This will also be written to /etc/localtime
#
# See: https://blog.packagecloud.io/set-environment-variable-save-thousands-of-system-calls/
ARG TZ="Etc/UTC"

# Allow specifying your own version prerelease, change with [--build-arg MASTODON_VERSION_PRERELEASE="hello"]
ARG MASTODON_VERSION_PRERELEASE=""

# Allow specifying your own version metadata, change with [--build-arg MASTODON_VERSION_METADATA="world"]
ARG MASTODON_VERSION_METADATA=""

# Use production settings for Ruby on Rails (and thus, Mastodon)
#
# See: https://docs.joinmastodon.org/admin/config/#rails_env
# See: https://guides.rubyonrails.org/configuring.html#rails-environment-settings
ARG RAILS_ENV="production"

# Use production settings for Yarn, Node and related nodejs based tools
#
# See: https://docs.joinmastodon.org/admin/config/#node_env
ARG NODE_ENV="production"

# Allow Ruby on Rails to serve static files
#
# See: https://docs.joinmastodon.org/admin/config/#rails_serve_static_files
ARG RAILS_SERVE_STATIC_FILES="true"

# Configure the IP to bind Mastodon to when serving traffic
#
# See: https://docs.joinmastodon.org/admin/config/#bind
ARG BIND="0.0.0.0"

########################################################################################################################
FROM node:${NODE_VERSION}-${NODE_IMAGE_VARIANT} as node

########################################################################################################################
FROM ruby:${RUBY_VERSION}-${RUBY_IMAGE_VARIANT} as base
ARG UID
ARG GID
ARG TZ

RUN set -eux; \
    # Update apt due to /var/lib/apt/lists is empty
    apt-get update; \
    # Upgrade packages
	apt-get -yq dist-upgrade; \
    # Install base dependencies
    apt-get install -y --no-install-recommends \
        # Dependencies for all (includes runtime)
        ffmpeg \
        file \
        imagemagick \
        libjemalloc2 \
        tini \
        tzdata \
        wget \
        # Dependencies for ruby gems
        libicu72 \
        libidn12 \
        libpq5 \
        # Dependencies for nodejs
        libatomic1 \
    ; \
    # Remove /var/lib/apt/lists as cache
    rm -rf /var/lib/apt/lists/*; \
    # Set local timezone
    echo "${TZ}" > /etc/localtime; \
    # Add mastodon group and user
    groupadd -g "${GID}" mastodon; \
    useradd -u "${UID}" -g "${GID}" -l -m -d /opt/mastodon mastodon; \
    # Symlink /opt/mastodon to /mastodon
    ln -s /opt/mastodon /mastodon;

WORKDIR /opt/mastodon

# Node image contains node on /usr/local
#
# See: https://github.com/nodejs/docker-node/blob/151ec75067877000120d634fc7fd2a18c544e3d4/20/bookworm-slim/Dockerfile
COPY --link --from=node /usr/local/bin /usr/local/bin
COPY --link --from=node /usr/local/lib /usr/local/lib

ENV COREPACK_HOME /usr/local/corepack

RUN set -eux; \
    rm /usr/local/bin/yarn*; \
    corepack enable; \
    yarn set version classic; \
    # Smoke test for node, yarn
    node --version; \
    yarn --version; \
    # Remove tmp files from node
    rm -rf .yarn* /tmp/*;

########################################################################################################################
FROM base as builder-base

# Node image contains node on /usr/local
#
# See: https://github.com/nodejs/docker-node/blob/151ec75067877000120d634fc7fd2a18c544e3d4/20/bookworm-slim/Dockerfile
COPY --link --from=node /usr/local/include /usr/local/include

RUN set -eux; \
    # Update apt due to /var/lib/apt/lists is empty
    apt-get update; \
    # Install builder dependencies
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        nasm \
        pkg-config \
        xz-utils \
    ;

########################################################################################################################
FROM builder-base as ruby-builder
ARG RAILS_ENV

ADD Gemfile* /opt/mastodon/

RUN set -eux; \
    # Install ruby gems dependencies
    apt-get install -y --no-install-recommends \
        libicu-dev \
        libidn-dev \
        libpq-dev \
    ; \
    # Set bundle configs
    bundle config set --local deployment 'true'; \
    case "${RAILS_ENV}" in \
        development) bundle config set --local without 'test';; \
        test) bundle config set --local without 'development';; \
        production) bundle config set --local without 'development test';; \
    esac; \
    # Install gems
    bundle install --no-cache;

########################################################################################################################
FROM builder-base as node-builder
ARG NODE_ENV

ADD package.json yarn.lock /opt/mastodon/

RUN set -eux; \
    # Download and install yarn packages
    yarn install --frozen-lockfile --network-timeout 600000; \
    yarn cache clean --all;

########################################################################################################################
FROM base
ARG RAILS_ENV
ARG NODE_ENV
ARG RAILS_SERVE_STATIC_FILES
ARG BIND
ARG MASTODON_VERSION_PRERELEASE
ARG MASTODON_VERSION_METADATA

# Copy the git source code into the image layer
COPY --link . /opt/mastodon

# Copy output of the "bundle install" build stage into this layer
COPY --link --from=ruby-builder ${BUNDLE_APP_CONFIG}/config ${BUNDLE_APP_CONFIG}/config
COPY --link --from=ruby-builder /opt/mastodon/vendor/bundle /opt/mastodon/vendor/bundle

# Copy output of the "yarn install" build stage into this image layer
COPY --link --from=node-builder /opt/mastodon/node_modules /opt/mastodon/node_modules

# Run commands before the mastodon user used
RUN set -eux; \
    # Create some dirs as 1777
    mkdir -p /opt/mastodon/tmp && chmod 1777 /opt/mastodon/tmp; \
    mkdir -p /opt/mastodon/log && chmod 1777 /opt/mastodon/log; \
    mkdir -p /opt/mastodon/public && chmod 1777 /opt/mastodon/public; \
    mkdir -p /opt/mastodon/public/assets && chmod 1777 /opt/mastodon/public/assets; \
    mkdir -p /opt/mastodon/public/packs && chmod 1777 /opt/mastodon/public/packs; \
    mkdir -p /opt/mastodon/public/system && chmod 1777 /opt/mastodon/public/system;

# Set runtime envs
ENV PATH="${PATH}:/opt/mastodon/bin" \
    LD_PRELOAD="libjemalloc.so.2" \
    RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}" \
    RAILS_SERVE_STATIC_FILES="${RAILS_SERVE_STATIC_FILES}" \
    BIND="${BIND}" \
    MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
    MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}"

# Use the mastodon user from here on out
USER mastodon

RUN set -eux; \
    # assets:precompile when RAILS_ENV is not development
    case "${RAILS_ENV}" in \
        development) exit 0;; \
        *) \
            # Precompile assets
            OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile; \
            # Remove tmp files from assets:precompile
            rm -rf /tmp/* tmp/* log/* .cache/*; \
        ;; \
    esac;

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 3000 4000
