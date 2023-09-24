# syntax=docker/dockerfile:1.4

# Please see https://docs.docker.com/engine/reference/builder for information about
# the extended buildx capabilities used in this file.
# Make sure multiarch TARGETPLATFORM is available for interpolation
# See: https://docs.docker.com/build/building/multi-platform/
ARG TARGETPLATFORM="${TARGETPLATFORM}"
ARG BUILDPLATFORM="${BUILDPLATFORM}"

# Node version to use in base image, change with [--build-arg NODE_MAJOR_VERSION="20"]
ARG NODE_MAJOR_VERSION="20"
# Node image to use for base image based on combined variables (ex: 20-alpine)
FROM node:${NODE_MAJOR_VERSION}-alpine

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

# APK update & upgrade to check for security updates to Alpine image
RUN \
  apk update; \
  apk upgrade;

### Set /opt/mastodon as working directory ###
WORKDIR /opt/mastodon

### Copy Node package configuration files from build system to container (yarn 1)
COPY package.json yarn.lock /opt/mastodon/
### Copy Node package configuration files from build system to container (yarn 3)
COPY package.json yarn.lock .yarnrc.yml /opt/mastodon/
COPY .yarn /opt/mastodon/.yarn
# Copy Streaming source code from build system to container
COPY ./streaming /opt/mastodon/streaming

RUN \
# Configure yarn to prevent changes to package.json and yarn.lock
# Configure yarn to only process production Node packages
# Download and install required Node packages (yarn 1)
  # yarn install --pure-lockfile --production --network-timeout 600000; \
# Download and install required Node packages (yarn 3)
  yarn workspaces focus --all --production; \
# Cleanup cache of downloaded Node packages
  yarn cache clean --all;

# Set the running user for resulting container
USER mastodon
# Expose default Streaming ports
EXPOSE 4000
