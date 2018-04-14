require 'bundler'
Bundler::GemHelper.install_tasks
require "rspec/core/rake_task" 

RSpec::Core::RakeTask.new(:rspec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :rspec
