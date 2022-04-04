FROM ubuntu:20.04 as build-dep

# Use bash for the shell
SHELL ["/bin/bash", "-c"]

# Install build stage deps
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo "Etc/UTC" > /etc/localtime && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
	# Generic OS
	apt-utils \
	ca-certificates \
	python3 \
	wget \
	# Generic Build
	bison \
	build-essential \
	git \
	# Ruby Build
	libffi-dev \
	libgdbm-dev \
	libicu-dev \
	libidn11-dev \
	libjemalloc-dev \
	libncurses5-dev \
	libpq-dev \
	libreadline-dev \
	libssl-dev \
	libyaml-dev \
	shared-mime-info \
	zlib1g-dev \
	&& \
	rm -rf /var/cache/* && \
	rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/ruby/bin:/opt/node/bin:/opt/mastodon/bin:${PATH}"

# Install Node v16 (LTS)
ENV NODE_VER="16.14.2"
RUN ARCH= && \
    dpkgArch="$(dpkg --print-architecture)" && \
  case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac && \
	cd ~ && \
	wget -q https://nodejs.org/download/release/v$NODE_VER/node-v$NODE_VER-linux-$ARCH.tar.gz && \
	tar xf node-v$NODE_VER-linux-$ARCH.tar.gz && \
	rm node-v$NODE_VER-linux-$ARCH.tar.gz && \
	mv node-v$NODE_VER-linux-$ARCH /opt/node

# Install Ruby 3.0
ENV RUBY_VER="3.0.3"
RUN cd ~ && \
	wget https://cache.ruby-lang.org/pub/ruby/${RUBY_VER%.*}/ruby-$RUBY_VER.tar.gz && \
	tar xf ruby-$RUBY_VER.tar.gz && \
	cd ruby-$RUBY_VER && \
	./configure --prefix=/opt/ruby \
	  --with-jemalloc \
	  --with-shared \
	  --disable-install-doc && \
	make -j"$(nproc)" > /dev/null && \
	make install && \
	rm -rf ../ruby-$RUBY_VER.tar.gz ../ruby-$RUBY_VER

RUN npm install -g npm@latest && \
	npm install -g yarn && \
	gem install bundler

COPY Gemfile* package.json yarn.lock /opt/mastodon/

RUN cd /opt/mastodon && \
	bundle config set --local deployment 'true' && \
	bundle config set --local without 'development test' && \
	bundle config set silence_root_warning true && \
	bundle install -j"$(nproc)" && \
	yarn install --pure-lockfile

COPY . /opt/mastodon/
RUN cd /opt/mastodon && \
	RAILS_ENV=production NODE_ENV="production" \
	OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder \
	rails assets:precompile && \
	yarn cache clean && \
	rm -rf tmp

# Build runtime stage
FROM ubuntu:20.04

# Add more PATHs to the PATH
ENV PATH="/opt/ruby/bin:/opt/node/bin:/opt/mastodon/bin:${PATH}"

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create the mastodon user
ARG UID=991
ARG GID=991

# Install mastodon runtime deps
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo "Etc/UTC" > /etc/localtime && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
	# Generic OS
	apt-utils \
	ca-certificates \
	file \
	tini \
	tzdata \
	wget \
	whois \
	# Mastodon Runtime
	ffmpeg \
	imagemagick \
	libicu66 \
	libidn11 \
	libjemalloc2 \
	libpq5 \
	libprotobuf17 \
	libreadline8 \
	libssl1.1 \
	libyaml-0-2 \
	&& \
	addgroup --gid $GID mastodon && \
	useradd -m -u $UID -g $GID -d /opt/mastodon mastodon && \
	ln -s /opt/mastodon /mastodon && \
	echo "mastodon:$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -s -m sha-256)" | chpasswd && \
	rm -rf /var/cache && \
	rm -rf /var/lib/apt/lists/*

# Copy over mastodon source, and dependencies from building, and set permissions
COPY --from=build-dep /opt/node /opt/node
COPY --from=build-dep /opt/ruby /opt/ruby
COPY --from=build-dep --chown=mastodon:mastodon /opt/mastodon /opt/mastodon

# Run mastodon services in prod mode
ENV RAILS_ENV="production"
ENV NODE_ENV="production"

# Tell rails to serve static files
ENV RAILS_SERVE_STATIC_FILES="true"
ENV BIND="0.0.0.0"

# Set the run user
USER mastodon

# Set the work dir and the container entry point
WORKDIR /opt/mastodon
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000 4000
