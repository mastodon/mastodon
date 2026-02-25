# syntax=docker/dockerfile:1.18

# This file is designed for production server deployment, not local development work
# For a containerized local dev environment, see: https://github.com/mastodon/mastodon/blob/main/docs/DEVELOPMENT.md#docker

# Please see https://docs.docker.com/engine/reference/builder for information about
# the extended buildx capabilities used in this file.
# Make sure multiarch TARGETPLATFORM is available for interpolation
# See: https://docs.docker.com/build/building/multi-platform/
ARG TARGETPLATFORM=${TARGETPLATFORM}
ARG BUILDPLATFORM=${BUILDPLATFORM}
ARG BASE_REGISTRY="docker.io"

# Ruby image to use for base image, change with [--build-arg RUBY_VERSION="3.4.x"]
# renovate: datasource=docker depName=docker.io/ruby
ARG RUBY_VERSION="3.4.8"
# # Node.js version to use in base image, change with [--build-arg NODE_MAJOR_VERSION="22"]
# renovate: datasource=node-version depName=node
ARG NODE_MAJOR_VERSION="24"
# Debian image to use for base image, change with [--build-arg DEBIAN_VERSION="trixie"]
ARG DEBIAN_VERSION="trixie"
# Node.js image to use for base image based on combined variables (ex: 20-trixie-slim)
FROM ${BASE_REGISTRY}/node:${NODE_MAJOR_VERSION}-${DEBIAN_VERSION}-slim AS node
# Ruby image to use for base image based on combined variables (ex: 3.4.x-slim-trixie)
FROM ${BASE_REGISTRY}/ruby:${RUBY_VERSION}-slim-${DEBIAN_VERSION} AS ruby

# Resulting version string is vX.X.X-MASTODON_VERSION_PRERELEASE+MASTODON_VERSION_METADATA
# Example: v4.3.0-nightly.2023.11.09+pr-123456
# Overwrite existence of 'alpha.X' in version.rb [--build-arg MASTODON_VERSION_PRERELEASE="nightly.2023.11.09"]
ARG MASTODON_VERSION_PRERELEASE=""
# Append build metadata or fork information to version.rb [--build-arg MASTODON_VERSION_METADATA="pr-123456"]
ARG MASTODON_VERSION_METADATA=""
# Will be available as Mastodon::Version.source_commit
ARG SOURCE_COMMIT=""

# Allow Ruby on Rails to serve static files
# See: https://docs.joinmastodon.org/admin/config/#rails_serve_static_files
ARG RAILS_SERVE_STATIC_FILES="true"
# Allow to use YJIT compiler
# See: https://github.com/ruby/ruby/blob/v3_2_4/doc/yjit/yjit.md
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
  SOURCE_COMMIT="${SOURCE_COMMIT}" \
  # Apply Mastodon static files and YJIT options
  RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES} \
  RUBY_YJIT_ENABLE=${RUBY_YJIT_ENABLE} \
  # Apply timezone
  TZ=${TZ}

ENV \
  # Configure the IP to bind Mastodon to when serving traffic
  BIND="0.0.0.0" \
  # Use production settings for Yarn, Node.js and related tools
  NODE_ENV="production" \
  # Use production settings for Ruby on Rails
  RAILS_ENV="production" \
  # Add Ruby and Mastodon installation to the PATH
  DEBIAN_FRONTEND="noninteractive" \
  PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin" \
  # Optimize jemalloc 5.x performance
  MALLOC_CONF="narenas:2,background_thread:true,thp:never,dirty_decay_ms:1000,muzzy_decay_ms:0" \
  # Sidekiq will touch tmp/sidekiq_process_has_started_and_will_begin_processing_jobs to indicate it is ready. This can be used for a readiness check in Kubernetes
  MASTODON_SIDEKIQ_READY_FILENAME=sidekiq_process_has_started_and_will_begin_processing_jobs

# Set default shell used for running commands
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]

ARG TARGETPLATFORM

RUN echo "Target platform is $TARGETPLATFORM"

RUN \
  # Remove automatic apt cache Docker cleanup scripts
  rm -f /etc/apt/apt.conf.d/docker-clean; \
  # Sets timezone
  echo "${TZ}" > /etc/localtime; \
  # Creates mastodon user/group and sets home directory
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon; \
  # Creates /mastodon symlink to /opt/mastodon
  ln -s /opt/mastodon /mastodon;

# Set /opt/mastodon as working directory
WORKDIR /opt/mastodon

# hadolint ignore=DL3008,DL3005
RUN \
  # Mount Apt cache and lib directories from Docker buildx caches
  --mount=type=cache,id=apt-cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt-lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  # Apt update & upgrade to check for security updates to Debian image
  apt-get update; \
  apt-get dist-upgrade -yq; \
  # Install jemalloc, curl and other necessary components
  apt-get install -y --no-install-recommends \
  curl \
  file \
  libjemalloc2 \
  patchelf \
  procps \
  tini \
  tzdata \
  wget \
  ; \
  # Patch Ruby to use jemalloc
  patchelf --add-needed libjemalloc.so.2 /usr/local/bin/ruby; \
  # Discard patchelf after use
  apt-get purge -y \
  patchelf \
  ;

# Create temporary build layer from base image
FROM ruby AS build

ARG TARGETPLATFORM

# hadolint ignore=DL3008
RUN \
  # Mount Apt cache and lib directories from Docker buildx caches
  --mount=type=cache,id=apt-cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt-lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  # Install build tools and bundler dependencies from APT
  apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  cmake \
  git \
  libgdbm-dev \
  libglib2.0-dev \
  libgmp-dev \
  libicu-dev \
  libidn-dev \
  libpq-dev \
  libssl-dev \
  libtool \
  libyaml-dev \
  meson \
  nasm \
  pkg-config \
  shared-mime-info \
  xz-utils \
  # libvips components
  libcgif-dev \
  libexif-dev \
  libexpat1-dev \
  libgirepository1.0-dev \
  libheif-dev \
  libhwy-dev \
  libimagequant-dev \
  libjpeg62-turbo-dev \
  liblcms2-dev \
  libspng-dev \
  libtiff-dev \
  libwebp-dev \
  # ffmpeg components
  libdav1d-dev \
  liblzma-dev \
  libmp3lame-dev \
  libopus-dev \
  libsnappy-dev \
  libvorbis-dev \
  libvpx-dev \
  libx264-dev \
  libx265-dev \
  ;

# Create temporary libvips specific build layer from build layer
FROM build AS libvips

# libvips version to compile, change with [--build-arg VIPS_VERSION="8.15.2"]
# renovate: datasource=github-releases depName=libvips packageName=libvips/libvips
ARG VIPS_VERSION=8.18.0
# libvips download URL, change with [--build-arg VIPS_URL="https://github.com/libvips/libvips/releases/download"]
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download

WORKDIR /usr/local/libvips/src
# Download and extract libvips source code
ADD ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz /usr/local/libvips/src/
RUN tar xf vips-${VIPS_VERSION}.tar.xz;

WORKDIR /usr/local/libvips/src/vips-${VIPS_VERSION}

# Configure and compile libvips
RUN \
  meson setup build --prefix /usr/local/libvips --libdir=lib -Ddeprecated=false -Dintrospection=disabled -Dmodules=disabled -Dexamples=false; \
  cd build; \
  ninja; \
  ninja install;

# Create temporary ffmpeg specific build layer from build layer
FROM build AS ffmpeg

# ffmpeg version to compile, change with [--build-arg FFMPEG_VERSION="7.0.x"]
# renovate: datasource=repology depName=ffmpeg packageName=openpkg_current/ffmpeg
ARG FFMPEG_VERSION=8.0
# ffmpeg download URL, change with [--build-arg FFMPEG_URL="https://ffmpeg.org/releases"]
ARG FFMPEG_URL=https://github.com/FFmpeg/FFmpeg/archive/refs/tags

WORKDIR /usr/local/ffmpeg/src
# Download and extract ffmpeg source code
ADD ${FFMPEG_URL}/n${FFMPEG_VERSION}.tar.gz /usr/local/ffmpeg/src/
RUN tar xf n${FFMPEG_VERSION}.tar.gz && mv FFmpeg-n${FFMPEG_VERSION} ffmpeg-${FFMPEG_VERSION};

WORKDIR /usr/local/ffmpeg/src/ffmpeg-${FFMPEG_VERSION}

# Configure and compile ffmpeg
RUN \
  ./configure \
  --prefix=/usr/local/ffmpeg \
  --toolchain=hardened \
  --disable-debug \
  --disable-devices \
  --disable-doc \
  --disable-ffplay \
  --disable-network \
  --disable-static \
  --enable-ffmpeg \
  --enable-ffprobe \
  --enable-gpl \
  --enable-libdav1d \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsnappy \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libx264 \
  --enable-libx265 \
  --enable-shared \
  --enable-version3 \
  ; \
  make -j$(nproc); \
  make install;

# Create temporary bundler specific build layer from build layer
FROM build AS bundler

ARG TARGETPLATFORM

# Copy Gemfile config into working directory
COPY Gemfile* /opt/mastodon/

RUN \
  # Mount Ruby Gem caches
  --mount=type=cache,id=gem-cache-${TARGETPLATFORM},target=/usr/local/bundle/cache/,sharing=locked \
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

# Create temporary assets build layer from build layer
FROM build AS precompiler

ARG TARGETPLATFORM

# Copy Mastodon sources into layer
COPY . /opt/mastodon/

# Copy Node.js binaries/libraries into layer
COPY --from=node /usr/local/bin /usr/local/bin
COPY --from=node /usr/local/lib /usr/local/lib

RUN \
  # Configure Corepack
  rm /usr/local/bin/yarn*; \
  corepack enable; \
  corepack prepare --activate;

# hadolint ignore=DL3008
RUN \
  --mount=type=cache,id=corepack-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/corepack,sharing=locked \
  --mount=type=cache,id=yarn-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/yarn,sharing=locked \
  # Install Node.js packages
  yarn workspaces focus --production @mastodon/mastodon;

# Copy libvips components into layer for precompiler
COPY --from=libvips /usr/local/libvips/bin /usr/local/bin
COPY --from=libvips /usr/local/libvips/lib /usr/local/lib
# Copy bundler packages into layer for precompiler
COPY --from=bundler /opt/mastodon /opt/mastodon/
COPY --from=bundler /usr/local/bundle/ /usr/local/bundle/

RUN \
  ldconfig; \
  # Use Ruby on Rails to create Mastodon assets
  SECRET_KEY_BASE_DUMMY=1 \
  bundle exec rails assets:precompile; \
  # Cleanup temporary files
  rm -fr /opt/mastodon/tmp;

# Prep final Mastodon Ruby layer
FROM ruby AS mastodon

ARG TARGETPLATFORM

# hadolint ignore=DL3008
RUN \
  # Mount Apt cache and lib directories from Docker buildx caches
  --mount=type=cache,id=apt-cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt-lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  # Mount Corepack and Yarn caches from Docker buildx caches
  --mount=type=cache,id=corepack-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/corepack,sharing=locked \
  --mount=type=cache,id=yarn-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/yarn,sharing=locked \
  # Apt update install non-dev versions of necessary components
  apt-get install -y --no-install-recommends \
  libexpat1 \
  libglib2.0-0t64 \
  libicu76 \
  libidn12 \
  libpq5 \
  libreadline8t64 \
  libssl3t64 \
  libyaml-0-2 \
  # libvips components
  libcgif0 \
  libexif12 \
  libheif1 \
  libhwy1t64 \
  libimagequant0 \
  libjpeg62-turbo \
  liblcms2-2 \
  libspng0 \
  libtiff6 \
  libwebp7 \
  libwebpdemux2 \
  libwebpmux3 \
  # ffmpeg components
  libdav1d7 \
  libmp3lame0 \
  libopencore-amrnb0 \
  libopencore-amrwb0 \
  libopus0 \
  libsnappy1v5 \
  libtheora0 \
  libvorbis0a \
  libvorbisenc2 \
  libvorbisfile3 \
  libvpx9 \
  libx264-164 \
  libx265-215 \
  ;

# Copy Mastodon sources into final layer
COPY . /opt/mastodon/

# Copy compiled assets to layer
COPY --from=precompiler /opt/mastodon/public/packs /opt/mastodon/public/packs
COPY --from=precompiler /opt/mastodon/public/assets /opt/mastodon/public/assets
# Copy bundler components to layer
COPY --from=bundler /usr/local/bundle/ /usr/local/bundle/
# Copy libvips components to layer
COPY --from=libvips /usr/local/libvips/bin /usr/local/bin
COPY --from=libvips /usr/local/libvips/lib /usr/local/lib
# Copy ffpmeg components to layer
COPY --from=ffmpeg /usr/local/ffmpeg/bin /usr/local/bin
COPY --from=ffmpeg /usr/local/ffmpeg/lib /usr/local/lib

RUN \
  ldconfig; \
  # Smoketest media processors
  vips -v; \
  ffmpeg -version; \
  ffprobe -version;

RUN \
  # Precompile bootsnap code for faster Rails startup
  bundle exec bootsnap precompile --gemfile app/ lib/;

RUN \
  # Pre-create and chown system volume to Mastodon user
  mkdir -p /opt/mastodon/public/system; \
  chown mastodon:mastodon /opt/mastodon/public/system; \
  # Set Mastodon user as owner of tmp folder
  chown -R mastodon:mastodon /opt/mastodon/tmp;

# Set the running user for resulting container
USER mastodon
# Expose default Puma ports
EXPOSE 3000
# Set container tini as default entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
