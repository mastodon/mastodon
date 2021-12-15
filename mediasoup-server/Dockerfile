FROM node:12-buster as build

WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install


FROM ubuntu:20.04 as RUN

SHELL ["/bin/bash", "-c"]

ENV NODE_VER="16.13.0"
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
    echo "Etc/UTC" > /etc/localtime && \
	apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates wget python apt-utils && \
	cd ~ && \
	wget -q https://nodejs.org/download/release/v$NODE_VER/node-v$NODE_VER-linux-$ARCH.tar.gz && \
	tar xf node-v$NODE_VER-linux-$ARCH.tar.gz && \
	rm node-v$NODE_VER-linux-$ARCH.tar.gz && \
	mv node-v$NODE_VER-linux-$ARCH /opt/node

ENV PATH="${PATH}:/opt/node/bin"

WORKDIR /usr/src/app
COPY --from=build /usr/src/app/node_modules ./node_modules

# Bundle app source.
COPY . .

EXPOSE 8000
ENV PORT 8000
ENV HOST 0.0.0.0
CMD ["node", "index.js"]
