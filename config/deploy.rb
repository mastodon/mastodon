lock '3.7.2'

set :application, 'mastodon'
set :repo_url, 'https://github.com/tootsuite/mastodon.git'
set :branch, 'master'
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip
set :migration_role, :app

append :linked_files, '.env.production'
append :linked_dirs, 'vendor/bundle', 'node_modules', 'public/system'
