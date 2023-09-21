# syntax=docker/dockerfile:1.4
# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# See: https://github.com/hadolint/hadolint/wiki/DL3008
# hadolint global ignore=DL3008,DL3009

# Ruby version to use, change with [--build-arg RUBY_VERSION=]
ARG RUBY_VERSION="3.2.2"

# Node version to use, change with [--build-arg NODE_VERSION=]
ARG NODE_VERSION="20.6.0"

# FFmpeg version to use, change with [--build-arg FFMPEG_VERSION=]
ARG FFMPEG_VERSION="6.0"

# ImageMagick version to use, change with [--build-arg IMAGEMAGICK_VERSION=]
ARG IMAGEMAGICK_VERSION="7.1.1-17"

# Image variant to use for ruby and node, change with [--build-arg IMAGE_VARIANT=]
ARG IMAGE_VARIANT="bookworm"

# Image variant to use for ruby, change with [--build-arg RUBY_IMAGE_VARIANT=]
ARG RUBY_IMAGE_VARIANT="slim-${IMAGE_VARIANT}"

# Image variant to use for node, change with [--build-arg NODE_IMAGE_VARIANT=]
ARG NODE_IMAGE_VARIANT="${IMAGE_VARIANT}-slim"

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
FROM node:${NODE_VERSION}-${NODE_IMAGE_VARIANT} as node

########################################################################################################################
FROM ruby:${RUBY_VERSION}-${RUBY_IMAGE_VARIANT} as base
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
        # Dependencies for all
        tzdata \
        wget \
        # Dependencies for ruby gems
        libicu72 \
        libidn12 \
        libpq5 \
        # Dependencies for nodejs
        libatomic1 \
        # Dependencies for FFmpeg
        libaom3 \
        libdav1d6 \
        libdrm2 \
        libmp3lame0 \
        libnuma1 \
        libopus0 \
        libva-drm2 \
        libvorbis0a \
        libvorbisenc2 \
        libvorbisfile3 \
        libvpx7 \
        libx264-164 \
        libx265-199 \
        zlib1g \
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
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        nasm \
        pkg-config \
        xz-utils \
    ;

########################################################################################################################
FROM builder-base as ruby-builder

ADD Gemfile* /opt/mastodon/

RUN set -eux; \
    # Install ruby gems dependencies
    apt-get install -y --no-install-recommends \
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
FROM builder-base as imagemagick-builder
ARG IMAGEMAGICK_VERSION

RUN set -eux; \
    apt-get install -y --no-install-recommends \
        libltdl-dev \
    ; \
    imagemagick_workdir="$(mktemp -d)"; \
    imagemagick_prefix="/opt/magick"; \
    cd ${imagemagick_workdir}; \
    git clone -b ${IMAGEMAGICK_VERSION} --depth 1 https://github.com/ImageMagick/ImageMagick.git .; \
    LDFLAGS="-Wl,-rpath,'$$ORIGIN/../lib'" ./configure \
        --prefix="${imagemagick_prefix}" \
        # Optional Features
        --disable-openmp \
        --enable-shared \
        --disable-static \
        --disable-docs \
        # Optional Packages
        --without-x \
    ; \
    make -j$(nproc); \
    make install; \
    rm -r \
        "${imagemagick_prefix}/include" \
        "${imagemagick_prefix}/lib/pkgconfig" \
        "${imagemagick_prefix}/share" \
    ;

########################################################################################################################
FROM builder-base as ffmpeg-builder
ARG FFMPEG_VERSION

RUN set -eux; \
    apt-get install -y --no-install-recommends \
        libaom-dev \
        libdav1d-dev \
        libdrm-dev \
        libmp3lame-dev \
        libnuma-dev \
        libopus-dev \
        libva-dev \
        libvorbis-dev \
        libvpx-dev \
        libx264-dev \
        libx265-dev \
        zlib1g-dev \
    ; \
    ffmpeg_workdir="$(mktemp -d)"; \
    ffmpeg_prefix="/opt/ffmpeg"; \
    cd ${ffmpeg_workdir}; \
    wget -q https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz; \
    tar -xJf ffmpeg-${FFMPEG_VERSION}.tar.xz --strip-components=1; \
    ./configure \
        --prefix="${ffmpeg_prefix}" \
        --enable-rpath \
        --enable-gpl \
        --enable-version3 \
        --enable-nonfree \
        --disable-static \
        --enable-shared \
        # Program Options
        --disable-programs \
        --enable-ffmpeg \
        --enable-ffprobe \
        # Documentation Options
        --disable-doc \
        # Component Options
        --disable-network \
        --disable-bsfs \
        --disable-filters \
        # External Library Support
        --enable-libaom \
        --enable-libdav1d \
        --enable-libdrm \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-vaapi \
    ; \
    make -j$(nproc); \
    make install; \
    rm -r \
        "${ffmpeg_prefix}/include" \
        "${ffmpeg_prefix}/lib/pkgconfig" \
        "${ffmpeg_prefix}/share" \
    ;

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
    # Install runtime-only dependencies
    apt-get install -y --no-install-recommends \
        file \
        libjemalloc2 \
        tini \
    ; \
    # Remove /var/lib/apt/lists as cache
    rm -rf /var/lib/apt/lists/*;

# [1/5] Copy the git source code into the image layer
COPY --link . /opt/mastodon
# [2/5] Copy output of the "bundle install" build stage into this layer
COPY --link --from=ruby-builder /opt/mastodon/vendor/bundle /opt/mastodon/vendor/bundle
# [3/5] Copy output of the "yarn install" build stage into this image layer
COPY --link --from=node-builder /opt/mastodon/node_modules /opt/mastodon/node_modules
# [4/5] Copy output of the imagemagick-builder into this image layer
COPY --link --from=imagemagick-builder /opt/magick /opt/magick
RUN set -eux; \
    ln -s /opt/magick/bin/* /usr/local/bin/; \
    # smoke tests for magick
    magick -version;

# [5/5] Copy output of the ffmpeg-builder into this image layer
COPY --link --from=ffmpeg-builder /opt/ffmpeg /opt/ffmpeg
RUN set -eux; \
    ln -s /opt/ffmpeg/bin/* /usr/local/bin/; \
    # smoke tests for ffmpeg, ffprobe
    ffmpeg -version; \
    ffprobe -version;

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
    # Remove tmp files from assets:precompile
    rm -rf /tmp/* tmp/* .cache;

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 3000 4000
