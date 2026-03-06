# For details, see https://github.com/rails/devcontainer/tree/main/images/ruby/.devcontainer
FROM ghcr.io/rails/devcontainer/images/ruby:2.2.2-3.4.8

# Install additional OS packages
RUN sudo apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get -y install --no-install-recommends libicu-dev libidn11-dev ffmpeg libvips42 libpam-dev

# Disable download prompt for Corepack
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

# Move welcome message to where VS Code expects it
COPY .devcontainer/welcome-message.txt /usr/local/etc/vscode-dev-containers/first-run-notice.txt
