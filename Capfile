# frozen_string_literal: true
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'

install_plugin Capistrano::SCM::Git

require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/yarn'
require 'capistrano/rails/assets'
require 'capistrano/faster_assets'
require 'capistrano/rails/migrations'

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
