# syntax=docker/dockerfile:1.4
# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# hadolint global ignore=DL3008
ARG RUBY_VERSION="3.2.2"
ARG NODE_VERSION="20.6.0"

# Use those args to specify your own version flags & suffixes
ARG MASTODON_VERSION_PRERELEASE=""
ARG MASTODON_VERSION_METADATA=""

ARG UID="991"
ARG GID="991"

################################################################################
FROM ruby:${RUBY_VERSION}-slim-bookworm as base
ARG NODE_VERSION

# Install Node.js, Yarn
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl gnupg; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION%%.*}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list; \
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null; \
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs=${NODE_VERSION}\* yarn; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark nodejs yarn > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf \
        /usr/share/keyrings/nodesource.gpg \
        /etc/apt/sources.list.d/nodesource.list \
        /usr/share/keyrings/yarnkey.gpg \
        /etc/apt/sources.list.d/yarn.list \
        /var/lib/apt/lists/* \
    ; \
    node --version; \
    yarn --version;

# Install Runtime dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        ffmpeg \
        file \
        imagemagick \
        libicu72 \
        libidn12 \
        libjemalloc2 \
        libpq5 \
        libssl3 \
        shared-mime-info \
        tini \
        tzdata \
        wget \
        zlib1g \
    ; \
    rm -rf /var/lib/apt/lists/*;

RUN set -eux; \
    bundle config set --local deployment 'true'; \
    bundle config set --local without 'development test'; \
    bundle config set silence_root_warning true;

WORKDIR /opt/mastodon

################################################################################
FROM base as base-builder 

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends build-essential git; \
    rm -rf /var/lib/apt/lists/*;

################################################################################
FROM base-builder as ruby-builder

COPY Gemfile* /opt/mastodon/

# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libicu-dev \
        libidn-dev \
        libpq-dev \
        libssl-dev \
        zlib1g-dev \
    ; \
    bundle install -j"$(nproc)";

################################################################################
FROM base-builder as node-builder

COPY package.json yarn.lock /opt/mastodon/

# hadolint ignore=DL3008
RUN set -eux; \
    yarn install --pure-lockfile --production --network-timeout 600000; \
    yarn cache clean;

################################################################################
FROM base
ARG MASTODON_VERSION_PRERELEASE
ARG MASTODON_VERSION_METADATA
ARG UID
ARG GID

RUN set -eux; \
    echo "Etc/UTC" > /etc/localtime; \
    groupadd -g "${GID}" mastodon; \
    useradd -l -u "$UID" -g "${GID}" -m -d /opt/mastodon mastodon; \
    ln -s /opt/mastodon /mastodon;

COPY --chown=mastodon:mastodon . /opt/mastodon
COPY --chown=mastodon:mastodon --from=ruby-builder /opt/mastodon /opt/mastodon
COPY --chown=mastodon:mastodon --from=node-builder /opt/mastodon /opt/mastodon

ENV PATH="${PATH}:/opt/mastodon/bin" \
    LD_PRELOAD="libjemalloc.so.2" \
    RAILS_ENV="production" \
    NODE_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" \
    BIND="0.0.0.0" \
    MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
    MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}"

# Precompile assets
RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile

# Set the run user
USER mastodon

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000 4000
