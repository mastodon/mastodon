# If you use gems that require environment variables to be set before they are
# loaded, then list `dotenv-rails` in the `Gemfile` before those other gems and
# require `dotenv/rails-now`.
#
#     gem "dotenv-rails", require: "dotenv/rails-now"
#     gem "gem-that-requires-env-variables"
#

require "dotenv/rails"
Dotenv::Railtie.load
