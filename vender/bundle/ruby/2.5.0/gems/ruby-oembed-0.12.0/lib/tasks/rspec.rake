require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:specs)

task :default => :specs