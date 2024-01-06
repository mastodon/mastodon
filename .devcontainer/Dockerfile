# For details, see https://github.com/devcontainers/images/tree/main/src/ruby
FROM mcr.microsoft.com/devcontainers/ruby:1-3.2-bullseye

ARG NODE_VERSION="20"
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libicu-dev libidn11-dev ffmpeg imagemagick libpam-dev

RUN gem install foreman

RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && corepack enable" 2>&1

COPY welcome-message.txt /usr/local/etc/vscode-dev-containers/first-run-notice.txt

WORKDIR /mastodon

ENV PATH=/mastodon/bin:${PATH}

RUN su vscode -c "git config --global --add safe.directory /mastodon"
