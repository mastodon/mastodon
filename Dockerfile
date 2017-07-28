FROM ruby:2.4.1-alpine

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="A GNU Social-compatible microblogging server"

ENV UID=991 GID=991 \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production NODE_ENV=production

EXPOSE 3000 4000

WORKDIR /mastodon

RUN echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
 && echo "@edge https://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    build-base \
    icu-dev \
    libidn-dev \
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
    icu-libs \
    imagemagick@edge \
    libidn \
    libpq \
    libxml2 \
    libxslt \
    nodejs-npm@edge \
    nodejs@edge \
    protobuf \
    su-exec \
    tini \
    yarn@edge \
 && update-ca-certificates \
 && rm -rf /tmp/* /var/cache/apk/*

COPY Gemfile Gemfile.lock package.json yarn.lock /mastodon/

RUN bundle install --deployment --without test development \
 && yarn --ignore-optional --pure-lockfile

COPY . /mastodon

COPY docker_entrypoint.sh /usr/local/bin/run

RUN chmod +x /usr/local/bin/run

VOLUME /mastodon/public/system /mastodon/public/assets /mastodon/public/packs

ENTRYPOINT ["/usr/local/bin/run"]
