#!/usr/bin/env rake
require "bundler/gem_tasks"

gemspec = Bundler::GemHelper.gemspec

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.test_files = gemspec.test_files
  test.verbose = true
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{gemspec.name} #{gemspec.version}"
  rdoc.rdoc_files.include(gemspec.extra_rdoc_files)
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :test
