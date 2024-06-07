# For details, see https://github.com/devcontainers/images/tree/main/src/ruby
FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bookworm

# Update existing node version, keep in sync with .nvmrc
ARG NODE_VERSION="20"
RUN . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1

# Install additional OS packages
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install --no-install-recommends libicu-dev libidn11-dev ffmpeg imagemagick libvips42 libpam-dev

# Install global node packages
RUN . /usr/local/share/nvm/nvm.sh && corepack enable 2>&1

# Move welcome message to where VS Code expects it
COPY welcome-message.txt /usr/local/etc/vscode-dev-containers/first-run-notice.txt
