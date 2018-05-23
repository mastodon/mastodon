require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'elasticsearch/extensions/test/cluster/tasks'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :es do
  task :start do
    Rake.application['elasticsearch:start'].invoke
  end

  task :stop do
    Rake.application['elasticsearch:stop'].invoke
  end
end
