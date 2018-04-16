require 'rubygems'
require 'bundler/setup'

orm = ENV['BUNDLE_GEMFILE'].match(/Gemfile\.(.+)\.rb/)
unless defined?(DOORKEEPER_ORM)
  DOORKEEPER_ORM = (orm && orm[1]) || :active_record
end

$LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__)
