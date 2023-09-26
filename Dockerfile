# syntax=docker/dockerfile:1.4

# Please see https://docs.docker.com/engine/reference/builder for information about
# the extended buildx capabilities used in this file.
# Make sure multiarch TARGETPLATFORM is available for interpolation
# See: https://docs.docker.com/build/building/multi-platform/
ARG TARGETPLATFORM="${TARGETPLATFORM}"
ARG BUILDPLATFORM="${BUILDPLATFORM}"

# Ruby image to use for base image, change with [--build-arg RUBY_VERSION="3.2.2"]
ARG RUBY_VERSION="3.2.2"
# # Node version to use in base image, change with [--build-arg NODE_MAJOR_VERSION="20"]
ARG NODE_MAJOR_VERSION="20"
# Debian image to use for base image, change with [--build-arg DEBIAN_VERSION="bookworm"]
ARG DEBIAN_VERSION="bookworm"
# Node image to use for base image based on combined variables (ex: 20-bookworm-slim)
FROM docker.io/node:${NODE_MAJOR_VERSION}-${DEBIAN_VERSION}-slim as node
# Ruby image to use for base image based on combined variables (ex: 3.2.2-slim-bookworm)
FROM docker.io/ruby:${RUBY_VERSION}-slim-${DEBIAN_VERSION} as ruby

# Resulting version string is vX.X.X-MASTODON_VERSION_PRERELEASE+MASTODON_VERSION_METADATA
# Example: v4.2.0-nightly.2023.11.09+something
# Overwrite existance of 'dev.0' in version.rb [--build-arg MASTODON_VERSION_PRERELEASE="nightly.2023.11.09"]
ARG MASTODON_VERSION_PRERELEASE=""
# Append build metadata or fork information to version.rb [--build-arg MASTODON_VERSION_METADATA="something"]
ARG MASTODON_VERSION_METADATA=""

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

# Apply Mastodon build options based on options above
ENV \
# Apply Mastodon version information
  MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
  MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}" \
# Apply Mastodon static files and YJIT options
  RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES} \
  RUBY_YJIT_ENABLE=${RUBY_YJIT_ENABLE} \
# Apply timezone
  TZ=${TZ}

ENV \
# Configure the IP to bind Mastodon to when serving traffic
  BIND="0.0.0.0" \
# Use production settings for Yarn, Node and related nodejs based tools
  NODE_ENV="production" \
# Use production settings for Ruby on Rails
  RAILS_ENV="production" \
# Add Ruby and Mastodon installation to the PATH
  DEBIAN_FRONTEND="noninteractive" \
  PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin" \
# Optimize jemalloc 5.x performance
  MALLOC_CONF="narenas:2,background_thread:true,thp:never,dirty_decay_ms:1000,muzzy_decay_ms:0"

# Set default shell used for running commands
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]

RUN \
# Sets timezone
  echo "${TZ}" > /etc/localtime; \
# Creates mastodon user/group and sets home directory
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon; \
# Creates /mastodon symlink to /opt/mastodon
  ln -s /opt/mastodon /mastodon;

# Set /opt/mastodon as working directory
WORKDIR /opt/mastodon

# Copy Ruby and Node package configuration files from build system to container
# COPY Gemfile* package.json yarn.lock /opt/mastodon/
COPY . /opt/mastodon/

# hadolint ignore=DL3008,DL3005
RUN \
# Apt update & upgrade to check for security updates to Debian image
  apt-get update; \
  apt-get dist-upgrade -yq; \
# Install jemalloc, curl and other necessary components
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    file \
    libjemalloc2 \
    patchelf \
    procps \
    tini \
    tzdata \
  ; \
# Install ffmpeg for video processing
  apt update; \
  apt-get install -y --no-install-recommends \
    ffmpeg \
  ; \
# Patch Ruby to use jemalloc
  patchelf --add-needed libjemalloc.so.2 /usr/local/bin/ruby; \
# Discard patchelf after use
  apt-get purge -y \
    patchelf \
  ; \
# Cleanup Apt
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

# hadolint ignore=DL3008,DL3005
RUN \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    # Dependencies for ImageMagick
    libbz2-1.0 \
    liblzma5 \
    libheif1 \
    libjxl0.7 \
    libpng16-16 \
    libraw20 \
    libtiff6 \
    libwebp7 \
    libwebpdemux2 \
    libwebpmux3 \
    libzip4 \
  ; \
# Cleanup Apt
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

# Create temporary build layer from base image
FROM ruby as build

# ImageMagick version to use, change with [--build-arg IMAGEMAGICK_VERSION=]
ARG IMAGEMAGICK_VERSION="7.1.1-18"

COPY --from=node /usr/local/bin /usr/local/bin
COPY --from=node /usr/local/lib /usr/local/lib

# hadolint ignore=DL3008
RUN \
# Install build tools and bundler dependencies from APT
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
    shared-mime-info \
    yarn \
    zlib1g-dev \
    # Dependencies for ImageMagick
    libbz2-dev \
    libheif-dev \
    libjxl-dev \
    libltdl-dev \
    liblzma-dev \
    libpng-dev \
    libraw-dev \
    libtiff-dev \
    libwebp-dev \
    libzip-dev \
    zlib1g-dev \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
# Remove existing yarn
  rm /usr/local/bin/yarn*; \
# Set yarn to use classic mode and enable corepack (yarn 1)
	corepack enable; \
  yarn set version classic; \
# Enable corepack (yarn 3)
  # corepack enable; \
  # Configure ImageMagick working directory
  imagemagick_workdir="$(mktemp -d)"; \
  imagemagick_prefix="/opt/magick"; \
  cd ${imagemagick_workdir}; \
  # Clone ImageMagick source code
  git clone -b ${IMAGEMAGICK_VERSION} --depth 1 https://github.com/ImageMagick/ImageMagick.git .; \
  LDFLAGS="-Wl,-rpath,\"\\$\$ORIGIN/../lib\"" ./configure \
      --prefix="${imagemagick_prefix}" \
      # Optional Features
      --disable-openmp \
      --enable-shared \
      --disable-static \
      --disable-deprecated \
      --disable-docs \
      # Optional Packages
      --with-security-policy=websafe \
      --without-magick-plus-plus \
      --without-fontconfig \
      --without-freetype \
  ; \
  # Compile ImageMagick
  make -j"$(nproc)"; \
  make install; \
  rm -r \
      "${imagemagick_prefix}/include" \
      "${imagemagick_prefix}/lib/pkgconfig" \
      "${imagemagick_prefix}/share" \
  ;

# Create temporary bundler specific build layer from build layer
FROM build as build-bundler

RUN \
# Configure bundle to prevent changes to Gemfile and Gemfile.lock
  bundle config set --global frozen "true"; \
# Configure bundle to not cache downloaded Gems
  bundle config set --global cache_all "false"; \
# Configure bundle to only process production Gems
  bundle config set --local without "development test"; \
# Configure bundle to not warn about root user
  bundle config set silence_root_warning "true"; \
# Download and install required Gems
  bundle install -j"$(nproc)";

# Create temporary yarn specific build layer from build layer
FROM build as build-yarn

# hadolint ignore=DL3008
RUN \
# Configure yarn to prevent changes to package.json and yarn.lock
# Configure yarn to only process production Node packages
# Download and install required Node packages (yarn 1)
  yarn install --pure-lockfile --production --network-timeout 600000; \
# Download and install required Node packages (yarn 3)
  # yarn workspaces focus --all --production; \
# Cleanup cache of downloaded Node packages
  yarn cache clean --all;

# Create temporary assets build layer from build layer
FROM build as build-assets

# Copy Mastodon source code to layer
# COPY . /opt/mastodon/
# Copy bundler and node packages from build layer to container
COPY --from=build-bundler /opt/mastodon /opt/mastodon/
COPY --from=build-bundler /usr/local/bundle/ /usr/local/bundle/
COPY --from=build-yarn /opt/mastodon /opt/mastodon/

RUN \
# Use Ruby on Rails to create Mastodon assets
  OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile; \
# Cleanup temporary files
  rm -fr /opt/mastodon/tmp;

# Prep final Mastodon Ruby layer
FROM ruby

# hadolint ignore=DL3008
RUN \
# Apt update install non-dev versions of necessary components
  apt-get update; \
  apt-get install -y --no-install-recommends \
    libssl3 \
    libpq5 \
    libicu72 \
    libidn12 \
    libreadline8 \
    libyaml-0-2 \
  ; \
# Cleanup Apt
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

# Copy Mastodon source code to container
# COPY . /opt/mastodon/
# Copy compiled assets to layer
COPY --from=build-assets /opt/mastodon/public/packs /opt/mastodon/public/packs
COPY --from=build-assets /opt/mastodon/public/assets /opt/mastodon/public/assets
# Copy bundler components to run layer
COPY --from=build-bundler /opt/mastodon/ /opt/mastodon/
COPY --from=build-bundler /usr/local/bundle/ /usr/local/bundle/

# Copy output of the imagemagick into this image layer
COPY --link --from=build /opt/magick /opt/magick

RUN \
  ln -s /opt/magick/bin/* /usr/local/bin/; \
  # Test ImageMagick and ffmpeg availablity
  magick -version; \
  ffmpeg -version; \
  ffprobe -version; \
# Pre-create and chown system volume to Mastodon user
  mkdir -p /opt/mastodon/public/system; \
  chown mastodon:mastodon /opt/mastodon/public/system;

# Set the running user for resulting container
USER mastodon

# Set container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
# Expose default Puma ports
EXPOSE 3000