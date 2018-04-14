require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

Cucumber::Rake::Task.new(:wip, "Run features tagged with @wip") do |t|
  t.profile = "wip"
end

task :default => [:spec, :cucumber, :wip]
