FROM ruby:2.4.2-alpine3.6

LABEL maintainer="https://github.com/tootsuite/mastodon" \
      description="A GNU Social-compatible microblogging server"

ENV UID=991 GID=991 \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production NODE_ENV=production

ARG YARN_VERSION=1.1.0
ARG YARN_DOWNLOAD_SHA256=171c1f9ee93c488c0d774ac6e9c72649047c3f896277d88d0f805266519430f3
ARG LIBICONV_VERSION=1.15
ARG LIBICONV_DOWNLOAD_SHA256=ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178

EXPOSE 3000 4000

WORKDIR /mastodon

RUN apk -U upgrade \
 && apk add -t build-dependencies \
    build-base \
    icu-dev \
    libidn-dev \
    libressl \
    libtool \
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
    nodejs \
    nodejs-npm \
    protobuf \
    su-exec \
    tini \
 && update-ca-certificates \
 && mkdir -p /tmp/src /opt \
 && wget -O yarn.tar.gz "https://github.com/yarnpkg/yarn/releases/download/v$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
 && echo "$YARN_DOWNLOAD_SHA256 *yarn.tar.gz" | sha256sum -c - \
 && tar -xzf yarn.tar.gz -C /tmp/src \
 && rm yarn.tar.gz \
 && mv /tmp/src/yarn-v$YARN_VERSION /opt/yarn \
 && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
 && wget -O libiconv.tar.gz "http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$LIBICONV_VERSION.tar.gz" \
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

RUN bundle config build.nokogiri --with-iconv-lib=/usr/local/lib --with-iconv-include=/usr/local/include \
 && bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without test development \
 && yarn --pure-lockfile \
 && yarn cache clean

COPY . /mastodon

COPY docker_entrypoint.sh /usr/local/bin/run

RUN chmod +x /usr/local/bin/run

VOLUME /mastodon/public/system /mastodon/public/assets /mastodon/public/packs

ENTRYPOINT ["/usr/local/bin/run"]
