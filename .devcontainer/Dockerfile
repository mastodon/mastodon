# For details, see https://github.com/devcontainers/images/tree/main/src/ruby
FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bookworm

# Install node version from .nvmrc
WORKDIR /app
COPY .nvmrc .
RUN /bin/bash --login -i -c "nvm install"

# Install additional OS packages
# 예: 패키지 설치 시 apt 캐시 mount
RUN \
  --mount=type=cache,id=apt/cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt/lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  apt-get update; \
  apt-get dist-upgrade -yq; \
  apt-get install -y --no-install-recommends \
  curl file libjemalloc2 patchelf procps tini tzdata wget; \
  patchelf --add-needed libjemalloc.so.2 /usr/local/bin/ruby; \
  apt-get purge -y patchelf;

# 예: build layer에서 bundler 실행 시 캐시 적용
RUN \
  --mount=type=cache,id=gem/cache-${TARGETPLATFORM},target=/usr/local/bundle/cache/,sharing=locked \
  bundle config set --global frozen "true"; \
  bundle config set --global cache_all "false"; \
  bundle config set --local without "development test"; \
  bundle install -j"$(nproc)";

# 예: yarn 설치 시 캐시
RUN \
  --mount=type=cache,id=yarn/cache-${TARGETPLATFORM},target=/usr/local/share/.cache/yarn,sharing=locked \
  --mount=type=cache,id=corepack/cache-${TARGETPLATFORM},target=/usr/local/share/.cache/corepack,sharing=locked \
  yarn workspaces focus --production @mastodon/mastodon;

# 예: 최종 서비스 레이어에서도 apt/yarn 캐시 유지
RUN \
  --mount=type=cache,id=apt/cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt/lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  --mount=type=cache,id=corepack/cache-${TARGETPLATFORM},target=/usr/local/share/.cache/corepack,sharing=locked \
  --mount=type=cache,id=yarn/cache-${TARGETPLATFORM},target=/usr/local/share/.cache/yarn,sharing=locked \
  apt-get install -y --no-install-recommends \
  libexpat1 libglib2.0-0 libicu72 libidn12 libpq5 libreadline8 libssl3 libyaml-0-2 \
  libcgif0 libexif12 libheif1/bookworm-backports libimagequant0 libjpeg62-turbo \
  liblcms2-2 liborc-0.4-0 libspng0 libtiff6 libwebp7 libwebpdemux2 libwebpmux3 \
  libdav1d6 libmp3lame0 libopencore-amrnb0 libopencore-amrwb0 libopus0 libsnappy1v5 \
  libtheora0 libvorbis0a libvorbisenc2 libvorbisfile3 libvpx7 libx264-164 libx265-199;
