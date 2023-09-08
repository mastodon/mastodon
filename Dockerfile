# syntax=docker/dockerfile:1.4

ARG TARGETPLATFORM="${TARGETPLATFORM}"
ARG BUILDPLATFORM="${BUILDPLATFORM}"

# Sets baseline for official Ruby container image
ARG RUBY_VERSION="3.2.2"
ARG DEBIAN_VERSION="bookworm"
FROM ruby:${RUBY_VERSION}-slim-${DEBIAN_VERSION}

# Modify these settings here or use build flags [--build-arg ARG_NAME="value"] to change default values
ARG MASTODON_VERSION_PRERELEASE=""
ARG MASTODON_VERSION_METADATA=""
ARG NODE_MAJOR_VERSION="20"
ARG RAILS_SERVE_STATIC_FILES="true"
ARG RUBY_YJIT_ENABLE="0"
ARG DEBIAN_MM_REPO="0"
ARG TZ="Etc/UTC"

# Applied to resulting container image, use ARG above to change these values
ENV \
  MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
  MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}" \
  RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES} \
  RUBY_YJIT_ENABLE=${RUBY_YJIT_ENABLE} \
  TZ=${TZ}

# Static variables
ENV \
  BIND="0.0.0.0" \
  NODE_ENV="production" \
  RAILS_ENV="production" \
  DEBIAN_FRONTEND="noninteractive"

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]

ENV PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin"

# Install build tools and dependencies from APT
RUN \
  echo "${TZ}" > /etc/localtime; \
  apt-get update; \
  apt-get upgrade -y; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    file \
    g++ \
    gcc \
    git \
    gnupg2 \
    libgdbm-dev \
    libgmp-dev \
    libicu-dev \
    libidn-dev \
    libjemalloc2 \
    libpq-dev \
    libssl-dev \
    make \
    procps \
    python3 \
    shared-mime-info \
    tini \
    tzdata \
    wget \
    zlib1g-dev \
  ; \
  wget -nv -O - https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg >/dev/null; \
  wget -nv -O - https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null; \
  echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list; \
  echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list; \
  if [ "${DEBIAN_MM_REPO}" = "1" ]; then \
    wget -nv -O - https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb | dpkg-deb -x - ./ && gpg --dearmor ./etc/apt/trusted.gpg.d/deb-multimedia-keyring.gpg; \
    mv ./etc/apt/trusted.gpg.d/deb-multimedia-keyring.gpg /usr/share/keyrings/deb-multimedia-keyring.gpg >/dev/null; \
    echo "deb [signed-by=/usr/share/keyrings/deb-multimedia-keyring.gpg] https://mirror.csclub.uwaterloo.ca/debian-multimedia/ bookworm main non-free" | tee /etc/apt/sources.list.d/deb-mm.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends imagemagick-7; \
  else \
    apt-get update; \
    apt-get install -y --no-install-recommends imagemagick; \
  fi; \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    nodejs \
    yarn \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

ARG UID="991"
ARG GID="991"
 
RUN \
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon; \
  ln -s /opt/mastodon /mastodon;

WORKDIR /opt/mastodon

RUN bundle config set --global frozen "true"; \
    bundle config set --global cache_all "false"; \
    bundle config set --local without "development test";

COPY --chown=mastodon:mastodon Gemfile* package.json yarn.lock /opt/mastodon/
COPY --chown=mastodon:mastodon . /opt/mastodon

# Perform Ruby Install
RUN bundle install;

# Perform Node Install
RUN \
  yarn install --pure-lockfile --production --network-timeout 600000; \
  yarn cache clean --all;

# Set the running user
USER mastodon

# Use Jemalloc
ENV LD_PRELOAD="libjemalloc.so.2"

# Precompile assets
RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile

# Set container entry point and expose ports
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000 4000