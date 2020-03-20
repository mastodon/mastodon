FROM ubuntu:18.04 as build-dep

# Use bash for the SHELL
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo "Etc/UTC" > /etc/localtime && \
	apt-get update && \
	apt-get --no-install-recommends -y install apt-utils wget python ca-certificates

# Install Node v12 (LTS)
ENV NODE_VER="12.16.1"
RUN	ARCH= && \
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
	wget https://nodejs.org/download/release/v${NODE_VER}/node-v${NODE_VER}-linux-${ARCH}.tar.gz && \
	tar xf node-v${NODE_VER}-linux-${ARCH}.tar.gz && \
	rm node-v${NODE_VER}-linux-${ARCH}.tar.gz && \
	mv node-v${NODE_VER}-linux-${ARCH} /opt/node

# Install jemalloc
ENV JE_VER="5.2.1"
RUN apt-get --no-install-recommends -y install make autoconf gcc g++ && \
	cd ~ && \
	wget https://github.com/jemalloc/jemalloc/archive/${JE_VER}.tar.gz && \
	tar xf ${JE_VER}.tar.gz && \
	cd jemalloc-${JE_VER} && \
	./autogen.sh && \
	./configure --prefix=/opt/jemalloc && \
	make -j$(nproc) > /dev/null && \
	make install_bin install_include install_lib

# Install Ruby
ENV RUBY_VER="2.6.5"
ENV CPPFLAGS="-I/opt/jemalloc/include"
ENV LDFLAGS="-L/opt/jemalloc/lib/"
RUN apt-get --no-install-recommends -y install build-essential bison libyaml-dev libgdbm-dev libreadline-dev \
	libncurses5-dev libffi-dev zlib1g-dev libssl-dev && \
	cd ~ && \
	wget https://cache.ruby-lang.org/pub/ruby/${RUBY_VER%.*}/ruby-${RUBY_VER}.tar.gz && \
	tar xf ruby-${RUBY_VER}.tar.gz && \
	cd ruby-${RUBY_VER} && \
	./configure --prefix=/opt/ruby \
	--with-jemalloc \
	--with-shared \
	--disable-install-doc && \
	ln -s /opt/jemalloc/lib/* /usr/lib/ && \
	make -j$(nproc) > /dev/null && \
	make install

# Update PATH
ENV PATH="/opt/ruby/bin:/opt/node/bin:${PATH}"

# Install mastodon install deps
RUN npm install -g yarn && \
	gem install bundler && \
	apt-get --no-install-recommends -y install git libicu-dev libidn11-dev libpq-dev libprotobuf-dev protobuf-compiler

COPY Gemfile* package.json yarn.lock /opt/mastodon/

RUN cd /opt/mastodon && \
	bundle config set deployment 'true' && \
	bundle config set without 'development test' && \
	bundle install -j$(nproc) && \
	yarn install --pure-lockfile

##-------------------------------------------------
FROM ubuntu:18.04

# Use bash for the SHELL
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo "Etc/UTC" > /etc/localtime && \
	apt-get update && \
	apt-get --no-install-recommends -y install apt-utils wget whois ca-certificates

# Copy over all the langs needed for runtime
COPY --from=build-dep /opt/node /opt/node
COPY --from=build-dep /opt/ruby /opt/ruby
COPY --from=build-dep /opt/jemalloc /opt/jemalloc
RUN ln -s /opt/jemalloc/lib/* /usr/lib/

# Update PATH
ENV PATH="/opt/ruby/bin:/opt/node/bin:/opt/mastodon/bin:${PATH}"

# Create the mastodon user
ARG UID=991
ARG GID=991
RUN addgroup --gid ${GID} mastodon && \
	useradd -m -u ${UID} -g ${GID} -d /opt/mastodon mastodon && \
	echo "mastodon:$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -s -m sha-256)" | chpasswd

# Install mastodon runtime deps
RUN apt-get --no-install-recommends -y install \
	libssl1.1 libpq5 imagemagick ffmpeg \
	libicu60 libprotobuf10 libidn11 libyaml-0-2 \
	file ca-certificates tzdata libreadline7 gcc && \
	ln -s /opt/mastodon /mastodon && \
	gem install bundler && \
	rm -rf /var/cache && \
	rm -rf /var/lib/apt/lists/*

# Install tini
ENV TINI_VERSION="0.18.0"
ENV TINI_SUM="12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855"
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN echo "${TINI_SUM} tini" | sha256sum -c - && \
	chmod +x /tini

# Copy over mastodon source, and dependencies from building, and set permissions
COPY --chown=mastodon:mastodon . /opt/mastodon
COPY --from=build-dep --chown=mastodon:mastodon /opt/mastodon /opt/mastodon

# Run mastodon services in prod mode
ENV RAILS_ENV="production"
ENV NODE_ENV="production"

# Tell rails to serve static files
ENV RAILS_SERVE_STATIC_FILES="true"
ENV BIND="0.0.0.0"

# Set the run user
USER mastodon

# Precompile assets
RUN cd ~ && \
	OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile && \
	yarn cache clean

# Set the work dir and the container entry point
WORKDIR /opt/mastodon
ENTRYPOINT ["/tini", "--"]
EXPOSE 3000
