# syntax=docker/dockerfile:1.4

# Please see https://docs.docker.com/engine/reference/builder for information about
# the extended buildx capabilities used in this file.
# Make sure multiarch TARGETPLATFORM is available for interpolation
# See: https://docs.docker.com/build/building/multi-platform/
ARG TARGETPLATFORM="${TARGETPLATFORM}"
ARG BUILDPLATFORM="${BUILDPLATFORM}"

# Node version to use in base image, change with [--build-arg NODE_MAJOR_VERSION="20"]
ARG NODE_MAJOR_VERSION="20"
# Debian image to use for base image, change with [--build-arg DEBIAN_VERSION="bookworm"]
ARG DEBIAN_VERSION="bookworm"
# Node image to use for base image based on combined variables (ex: 20-bookworm-slim)
FROM docker.io/node:${NODE_MAJOR_VERSION}-${DEBIAN_VERSION}-slim as node

# Timezone used by the Docker container and runtime, change with [--build-arg TZ=Europe/Berlin]
ARG TZ="Etc/UTC"
# Linux UID (user id) for the mastodon user, change with [--build-arg UID=1234]
ARG UID="991"
# Linux GID (group id) for the mastodon user, change with [--build-arg GID=1234]
ARG GID="991"

# Configure the IP to bind Mastodon to when serving traffic
ENV BIND="0.0.0.0"

RUN \
# Sets timezone
  echo "${TZ}" > /etc/localtime; \
# Creates mastodon user/group and sets home directory
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon; \
# Creates symlink for /mastodon folder
  ln -s /opt/mastodon /mastodon;

# hadolint ignore=DL3008,DL3005
RUN \
# Apt update & upgrade to check for security updates to Debian image
  apt-get update; \
  apt-get dist-upgrade -yq; \
# Cleanup Apt
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

# Set /opt/mastodon as working directory
WORKDIR /opt/mastodon

# Copy Node package configuration files from build system to container
COPY package.json *yarn* *pnpm* /opt/mastodon/
# Copy Streaming source code from build system to container
COPY ./streaming /opt/mastodon/streaming

RUN \
  rm /usr/local/bin/yarn*; \
  # Configure Corepack
  if [ -e .yarnrc.yml ]; then \
    # Yarn 3 detected
    corepack enable; \
  elif [ -e pnpm-lock.yaml ]; then \
    # NPM detected
    corepack enable; \
    corepack prepare --activate; \
  else \
    # Yarn 1 detected
  	corepack enable; \
    yarn set version classic; \
  fi;

RUN \
# Configure Node package manager
  if [ -e .yarnrc.yml ]; then \
    # Yarn 3 detected
    yarn workspaces focus --all --production; \
    yarn cache clean; \
  elif [ -e pnpm-lock.yaml ]; then \
    # NPM detected
    pnpm install --frozen-lockfile --prod; \
  else \
    # Yarn 1 detected
    yarn install --pure-lockfile --production --network-timeout 600000; \
    yarn cache clean; \
  fi;

# Set the running user for resulting container
USER mastodon
# Expose default Streaming ports
EXPOSE 4000
