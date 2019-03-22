FROM node:8.15-alpine as node
FROM ruby:2.6-alpine3.8

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="Your self-hosted, globally interconnected microblogging community"

ARG UID=991
ARG GID=991

ENV PATH=/mastodon/bin:$PATH \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production \
    NODE_ENV=production

ARG LIBICONV_VERSION=1.15
ARG LIBICONV_DOWNLOAD_SHA256=ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178

EXPOSE 3000 4000

WORKDIR /mastodon

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /opt/yarn-* /opt/yarn

RUN apk -U upgrade \
 && apk add -t build-dependencies \
    build-base \
    icu-dev \
    libidn-dev \
    libressl \
    libtool \
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
    imagemagick \
    libidn \
    libpq \
    libxml2 \
    libxslt \
    protobuf \
    tini \
    tzdata \
 && update-ca-certificates \
 && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
 && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg \
 && mkdir -p /tmp/src /opt \
 && wget -O libiconv.tar.gz "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$LIBICONV_VERSION.tar.gz" \
 && echo "$LIBICONV_DOWNLOAD_SHA256 *libiconv.tar.gz" | sha256sum -c - \
 && tar -xzf libiconv.tar.gz -C /tmp/src \
 && rm libiconv.tar.gz \
 && cd /tmp/src/libiconv-$LIBICONV_VERSION \
 && ./configure --prefix=/usr/local \
 && make -j$(getconf _NPROCESSORS_ONLN)\
 && make install \
 && libtool --finish /usr/local/lib \
 && cd /mastodon \
 && rm -rf /tmp/* /var/cache/apk/*

COPY Gemfile Gemfile.lock package.json yarn.lock .yarnclean /mastodon/

RUN bundle config build.nokogiri --use-system-libraries --with-iconv-lib=/usr/local/lib --with-iconv-include=/usr/local/include \
 && bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without test development \
 && yarn install --pure-lockfile --ignore-engines \
 && yarn cache clean

RUN addgroup -g ${GID} mastodon && adduser -h /mastodon -s /bin/sh -D -G mastodon -u ${UID} mastodon \
 && mkdir -p /mastodon/public/system /mastodon/public/assets /mastodon/public/packs \
 && chown -R mastodon:mastodon /mastodon/public

COPY . /mastodon

RUN chown -R mastodon:mastodon /mastodon

VOLUME /mastodon/public/system

USER mastodon

RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile

ENTRYPOINT ["/sbin/tini", "--"]
