FROM ruby:2.4.1-alpine

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="A GNU Social-compatible microblogging server"

ENV RAILS_ENV=production \
    NODE_ENV=production

EXPOSE 3000 4000

WORKDIR /mastodon

COPY Gemfile Gemfile.lock package.json yarn.lock /mastodon/

RUN echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
 && BUILD_DEPS=" \
    postgresql-dev \
    libxml2-dev \
    libxslt-dev \
    python \
    build-base" \
 && apk -U upgrade && apk add \
    $BUILD_DEPS \
    nodejs@edge \
    nodejs-npm@edge \
    libpq \
    libxml2 \
    libxslt \
    ffmpeg \
    file \
    imagemagick@edge \
    ca-certificates \
 && npm install -g npm@3 && npm install -g yarn \
 && bundle install --deployment --without test development \
 && yarn --ignore-optional \
 && yarn cache clean \
 && npm -g cache clean \
 && update-ca-certificates \
 && apk del $BUILD_DEPS \
 && rm -rf /tmp/* /var/cache/apk/*

COPY . /mastodon

VOLUME /mastodon/public/system /mastodon/public/assets
