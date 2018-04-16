require 'bundler/setup'
require 'rake'
require 'bundler/gem_tasks'
require 'redis-store/testing/tasks'

task :all do
  Dir["gemfiles/*.gemfile"].reject { |p| p =~ /\.lock\Z/ }.each do |gemfile|
    sh "BUNDLE_GEMFILE=#{gemfile} bundle exec rake"
  end
end
