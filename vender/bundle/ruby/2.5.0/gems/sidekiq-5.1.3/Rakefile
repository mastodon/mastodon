require 'bundler/gem_tasks'
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.warning = true
  test.pattern = 'test/**/test_*.rb'
end

task :default => :test
