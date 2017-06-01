FROM ruby:2.4.1-alpine

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="A GNU Social-compatible microblogging server"

ENV UID=991 GID=991 \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production NODE_ENV=production

EXPOSE 3000 4000

RUN echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
 && apk add --no-cache \
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
 && update-ca-certificates \
 && npm install -g npm@3 && npm install -g yarn

COPY Gemfile Gemfile.lock package.json yarn.lock /mastodon/
WORKDIR /mastodon

RUN apk add --no-cache -t build-dependencies \
    build-base \
    libxml2-dev \
    libxslt-dev \
    postgresql-dev \
    protobuf-dev \
    python \
 && bundle install --clean --no-cache --deployment --without test development \
 && yarn --ignore-optional --pure-lockfile \
 && apk del --no-cache build-dependencies

COPY . /mastodon

COPY docker_entrypoint.sh /usr/local/bin/run

RUN chmod +x /usr/local/bin/run

VOLUME /mastodon/public/system /mastodon/public/assets /mastodon/public/packs

ENTRYPOINT ["/usr/local/bin/run"]
