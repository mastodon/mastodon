FROM ruby:2.4.1-alpine

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="A GNU Social-compatible microblogging server"

ARG UID=991 
ARG GID=991

ENV RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production NODE_ENV=production

EXPOSE 3000 4000

WORKDIR /mastodon

RUN echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    build-base \
    libxml2-dev \
    libxslt-dev \
    postgresql-dev \
    protobuf-dev \
    python \
 && apk add \
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
 && npm install -g npm@3 && npm install -g yarn \
 && update-ca-certificates \
 && rm -rf /tmp/* /var/cache/apk/*

COPY Gemfile Gemfile.lock package.json yarn.lock /mastodon/

RUN bundle install --deployment --without test development \
 && yarn --ignore-optional --pure-lockfile

COPY . /mastodon

VOLUME /mastodon/public/system /mastodon/public/assets /mastodon/public/packs

RUN addgroup -g ${GID} mastodon \
 && adduser -h /mastodon -s /bin/sh -D -G mastodon -u ${UID} mastodon \
 && find /mastodon -path /mastodon/public/system -prune -o -not -user mastodon -not -group mastodon -print0 | xargs -0 chown -f mastodon:mastodon

USER mastodon

ENTRYPOINT /sbin/tini -- "$@"
