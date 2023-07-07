# syntax=docker/dockerfile:1.4

# Please see https://docs.docker.com/engine/reference/builder for information about
# the extended buildx capabilities used in this file.

# Node image to use for building and runtime, change with [--build-arg NODE_VERSION=]
#
# Note: This needs to be bullseye-slim because the Ruby image is built on bullseye-slim
# See: https://hub.docker.com/_/node/tags
ARG NODE_VERSION="16.20-bullseye-slim"

# Ruby image to use for building and runtime, change with [--build-arg RUBY_VERSION=]
#
# See: https://github.com/moritzheiber/ruby-jemalloc-docker/pkgs/container/ruby-jemalloc
ARG RUBY_VERSION="3.2.2-slim"

ARG TARGETPLATFORM="${TARGETPLATFORM}"
ARG BUILDPLATFORM="${BUILDPLATFORM}"

##########################################################################################
# Ruby image, referenced here for easier alias (ruby-layer) reference later
##########################################################################################

FROM ghcr.io/moritzheiber/ruby-jemalloc:${RUBY_VERSION} AS ruby-layer

##########################################################################################
# Base layer used for both the build steps and the final runtime image
##########################################################################################

FROM node:${NODE_VERSION} AS base-layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential \
        git \
        libicu-dev \
        libidn-dev \
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
        shared-mime-info && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle config set silence_root_warning true && \
    bundle install -j"$(nproc)" && \
    yarn install --pure-lockfile --production --network-timeout 600000 && \
    yarn cache clean

# Make sure multiarch TARGETPLATFORM is available for interpolation
#
# See: https://docs.docker.com/build/building/multi-platform/
ARG TARGETPLATFORM

# See: https://docs.docker.com/build/building/multi-platform/
#
# Make sure multiarch BUILDPLATFORM is available for interpolation
ARG BUILDPLATFORM

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
ENV TZ=${TZ}

# Allow specifying your own version prerelease, change with [--build-arg MASTODON_VERSION_PRERELEASE="hello"]
ARG MASTODON_VERSION_PRERELEASE=""
ENV MASTODON_VERSION_PRERELEASE=${MASTODON_VERSION_FLAGS}

# Allow specifying your own version metadata, change with [--build-arg MASTODON_VERSION_METADATA="world"]
ARG MASTODON_VERSION_METADATA=""
ENV MASTODON_VERSION_METADATA=${MASTODON_VERSION_SUFFIX}

# Use production settings for Ruby on Rails (and thus, Mastodon)
#
# See: https://docs.joinmastodon.org/admin/config/#rails_env
# See: https://guides.rubyonrails.org/configuring.html#rails-environment-settings
ARG RAILS_ENV="production"
ENV RAILS_ENV=${RAILS_ENV}

# Use production settings for Yarn, Node and related nodejs based tools
#
# See: https://docs.joinmastodon.org/admin/config/#node_env
ARG NODE_ENV="production"
ENV NODE_ENV=${NODE_ENV}

# Allow Ruby on Rails to serve static files
#
# See: https://docs.joinmastodon.org/admin/config/#rails_serve_static_files
ARG RAILS_SERVE_STATIC_FILES="true"
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES}

# Configure the IP to bind Mastodon to when serving traffic
#
# See: https://docs.joinmastodon.org/admin/config/#bind
ARG BIND="0.0.0.0"
ENV BIND=${BIND}

# Default shell used for running commands
#
# See: https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]

# Turn off any and all interactivetity from apt commands
#
# See: https://manpages.debian.org/testing/debconf-doc/debconf.7.en.html#noninteractive
ENV DEBIAN_FRONTEND="noninteractive"

# Persist timezone to disk as well
RUN echo "${TZ}}" > /etc/localtime

# Add Ruby and Mastodon installation to the PATH
ENV PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin"

# ”install" ruby from the ruby layer
COPY --from=ruby-layer /opt/ruby /opt/ruby

RUN \
  # We don't want to have the automatic apt docker-clean script running, since we're caching
  # these files between runs to help speed up builds.
  #
  # The way the caching work also mean the apt caches won't be included in the final image anyway
  rm -f /etc/apt/apt.conf.d/docker-clean && \
  # Create the mastodon user
  groupadd -g "${GID}" mastodon && \
  useradd -l -u "$UID" -g "${GID}" -m -d /opt/mastodon mastodon

# Change the working directory from here on out to the mastodon installation path
WORKDIR /opt/mastodon

##########################################################################################
# Shared layer for nodejs and ruby related build steps
##########################################################################################

FROM base-layer AS build-layer

# See: https://github.com/hadolint/hadolint/wiki/DL3008
# hadolint ignore=DL3008,DL3009
RUN \
  # --mount=type=cache,target=/var/cache/apt,id=build-apt-cache-${TARGETPLATFORM} \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    libgdbm-dev \
    libgmp-dev \
    libicu-dev \
    libidn11-dev \
    libjemalloc-dev \
    libpq-dev \
    libreadline8 \
    libssl-dev \
    libyaml-0-2 \
    python3 \
    shared-mime-info \
    zlib1g-dev

##########################################################################################
# Bundle cache + install layer
##########################################################################################

FROM build-layer AS bundle-install

# Download and cache gems without "installing" them
#
# By splitting "cache" from "install" we can avoid [Could not find $GEM_NAME in cached gems or installed locally]
#
# NOTE: Instead of copying Gemfile and Gemfile.lock, we bind them to the container at build time
# this avoids the issue of the files "changing" (e.g. a newline) invalidating the cache,
# even though the "parsed" content is the same, and makes the file read-only and immutable
# inside the build step, preventing "quiet" changes to the files
RUN \
  # --mount=type=cache,target=/opt/mastodon/vendor/cache,id=bundle-cache-${TARGETPLATFORM} \
  --mount=type=bind,source=Gemfile,target=Gemfile \
  --mount=type=bind,source=Gemfile.lock,target=Gemfile.lock \
  bundle config set --local without 'development test' && \
  bundle config set silence_root_warning 'true' && \
  bundle cache --no-install

# Install gems from the cache above
RUN \
  # --mount=type=cache,target=/opt/mastodon/vendor/cache,id=bundle-cache-${TARGETPLATFORM} \
  --mount=type=bind,source=Gemfile,target=Gemfile \
  --mount=type=bind,source=Gemfile.lock,target=Gemfile.lock \
  bundle config set --local deployment 'true' && \
  bundle install --local

##########################################################################################
# Yarn cache + install layer
##########################################################################################

FROM build-layer AS yarn-install

ENV YARN_CACHE_FOLDER=/opt/mastodon/cache/.yarn

# Download and install yarn packages
#
# Note: Instead of copying package.json and yarn.lock, we bind them to the container at build time
# this avoids the issue of the files "changing" (e.g. a newline) invalidating the cache,
# even though the "parsed" content is the same, and makes the file read-only and immutable
# inside the build step, preventing "quiet" changes to the files
RUN \
  # --mount=type=cache,target=/opt/mastodon/cache/.yarn,id=yarn-cache-${TARGETPLATFORM} \
  --mount=type=bind,source=package.json,target=package.json \
  --mount=type=bind,source=yarn.lock,target=yarn.lock \
  yarn install --pure-lockfile --production --network-timeout 600000

##########################################################################################
# Runtime layer, this is the output layer that the end-user will use
##########################################################################################

FROM base-layer AS runtime-layer

# hadolint ignore=DL3008,DL3009
RUN \
  # --mount=type=cache,target=/var/cache/apt,id=runtime-apt-cache-${TARGETPLATFORM} \
  apt-get update && \
  apt-get -y --no-install-recommends install \
    ca-certificates \
    ffmpeg \
    file \
    imagemagick \
    libicu72 \
    libidn12 \
    libjemalloc2 \
    libpq5 \
    libreadline8 \
    libssl3 \
    libyaml-0-2 \
    procps \
    tini \
    tzdata \
    wget \
    whois

# Symlink /opt/mastodon to /mastodon
RUN ln -s /opt/mastodon /mastodon

# [1/3] Copy the git source code into the image layer
COPY --link . /opt/mastodon

# [2/3] Copy output of the "bundle install" build stage into this layer
COPY --link --from=bundle-install /opt/mastodon /opt/mastodon

# [3/3] Copy output of the "yarn install" build stage into this image layer
COPY --link --from=yarn-install /opt/mastodon /opt/mastodon

RUN mkdir /opt/mastodon/tmp && chown mastodon:mastodon /opt/mastodon/tmp

##########################################################################################
# Assets layer
##########################################################################################

FROM runtime-layer AS assets-precompile

RUN \
  # --mount=type=cache,target=/opt/mastodon/tmp/cache,uid=${UID},gid=${GID},id=assets-cache-${BUILDPLATFORM},sharing=locked \
  OTP_SECRET=precompile_placeholder \
  SECRET_KEY_BASE=precompile_placeholder \
  rails assets:precompile

##########################################################################################
# Final layer
##########################################################################################

FROM runtime-layer

COPY --link --from=assets-precompile /opt/mastodon/public /opt/mastodon/public

# Use the mastodon user from here on out
USER mastodon

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 3000 4000
