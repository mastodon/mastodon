# frozen_string_literal: true

lock '3.8.1'

set :repo_url, ENV.fetch('REPO', 'https://github.com/tootsuite/mastodon.git')
set :branch, ENV.fetch('BRANCH', 'master')

set :application, 'mastodon'
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip
set :migration_role, :app

append :linked_files, '.env.production', 'public/robots.txt'
append :linked_dirs, 'vendor/bundle', 'node_modules', 'public/system'

set :assets_prefix, 'packs'
set :assets_dependencies, %w(app/javascripts package.json yarn.lock config/environments/production.rb config/webpack)
