FROM ruby:2.3.1-alpine

ENV RAILS_ENV=production \
    NODE_ENV=production

WORKDIR /mastodon

COPY . /mastodon

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
 && gem install tzinfo-data \
 && yarn \
 && npm cache clean \
 && apk del $BUILD_DEPS \
 && rm -rf /tmp/* /var/cache/apk/*

VOLUME /mastodon/public/system /mastodon/public/assets
