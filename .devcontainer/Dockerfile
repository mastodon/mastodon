# For details, see https://github.com/devcontainers/images/tree/main/src/ruby
FROM mcr.microsoft.com/devcontainers/ruby:3.4-trixie

# Install node version from .nvmrc
WORKDIR /app
COPY .nvmrc .
RUN /bin/bash --login -i -c "nvm install"

# Install additional OS packages
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install --no-install-recommends libicu-dev libidn11-dev ffmpeg libvips42 libpam-dev

# Disable download prompt for Corepack
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

# Move welcome message to where VS Code expects it
COPY .devcontainer/welcome-message.txt /usr/local/etc/vscode-dev-containers/first-run-notice.txt
