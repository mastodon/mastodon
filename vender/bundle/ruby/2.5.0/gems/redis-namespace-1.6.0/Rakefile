require 'rubygems'
require "rspec/core/rake_task"

require "bundler/gem_tasks"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
  spec.ruby_opts = ['-w']
end

task :default => :spec
task :test    => :spec
