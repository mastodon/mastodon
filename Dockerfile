# syntax=docker/dockerfile:1.4
# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# See: https://github.com/hadolint/hadolint/wiki/DL3008
# hadolint global ignore=DL3008,DL3009

ARG BASE_IMAGE="gchr.io/mastodon/mastodon/base"

# Linux UID (user id) for the mastodon user, change with [--build-arg UID=1234]
ARG UID="991"

# Linux GID (group id) for the mastodon user, change with [--build-arg GID=1234]
ARG GID="991"

# Mastodon home directory for the mastodon user and project, change with [--build-arg MASTODON_HOME=/some/path]
ARG MASTODON_HOME="/opt/mastodon"

# Timezone used by the Docker container and runtime, change with [--build-arg TZ=Europe/Berlin]
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
FROM ${BASE_IMAGE} as base
ARG TARGETPLATFORM
ARG UID
ARG GID
ARG MASTODON_HOME
ARG TZ
ARG RAILS_ENV
ARG NODE_ENV

RUN \
    --mount=type=cache,id=${TARGETPLATFORM}-/var/cache,target=/var/cache,sharing=locked \
    --mount=type=cache,id=${TARGETPLATFORM}-/var/lib/apt,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    set -eux; \
    # Update apt
    apt-get update; \
    # Upgrade packages
    apt-get -yq dist-upgrade; \
    # Install dependencies
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        # Dependencies for runtime
        file \
        libjemalloc2 \
        tini \
        tzdata \
        wget \
        # Dependencies for ruby gems
        libicu72 \
        libidn12 \
        libpq5 \
    ;

RUN set -eux; \
    # Add mastodon group and user
    groupadd -g "${GID}" mastodon; \
    useradd -u "${UID}" -g "${GID}" -l -m -d "${MASTODON_HOME}" mastodon; \
    # Set bundle configs
    bundle config set --local path 'vendor/bundle'; \
    case "${RAILS_ENV}" in \
        test) bundle config set --local without 'development';; \
        production) \
            bundle config set --local deployment 'true'; \
            bundle config set --local without 'development test'; \
        ;; \
    esac;

ENV MASTODON_HOME="${MASTODON_HOME}" \
    TZ="${TZ}" \
    RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}"

WORKDIR ${MASTODON_HOME}

########################################################################################################################
FROM base as builder-base
ARG TARGETPLATFORM

RUN \
    --mount=type=cache,id=${TARGETPLATFORM}-/var/cache,target=/var/cache,sharing=locked \
    --mount=type=cache,id=${TARGETPLATFORM}-/var/lib/apt,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    set -eux; \
    # Update apt
    apt-get update; \
    # Install builder dependencies for node-gyp, ruby gem native extensions
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gcc \
        git \
        g++ \
        make \
        python3 \
    ;

########################################################################################################################
FROM builder-base as bundle-installer
ARG TARGETPLATFORM

ADD Gemfile* ${MASTODON_HOME}/

RUN \
    --mount=type=cache,id=${TARGETPLATFORM}-/var/cache,target=/var/cache,sharing=locked \
    --mount=type=cache,id=${TARGETPLATFORM}-/var/lib/apt,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    set -eux; \
    # Update apt
    apt-get update; \
    # Install ruby gems dependencies
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libicu-dev \
        libidn-dev \
        libpq-dev \
    ;

RUN set -eux; \
    # Install gems
    bundle install --no-cache;

########################################################################################################################
FROM builder-base as yarn-installer

ADD package.json yarn.lock ${MASTODON_HOME}/

RUN set -eux; \
    # Download and install yarn packages
    case "${NODE_ENV}" in \
        production) yarn install --frozen-lockfile --network-timeout 600000;; \
        *) yarn install --network-timeout 600000;; \
    esac; \
    yarn cache clean --all; \
    # Remove tmp files from node
    rm -rf .yarn* /tmp/* /usr/local/share/.cache;

########################################################################################################################
FROM base
ARG RAILS_SERVE_STATIC_FILES
ARG BIND
ARG MASTODON_VERSION_PRERELEASE
ARG MASTODON_VERSION_METADATA

# Copy the git source code into the image layer
COPY --link . ${MASTODON_HOME}

# Copy output of the "bundle install" build stage into this layer
COPY --link --from=bundle-installer ${MASTODON_HOME}/vendor/bundle ${MASTODON_HOME}/vendor/bundle

# Copy output of the "yarn install" build stage into this image layer
COPY --link --from=yarn-installer ${MASTODON_HOME}/node_modules ${MASTODON_HOME}/node_modules

# Run commands before the mastodon user used
RUN set -eux; \
    # Create some dirs as 1777
    mkdir -p ${MASTODON_HOME}/tmp && chmod 1777 ${MASTODON_HOME}/tmp; \
    mkdir -p ${MASTODON_HOME}/log && chmod 1777 ${MASTODON_HOME}/log; \
    mkdir -p ${MASTODON_HOME}/public && chmod 1777 ${MASTODON_HOME}/public; \
    mkdir -p ${MASTODON_HOME}/public/assets && chmod 1777 ${MASTODON_HOME}/public/assets; \
    mkdir -p ${MASTODON_HOME}/public/packs && chmod 1777 ${MASTODON_HOME}/public/packs; \
    mkdir -p ${MASTODON_HOME}/public/system && chmod 1777 ${MASTODON_HOME}/public/system;

# Set runtime envs
ENV PATH="${PATH}:${MASTODON_HOME}/bin" \
    LD_PRELOAD="libjemalloc.so.2" \
    RAILS_SERVE_STATIC_FILES="${RAILS_SERVE_STATIC_FILES}" \
    BIND="${BIND}" \
    MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
    MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}"

# Use the mastodon user from here on out
USER mastodon

RUN set -eux; \
    # Precompile assets
    OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile; \
    # Remove tmp files from assets:precompile
    rm -rf /tmp/* tmp/* log/* .cache/*;

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 3000 4000
