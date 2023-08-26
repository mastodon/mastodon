# Ignoring these here since we don't want to pin any versions and the Debian image removes apt-get content after use
# hadolint global ignore=DL3008
FROM ruby:3.2.2-slim-bookworm

RUN set -eux; \
  apt-get update; \
  # Install Runtime dependencies
  apt-get install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    file \
    imagemagick \
    libjemalloc2 \
    procps \
    shared-mime-info \
    tini \
    tzdata \
    wget \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  echo "Etc/UTC" > /etc/localtime;

ARG NODE_MAJOR_VERSION="16"

# Install nodejs & yarn
RUN set -eux; \
  savedAptMark="$(apt-mark showmanual)"; \
  wget -nv -O - https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x | bash -; \
  wget -nv -O - https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null; \
  echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends nodejs=${NODE_MAJOR_VERSION}.\* yarn; \
  rm -rf /var/lib/apt/lists/*; \
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark nodejs yarn > /dev/null; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  node --version; \
  yarn --version;

# Use those args to specify your own version flags & suffixes
ARG MASTODON_VERSION_PRERELEASE=""
ARG MASTODON_VERSION_METADATA=""

ARG UID="991"
ARG GID="991"
 
RUN set -eux; \
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "$UID" -g "${GID}" -m -d /opt/mastodon mastodon; \
  ln -s /opt/mastodon /mastodon;

WORKDIR /opt/mastodon

RUN bundle config set --global frozen "true"; \
    bundle config set --global cache_all "false"; \
    bundle config set --local without "development test";

COPY --chown=mastodon:mastodon Gemfile* package.json yarn.lock /opt/mastodon/

# Intend to word splitting
# hadolint ignore=SC2086
RUN set -eux; \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  # Install build time dependencies (bundle install, yarn install)
  apt-get install -y --no-install-recommends \
    g++ \
    gcc \
    git \
    libicu-dev \
    libidn-dev \
    libpq-dev \
    libgdbm-dev \
    libgmp-dev \
    libssl-dev \
    make \
    python3 \
    zlib1g-dev \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  bundle install; \
  yarn install --immutable --production --network-timeout 600000; \
  yarn cache clean --all; \
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark > /dev/null; \
  find /usr/local /opt/mastodon -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
    | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
    | sort -u \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual \
  ; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

COPY --chown=mastodon:mastodon . /opt/mastodon

# Set the run user
USER mastodon

ENV LD_PRELOAD="libjemalloc.so.2" \
    RAILS_ENV="production" \
    NODE_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" \
    BIND="0.0.0.0" \
    MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
    MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}"

# Precompile assets
RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000 4000
