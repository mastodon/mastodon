ARG BASE_TAG

FROM ubuntu:22.04 as patch

RUN apt-get update && \
    apt-get install git -y

COPY . /workdir
WORKDIR /workdir
ARG BASE_TAG
RUN git diff "$BASE_TAG" -- ':!kgtkr.Dockerfile' > kgtkr.diff

FROM tootsuite/mastodon:$BASE_TAG

COPY --from=busybox:1.36-musl --chown=mastodon:mastodon /bin/busybox .
COPY --from=patch --chown=mastodon:mastodon /workdir/kgtkr.diff .

RUN ./busybox patch -p1 < kgtkr.diff
RUN rm ./kgtkr.diff ./busybox
