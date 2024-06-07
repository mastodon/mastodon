# For details, see https://github.com/devcontainers/images/tree/main/src/ruby
FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bookworm

# Install Rails
# RUN gem install rails webdrivers

ARG NODE_VERSION="20"
RUN . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libicu-dev libidn11-dev ffmpeg imagemagick libvips42 libpam-dev

# [Optional] Uncomment this line to install additional gems.
RUN gem install foreman

# [Optional] Uncomment this line to install global node packages.
RUN . /usr/local/share/nvm/nvm.sh && corepack enable 2>&1

COPY welcome-message.txt /usr/local/etc/vscode-dev-containers/first-run-notice.txt
