# syntax=docker/dockerfile:1.4
# This needs to be bullseye-slim because the Ruby image is built on bullseye-slim
ARG NODE_VERSION="16.20-bullseye-slim"
ARG RUBY_JEMALLOC="ghcr.io/moritzheiber/ruby-jemalloc:3.2.2-slim"

# builder-native is a stage that builds npm packages and precompiles assets in the native arch of the builder.
# This allows said CPU-intensive task to run 10x faster than it would under an emulated architecture.
# Outputs of this stage are arch-independent and thus copied over by the arch-dependent stages.
FROM --platform=$BUILDPLATFORM $RUBY_JEMALLOC as ruby-native
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION} as builder-native

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --link --from=ruby-native /opt/ruby /opt/ruby

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin"

# TODO: Unclear which of the following env vars are needed for build and which ones are needed for dist.
# Use those args to specify your own version flags & suffixes
ARG MASTODON_VERSION_FLAGS=""
ARG MASTODON_VERSION_SUFFIX=""

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" \
    BIND="0.0.0.0" \
    MASTODON_VERSION_FLAGS="${MASTODON_VERSION_FLAGS}" \
    MASTODON_VERSION_SUFFIX="${MASTODON_VERSION_SUFFIX}"

ARG UID="991"
ARG GID="991"
RUN groupadd -g "${GID}" mastodon && \
    useradd -l -u "$UID" -g "${GID}" -m -d /opt/mastodon mastodon
WORKDIR /opt/mastodon

# TODO: Clarify which of these are runtime deps, as they can be removed form this step.
# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# hadolint ignore=DL3008,DL3009
RUN echo "Etc/UTC" > /etc/localtime && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
        build-essential \
        ca-certificates \
        ffmpeg \
        file \
        git \
        imagemagick \
        libgdbm-dev \
        libgmp-dev \
        libicu67 \
        libicu-dev \
        libidn11 \
        libidn11-dev \
        libjemalloc2 \
        libjemalloc-dev \
        libpq5 \
        libpq-dev \
        libreadline8 \
        libssl1.1 \
        libssl-dev \
        libyaml-0-2 \
        procps \
        python3 \
        tzdata \
        wget \
        whois \
        zlib1g-dev \
        shared-mime-info

USER mastodon

# Instal NPM deps in native arch.
COPY package.json yarn.lock /opt/mastodon/

RUN yarn install --pure-lockfile --production --network-timeout 600000 && \
    yarn cache clean

# Build ruby packages and assets in native arch.
# Ruby packages will need to be re-built in emulated arches, but assets will be reused from this stage.
COPY --chown=mastodon:mastodon . /opt/mastodon

RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle config set silence_root_warning true && \
    bundle install -j"$(nproc)"

RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile


# target contains the common steps for the arch-specific stages.
FROM $RUBY_JEMALLOC as ruby
FROM node:${NODE_VERSION} as target

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --link --from=ruby /opt/ruby /opt/ruby

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin"

# TODO: Unclear which of the following env vars are needed for build and which ones are needed for dist.
# Use those args to specify your own version flags & suffixes
ARG MASTODON_VERSION_FLAGS=""
ARG MASTODON_VERSION_SUFFIX=""

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" \
    BIND="0.0.0.0" \
    MASTODON_VERSION_FLAGS="${MASTODON_VERSION_FLAGS}" \
    MASTODON_VERSION_SUFFIX="${MASTODON_VERSION_SUFFIX}"

ARG UID="991"
ARG GID="991"
RUN groupadd -g "${GID}" mastodon && \
    useradd -l -u "$UID" -g "${GID}" -m -d /opt/mastodon mastodon
WORKDIR /opt/mastodon

# Builder is the arch-specific build stage.
FROM target as builder

# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# hadolint ignore=DL3008,DL3009
RUN echo "Etc/UTC" > /etc/localtime && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
        build-essential \
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
        shared-mime-info

USER mastodon

COPY --chown=mastodon:mastodon . /opt/mastodon

# Ruby installation is arch-dependent so unfortunately we need to run it again.
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle config set silence_root_warning true && \
    bundle install -j"$(nproc)"

# Finally, target installs runtime deps and copies outputs from the non-arch specific and the arch-specific stages.
FROM target

# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# hadolint ignore=DL3008,DL3009
RUN echo "Etc/UTC" > /etc/localtime && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
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
        tini

COPY --chown=mastodon:mastodon --from=builder-native /opt/mastodon /opt/mastodon
COPY --chown=mastodon:mastodon --from=builder /opt/mastodon /opt/mastodon

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000 4000
