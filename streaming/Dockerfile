# syntax=docker/dockerfile:1.18

# Please see https://docs.docker.com/engine/reference/builder for information about
# the extended buildx capabilities used in this file.
# Make sure multiarch TARGETPLATFORM is available for interpolation
# See: https://docs.docker.com/build/building/multi-platform/
ARG TARGETPLATFORM=${TARGETPLATFORM}
ARG BUILDPLATFORM=${BUILDPLATFORM}
ARG BASE_REGISTRY="docker.io"

# Node version to use in base image, change with [--build-arg NODE_MAJOR_VERSION="22"]
# renovate: datasource=node-version depName=node
ARG NODE_MAJOR_VERSION="24"
# Debian image to use for base image, change with [--build-arg DEBIAN_VERSION="trixie"]
ARG DEBIAN_VERSION="trixie"
# Node image to use for base image based on combined variables (ex: 20-trixie-slim)
FROM ${BASE_REGISTRY}/node:${NODE_MAJOR_VERSION}-${DEBIAN_VERSION}-slim AS streaming

# Resulting version string is vX.X.X-MASTODON_VERSION_PRERELEASE+MASTODON_VERSION_METADATA
# Example: v4.3.0-nightly.2023.11.09+pr-123456
# Overwrite existence of 'alpha.X' in version.rb [--build-arg MASTODON_VERSION_PRERELEASE="nightly.2023.11.09"]
ARG MASTODON_VERSION_PRERELEASE=""
# Append build metadata or fork information to version.rb [--build-arg MASTODON_VERSION_METADATA="pr-123456"]
ARG MASTODON_VERSION_METADATA=""

# Timezone used by the Docker container and runtime, change with [--build-arg TZ=Europe/Berlin]
ARG TZ="Etc/UTC"
# Linux UID (user id) for the mastodon user, change with [--build-arg UID=1234]
ARG UID="991"
# Linux GID (group id) for the mastodon user, change with [--build-arg GID=1234]
ARG GID="991"

# Apply Mastodon build options based on options above
ENV \
  # Apply Mastodon version information
  MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
  MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}" \
  # Apply timezone
  TZ=${TZ}

ENV \
  # Configure the IP to bind Mastodon to when serving traffic
  BIND="0.0.0.0" \
  # Explicitly set PORT to match the exposed port
  PORT=4000 \
  # Use production settings for Yarn, Node and related nodejs based tools
  NODE_ENV="production" \
  # Add Ruby and Mastodon installation to the PATH
  DEBIAN_FRONTEND="noninteractive"

# Set default shell used for running commands
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]

ARG TARGETPLATFORM

RUN echo "Target platform is ${TARGETPLATFORM}"

RUN \
  # Remove automatic apt cache Docker cleanup scripts
  rm -f /etc/apt/apt.conf.d/docker-clean; \
  # Sets timezone
  echo "${TZ}" > /etc/localtime; \
  # Creates mastodon user/group and sets home directory
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon; \
  # Creates symlink for /mastodon folder
  ln -s /opt/mastodon /mastodon;

# hadolint ignore=DL3008,DL3005
RUN \
  # Mount Apt cache and lib directories from Docker buildx caches
  --mount=type=cache,id=apt-cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt-lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  # Upgrade to check for security updates to Debian image
  apt-get update; \
  apt-get dist-upgrade -yq; \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  tzdata \
  wget \
  ;

# Set /opt/mastodon as working directory
WORKDIR /opt/mastodon

# Copy Node package configuration files from build system to container
COPY package.json yarn.lock .yarnrc.yml /opt/mastodon/
# Copy Streaming source code from build system to container
COPY ./streaming /opt/mastodon/streaming

RUN \
  # Mount local Corepack and Yarn caches from Docker buildx caches
  --mount=type=cache,id=corepack-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/corepack,sharing=locked \
  --mount=type=cache,id=yarn-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/yarn,sharing=locked \
  # Configure Corepack
  rm /usr/local/bin/yarn*; \
  corepack enable; \
  corepack prepare --activate;

RUN \
  # Mount Corepack and Yarn caches from Docker buildx caches
  --mount=type=cache,id=corepack-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/corepack,sharing=locked \
  --mount=type=cache,id=yarn-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/yarn,sharing=locked \
  # Install Node packages
  yarn workspaces focus --production @mastodon/streaming;

# Set the running user for resulting container
USER mastodon
# Expose default Streaming ports
EXPOSE 4000
# Run streaming when started
CMD [ "node", "./streaming/index.js" ]
