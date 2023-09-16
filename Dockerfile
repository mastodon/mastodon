# syntax=docker/dockerfile:1.4
# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# See: https://github.com/hadolint/hadolint/wiki/DL3008
# hadolint global ignore=DL3008,DL3009

# Ruby image to use for building and runtime, change with [--build-arg RUBY_VERSION=]
ARG RUBY_VERSION="3.2.2"

# Node image to use for building and runtime, change with [--build-arg NODE_VERSION=]
ARG NODE_VERSION="20.6.0"

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
FROM node:${NODE_VERSION}-bookworm-slim as node

########################################################################################################################
FROM ruby:${RUBY_VERSION}-slim-bookworm as base
ARG TZ
ARG UID
ARG GID

RUN set -eux; \
    # Update apt due to /var/lib/apt/lists is empty
    apt-get update; \
    # Upgrade packages
	apt-get -yq dist-upgrade; \
    # Install base dependencies
    apt-get install -y --no-install-recommends \
        libatomic1 \
        libicu72 \
        libidn12 \
        libpq5 \
        tzdata \
    ; \
    # Remove /var/lib/apt/lists as cache
    rm -rf /var/lib/apt/lists/*; \
    # Set local timezone
    echo "${TZ}" > /etc/localtime;

# Node image contains node and yarn on /usr/local and /opt
#
# See: https://github.com/nodejs/docker-node/blob/151ec75067877000120d634fc7fd2a18c544e3d4/20/bookworm-slim/Dockerfile
COPY --link --from=node /usr/local /usr/local
COPY --link --from=node /opt /opt

RUN set -eux; \
    # Smoke test for node, yarn
    node --version; \
    yarn --version; \
    # Remove tmp files from node
    rm -rf /tmp/*;

RUN set -eux; \
    # Add mastodon group and user
    groupadd -g "${GID}" mastodon; \
    useradd -u "${UID}" -g "${GID}" -l -m -d /opt/mastodon mastodon; \
    # Symlink /opt/mastodon to /mastodon
    ln -s /opt/mastodon /mastodon;

WORKDIR /opt/mastodon

RUN set -eux; \
    # Set bundle configs
    bundle config set --local deployment 'true'; \
    bundle config set --local without 'development test';

########################################################################################################################
FROM base as builder-base

RUN set -eux; \
    # Update apt due to /var/lib/apt/lists is empty
    apt-get update; \
    # Install builder dependencies
    apt-get install -y --no-install-recommends build-essential;

########################################################################################################################
FROM builder-base as ruby-builder

ADD Gemfile* /opt/mastodon/

RUN set -eux; \
    # Install ruby gems dependencies
    apt-get install -y --no-install-recommends \
        git \
        libicu-dev \
        libidn-dev \
        libpq-dev \
    ; \
    # Install gems
    bundle install --no-cache;

########################################################################################################################
FROM builder-base as node-builder

ADD package.json yarn.lock /opt/mastodon/

RUN set -eux; \
    # Download and install yarn packages
    yarn install --immutable; \
    yarn cache clean --all;

########################################################################################################################
FROM base
ARG TZ
ARG RAILS_ENV
ARG NODE_ENV
ARG RAILS_SERVE_STATIC_FILES
ARG BIND
ARG MASTODON_VERSION_PRERELEASE
ARG MASTODON_VERSION_METADATA

RUN set -eux; \
    # Update apt due to /var/lib/apt/lists is empty
    apt-get update; \
    # Install runtime dependencies
    apt-get install -y --no-install-recommends \
        file \
        imagemagick \
        libjemalloc2 \
        tini \
        wget \
    ; \
    # Remove /var/lib/apt/lists as cache
    rm -rf /var/lib/apt/lists/*;

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    # Marks currently installed apt packages
    savedAptMark="$(apt-mark showmanual)"; \
    # Update apt due to /var/lib/apt/lists is empty
    apt-get update; \
    # Install ffmpeg installation dependencies
    apt-get install -y --no-install-recommends \
        xz-utils \
    ; \
    # Download and install ffmpeg latest release version
    wget -q "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-${dpkgArch}-static.tar.xz"; \
    wget -q "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-${dpkgArch}-static.tar.xz.md5"; \
    md5sum -c ffmpeg-release-${dpkgArch}-static.tar.xz.md5; \
    tmp="$(mktemp -d)"; \
    tar -xJf "ffmpeg-release-${dpkgArch}-static.tar.xz" -C "${tmp}" --strip-components=1 --no-same-owner; \
    rm "ffmpeg-release-${dpkgArch}-static.tar.xz" "ffmpeg-release-${dpkgArch}-static.tar.xz.md5"; \
    mv "${tmp}/ffmpeg" /usr/local/bin/; \
    mv "${tmp}/ffprobe" /usr/local/bin/; \
    rm -r "${tmp}"; \
    # Remove unrequired packages on runtime
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    # Remove /var/lib/apt/lists as cache
    rm -rf /var/lib/apt/lists/*; \
    # smoke tests for ffmpeg, ffprobe
    ffmpeg -version; \
    ffprobe -version;

# [1/3] Copy the git source code into the image layer
COPY --link . /opt/mastodon
# [2/3] Copy output of the "bundle install" build stage into this layer
COPY --link --from=ruby-builder /opt/mastodon/vendor/bundle /opt/mastodon/vendor/bundle
# [3/3] Copy output of the "yarn install" build stage into this image layer
COPY --link --from=node-builder /opt/mastodon/node_modules /opt/mastodon/node_modules

RUN set -eux; \
    # Create some dirs as mastodon:mastodon
    mkdir /opt/mastodon/tmp && chown mastodon:mastodon /opt/mastodon/tmp; \
    mkdir /opt/mastodon/public/assets && chown mastodon:mastodon /opt/mastodon/public/assets; \
    mkdir /opt/mastodon/public/packs && chown mastodon:mastodon /opt/mastodon/public/packs; \
    mkdir /opt/mastodon/public/system && chown mastodon:mastodon /opt/mastodon/public/system;

ENV PATH="${PATH}:/opt/mastodon/bin" \
    LD_PRELOAD="libjemalloc.so.2" \
    TZ="${TZ}" \
    RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}" \
    RAILS_SERVE_STATIC_FILES="${RAILS_SERVE_STATIC_FILES}" \
    BIND="${BIND}" \
    MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
    MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}"

# Use the mastodon user from here on out
USER mastodon

RUN set -eux; \
    # Precompile assets
    OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile; \
    # Remove tmp files from node
    rm -rf /tmp/*;

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 3000 4000
