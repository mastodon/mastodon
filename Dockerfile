# syntax=docker/dockerfile:1.4

# Please see https://docs.docker.com/engine/reference/builder for information about
# the extended buildx capabilities used in this file.
# Make sure multiarch TARGETPLATFORM is available for interpolation
# See: https://docs.docker.com/build/building/multi-platform/
ARG TARGETPLATFORM="${TARGETPLATFORM}"
ARG BUILDPLATFORM="${BUILDPLATFORM}"

### Set software version targets for base image ###
# Ruby image to use for base image, change with [--build-arg RUBY_VERSION="3.2.2"]
ARG RUBY_VERSION="3.2.2"
# Ruby image to use for base image, change with [--build-arg DEBIAN_VERSION="bookworm"]
ARG DEBIAN_VERSION="bookworm"
# Ruby image to use for base image based on combined variables (ex: 3.2.2-slim-bookworm)
FROM ruby:${RUBY_VERSION}-slim-${DEBIAN_VERSION} as base
# # Node version to use in base image, change with [--build-arg NODE_MAJOR_VERSION="20"]
# ARG NODE_MAJOR_VERSION="20"

### Set Mastodon version string suffix ###
# Resulting version string is vX.X.X-MASTODON_VERSION_PRERELEASE+MASTODON_VERSION_METADATA
# Example: v4.2.0-nightly.2023.11.09+something
# Overwrite existance of 'dev.0' in version.rb [--build-arg MASTODON_VERSION_PRERELEASE="nightly.2023.11.09"]
ARG MASTODON_VERSION_PRERELEASE=""
# Append build metadata or fork information to version.rb [--build-arg MASTODON_VERSION_METADATA="something"]
ARG MASTODON_VERSION_METADATA=""

### Set Mastodon build options ###
# Allow Ruby on Rails to serve static files
# See: https://docs.joinmastodon.org/admin/config/#rails_serve_static_files
ARG RAILS_SERVE_STATIC_FILES="true"
# Allow to use YJIT compiler
# See: https://github.com/ruby/ruby/blob/master/doc/yjit/yjit.md
ARG RUBY_YJIT_ENABLE="1"
# Timezone used by the Docker container and runtime, change with [--build-arg TZ=Europe/Berlin]
ARG TZ="Etc/UTC"
# Linux UID (user id) for the mastodon user, change with [--build-arg UID=1234]
ARG UID="991"
# Linux GID (group id) for the mastodon user, change with [--build-arg GID=1234]
ARG GID="991"

# Apply Mastodon build options based on options above ###
ENV \
  MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
  MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}" \
  RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES} \
  RUBY_YJIT_ENABLE=${RUBY_YJIT_ENABLE} \
  TZ=${TZ}

### Set variables which are not reccomended to change ###
# Configure the IP to bind Mastodon to when serving traffic
# Use production settings for Yarn, Node and related nodejs based tools
# Use production settings for Ruby on Rails
# Add Ruby and Mastodon installation to the PATH
# Optimize jemalloc 5.x performance
ENV \
  BIND="0.0.0.0" \
  NODE_ENV="production" \
  RAILS_ENV="production" \
  DEBIAN_FRONTEND="noninteractive" \
  PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin" \
  MALLOC_CONF="narenas:2,background_thread:true,thp:never,dirty_decay_ms:1000,muzzy_decay_ms:0"

### Set default shell used for running commands ###
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]

### Run commands in base image ###
# Sets timezone
# Creates mastodon user/group and sets home direcotry
# Creates symlink for /mastodon folder
RUN \
  echo "${TZ}" > /etc/localtime; \
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon; \
  ln -s /opt/mastodon /mastodon;

### Set /opt/mastodon as working directory ###
WORKDIR /opt/mastodon

### Copy Ruby and Node package configuration files from build system to container ###
COPY Gemfile* package.json yarn.lock /opt/mastodon/

### Run commands in base image ###
# Apt update & upgrade to check for security updates to Debian image
# Install ffpmeg, imagemagick, jemalloc, curl and other necessary components
# Add Node and Yarn package repositories for Debian
# Install nodejs and yarn
# Patch Ruby to use jemalloc
# Discard patchelf and gnupg2 after use
# Cleanup Apt
# hadolint ignore=DL3008,DL3005
RUN \
  apt-get update; \
  apt-get dist-upgrade -yq; \
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
  # curl -s https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg >/dev/null; \
  # curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null; \
  # echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list; \
  # echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list; \
  # apt-get update; \
  # apt-get install -y --no-install-recommends \
  #   nodejs \
  #   yarn \
  # ; \
  patchelf --add-needed libjemalloc.so.2 /usr/local/bin/ruby; \
  apt-get purge -y \
    # gnupg2 \
    patchelf \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

### Create future run layer from base layer ###
FROM base as run
## base >> run
# Apt update install non-dev versions of necessary components
# Cleanup Apt
# hadolint ignore=DL3008
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

### Create temporary build layer from base layer ###
## base >> build
FROM base as build
# Node version to use in base image, change with [--build-arg NODE_MAJOR_VERSION="20"]
ARG NODE_MAJOR_VERSION="20"

# Install build tools and bundler dependencies from APT
# Cleanup Apt
# hadolint ignore=DL3008
RUN \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    g++ \
    gcc \
    git \
    gpg \
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
  curl -s https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg >/dev/null; \
  curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null; \
  echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list; \
  echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    nodejs \
    yarn \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

### Create temporary ruby specific build layer from base layer ###
## base >> build >> build-ruby
FROM build as build-ruby
# Configure bundle to prevent changes to Gemfile and Gemfile.lock
# Configure bundle to not cache downloaded Gems
# Configure bundle to only process production Gems
# Download and install required Gems
RUN \
  bundle config set --global frozen "true"; \
  bundle config set --global cache_all "false"; \
  bundle config set --local without "development test"; \
  bundle install;

### Create temporary node specific layer from build layer ###
## base >> build >> build-node
FROM build as build-node

# Configure yarn to prevent changes to package.json and yarn.lock
# Configure yarn to only process production Node packages
# Download and install required Node packages
# Cleanup cache of downloaded Node packages
# hadolint ignore=DL3008
RUN \
  yarn install --pure-lockfile --production --network-timeout 600000; \
  yarn cache clean --all;

FROM build as combine

COPY --from=build-ruby /opt/mastodon /opt/mastodon/
COPY --from=build-ruby /usr/local/bundle/ /usr/local/bundle/
COPY --from=build-node /opt/mastodon /opt/mastodon/

### Mastodon asset (CSS/JS/Image) creation ###
# Use Ruby on Rails to create Mastodon assets
# Cleanup temporary directory
RUN \
  OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile; \
  rm -fr /opt/mastodon/tmp;

FROM run
COPY . /opt/mastodon/
COPY --from=combine /opt/mastodon /opt/mastodon/
COPY --from=build-ruby /usr/local/bundle/ /usr/local/bundle/

### Finalize image output ###
# Set the running user for resulting container
USER mastodon

# Set container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
# Expose default Puma and Streaming ports
EXPOSE 3000