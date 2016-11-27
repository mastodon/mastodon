#!/bin/bash

set -e

# Environment variables
export REDIS_HOST=localhost
export REDIS_PORT=6379
export DB_HOST=localhost
export DB_USER=postgres
export DB_DEV_NAME=postgres
export DB_PASS=postgres
export DB_PORT=5432

# Federation
export LOCAL_DOMAIN=localhost
export LOCAL_HTTPS=false

# Application secrets
if [ ! -f .secret.paperclip ]; then
  echo "$(rake secret)" > .secret.paperclip
fi
if [ ! -f .secret.keybase ]; then
  echo "$(rake secret)" > .secret.keybase
fi
export PAPERCLIP_SECRET=$(<.secret.paperclip)
export SECRET_KEY_BASE=$(<.secret.keybase)

# E-mail configuration
export SMTP_SERVER=smtp.mailgun.org
export SMTP_PORT=587
export SMTP_LOGIN=
export SMTP_PASSWORD=
export SMTP_FROM_ADDRESS=notifications@example.com

# Set the rails environment to development.
export RAILS_ENV=development

# Install dependencies
#bundle install

# Upgrade database
rails db:migrate

# Compile assets
#rails assets:precompile

# Run web server
rails server