FROM ruby:2.3.1-alpine

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="A GNU Social-compatible microblogging server"

ENV RAILS_ENV=production \
    NODE_ENV=production

EXPOSE 3000 4000

WORKDIR /mastodon

COPY Gemfile Gemfile.lock package.json yarn.lock /mastodon/

RUN BUILD_DEPS=" \
    postgresql-dev \
    libxml2-dev \
    libxslt-dev \
    build-base" \
 && apk -U upgrade && apk add \
    $BUILD_DEPS \
    nodejs \
    libpq \
    libxml2 \
    libxslt \
    ffmpeg \
    file \
    imagemagick \
 && npm install -g npm@3 && npm install -g yarn \
 && bundle install --deployment --without test development \
 && yarn \
 && npm cache clean \
 && apk del $BUILD_DEPS \
 && rm -rf /tmp/* /var/cache/apk/*

COPY . /mastodon

VOLUME /mastodon/public/system /mastodon/public/assets
