require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'

RuboCop::RakeTask.new

task :default => :test

desc 'Run fog-openstack unit tests with Minitest'
task :test do
  mock = ENV['FOG_MOCK'] || 'true'
  sh("export FOG_MOCK=#{mock} && bundle exec rake tests:unit")
end

desc 'Run fog-openstack spec/ tests (VCR)'
task :spec => "tests:spec"

namespace :tests do
  desc "Run fog-openstack test/"
  Rake::TestTask.new do |t|
    t.name = 'unit'
    t.libs.push [ "lib", "test" ]
    t.test_files = FileList['test/**/*.rb']
    t.verbose = true
  end

  desc "Run fog-openstack spec/"
  Rake::TestTask.new do |t|
    t.name = 'spec'
    t.libs.push [ "lib", "spec" ]
    t.pattern = 'spec/**/*_spec.rb'
    t.verbose = true
  end
end
