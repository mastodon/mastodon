FROM ruby:2.4.1-alpine

ENV UID=991 GID=991 \
    RUN_DB_MIGRATIONS=false \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production \
    NODE_ENV=production

WORKDIR /mastodon

RUN echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
 && apk -U add --no-cache \
    ca-certificates \
    ffmpeg \
    file \
    git \
    imagemagick@edge \
    libpq \
    libxml2 \
    libxslt \
    nodejs-npm@edge \
    nodejs@edge \
    protobuf \
    su-exec \
    tini \
 && update-ca-certificates

COPY Gemfile Gemfile.lock package.json yarn.lock /mastodon/

RUN apk -U add --no-cache -t build-dependencies \
    build-base \
    libxml2-dev \
    libxslt-dev \
    postgresql-dev \
    protobuf-dev \
    python \
 && bundle install --deployment --no-cache --without test development \
 && npm install -g npm@3 && npm install -g yarn \
 && yarn --ignore-optional --pure-lockfile \
 && npm -g cache clean && yarn cache clean \
 && apk del build-dependencies

COPY . /mastodon

RUN apk -U add --no-cache -t build-dependencies \
    build-base \
    python \
 && SECRET_KEY_BASE=$(rake secret) rake assets:precompile \
 && mv public/assets /tmp/assets \
 && mv public/packs /tmp/packs \
 && yarn cache clean \
 && apk del build-dependencies \
 && chmod +x docker_entrypoint.sh

VOLUME /mastodon/public/system /mastodon/public/assets /mastodon/public/packs

EXPOSE 3000 4000

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="A GNU Social-compatible microblogging server"

ENTRYPOINT ["/mastodon/docker_entrypoint.sh"]
