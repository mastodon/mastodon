# syntax=docker/dockerfile:1.4
FROM ghcr.io/mastodon/mastodon:v4.1.14

WORKDIR /opt/mastodon
COPY . .

RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle config set silence_root_warning true && \
    bundle install -j"$(nproc)"

COPY --chown=mastodon:mastodon . /opt/mastodon

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" \
    BIND="0.0.0.0"

# Set the run user
USER mastodon
WORKDIR /opt/mastodon

# Precompile assets
RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile && \
    yarn cache clean

# Set the work dir and the container entry point
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000 4000
