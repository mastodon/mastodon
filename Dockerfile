FROM ruby:2.5.0-alpine3.7 as base

ENV RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production NODE_ENV=production

RUN apk -U upgrade \
 && apk add \
    ca-certificates \
    ffmpeg \
    file \
    icu-libs \
    imagemagick \
    libidn \
    libpq \
    nodejs \
    protobuf \
    tini \
    tzdata \
    yarn \
 && update-ca-certificates \
 && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /mastodon

FROM base as builder

ARG LIBICONV_VERSION=1.15
ARG LIBICONV_DOWNLOAD_SHA256=ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178

RUN apk add \
    build-base \
    icu-dev \
    libidn-dev \
    libressl \
    libtool \
    postgresql-dev \
    protobuf-dev \
    python \
 && mkdir -p /tmp/src \
 && wget -O /tmp/libiconv.tar.gz "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$LIBICONV_VERSION.tar.gz" \
 && echo "$LIBICONV_DOWNLOAD_SHA256 */tmp/libiconv.tar.gz" | sha256sum -c - \
 && tar -xzf /tmp/libiconv.tar.gz -C /tmp/src \
 && cd /tmp/src/libiconv-$LIBICONV_VERSION \
 && ./configure --prefix=/usr/local \
 && make -j$(getconf _NPROCESSORS_ONLN) install \
 && make -j$(getconf _NPROCESSORS_ONLN) install DESTDIR=/libiconv

FROM builder as bundler

COPY Gemfile Gemfile.lock /mastodon/

RUN bundle config build.nokogiri --with-iconv-lib=/usr/local/lib --with-iconv-include=/usr/local/include \
 && bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without test development

FROM builder as yarn

COPY package.json yarn.lock .yarnclean /mastodon/

RUN yarn --pure-lockfile

FROM base

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="Your self-hosted, globally interconnected microblogging community"

ARG UID=991
ARG GID=991

EXPOSE 3000 4000

RUN addgroup -g ${GID} mastodon && adduser -h /mastodon -s /bin/sh -D -G mastodon -u ${UID} mastodon \
 && mkdir -p /mastodon/public/system /mastodon/public/assets /mastodon/public/packs \
 && chown -R mastodon:mastodon /mastodon/public

COPY --from=builder /libiconv /
COPY --from=bundler /usr/local/bundle /usr/local/bundle
COPY --from=bundler /mastodon /mastodon
COPY --from=yarn /mastodon/node_modules /mastodon/node_modules
COPY . /mastodon

RUN chown -R mastodon:mastodon /mastodon

VOLUME /mastodon/public/system /mastodon/public/assets /mastodon/public/packs

USER mastodon

ENTRYPOINT ["/sbin/tini", "--"]
