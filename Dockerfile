# syntax=docker/dockerfile:1.4

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Sets baseline for official Ruby container image
ARG RUBY_VERSION="3.2.2"
ARG DEBIAN_VERSION="bookworm"
FROM ruby:${RUBY_VERSION}-slim-${DEBIAN_VERSION} as base

# Modify these settings here or use build flags [--build-arg ARG_NAME="value"] to change default values
ARG MASTODON_VERSION_PRERELEASE=""
ARG MASTODON_VERSION_METADATA=""
ARG NODE_MAJOR_VERSION="20"
ARG RAILS_SERVE_STATIC_FILES="true"
ARG RUBY_YJIT_ENABLE="1"
ARG DEBIAN_MM_ENABLE="0"
ARG TZ="Etc/UTC"

# Applied to resulting container image, use ARG above to change these values
ENV \
  MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
  MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}" \
  RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES} \
  RUBY_YJIT_ENABLE=${RUBY_YJIT_ENABLE} \
  TZ=${TZ}

# It is not recommended to change the user/group IDs
ARG UID="991"
ARG GID="991"

# Static variables not reccomended to change
ENV \
  BIND="0.0.0.0" \
  NODE_ENV="production" \
  RAILS_ENV="production" \
  DEBIAN_FRONTEND="noninteractive" \
  PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin" \
  MALLOC_CONF="narenas:2,background_thread:true,thp:never,dirty_decay_ms:1000,muzzy_decay_ms:0"

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]

# Create dedicated mastodon user account
RUN \
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon; \
  ln -s /opt/mastodon /mastodon;

# Set mastodon working directory
WORKDIR /opt/mastodon

# Copy Mastodon source code from local build system to container
COPY --chown=mastodon:mastodon Gemfile* package.json yarn.lock /opt/mastodon/

# Install dependencies needed by all operations
RUN \
  echo "${TZ}" > /etc/localtime; \
  apt-get update; \
  apt-get upgrade -y; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    ffmpeg \
    file \
    gnupg2 \
    imagemagick \
    libjemalloc2 \
    patchelf \
    procps \
    tini \
    tzdata \
  ; \
  curl -s https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg >/dev/null; \
  curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null; \
  echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list; \
  echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    nodejs \
    yarn \
  ; \
  patchelf --add-needed libjemalloc.so.2 /usr/local/bin/ruby; \
  apt-get purge -y \
    gnupg2 \
    patchelf \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

FROM base as work
# Install build tools and dependencies from APT
RUN \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    g++ \
    gcc \
    git \
    libgdbm-dev \
    libgmp-dev \
    libicu-dev \
    libidn-dev \
    libpq-dev \
    libssl-dev \
    make \
    python3 \
    shared-mime-info \
    yarn \
    zlib1g-dev \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

FROM work as ruby
# Configure bundle
RUN \ 
  bundle config set --global frozen "true"; \
  bundle config set --global cache_all "false"; \
  bundle config set --local without "development test"; \
  bundle install;

FROM work as node
# Fetch necessary Node dependencies with Yarn
RUN \
  yarn install --pure-lockfile --production --network-timeout 600000; \
  yarn cache clean --all;

FROM base
# Install lighter versions of dependencies
RUN \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    libssl3 \
    libpq5 \
    libicu72 \
    libidn12 \
    libreadline8 \
    libyaml-0-2 \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

COPY --chown=mastodon:mastodon . /opt/mastodon
COPY --from=ruby --chown=mastodon:mastodon /opt/mastodon /opt/mastodon/
COPY --from=ruby --chown=mastodon:mastodon /usr/local/bundle/ /usr/local/bundle/
COPY --from=node --chown=mastodon:mastodon /opt/mastodon /opt/mastodon/

# Precompile assets
RUN \
  OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile; \
  rm -fr /opt/mastodon/tmp;

# Set the running user
USER mastodon

# Set container entry point and expose ports
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000 4000