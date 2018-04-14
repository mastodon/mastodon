require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:test)

  task default: :test
rescue LoadError
  puts 'RSpec rake tasks not available. Please run "bundle install" to install missing dependencies.'
end
