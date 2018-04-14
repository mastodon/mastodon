require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.ruby_opts << '-r./test/simplecov_start.rb' if RUBY_VERSION >= '1.9'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = HTTP::Cookie::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "http-cookie #{version}"
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include(Bundler::GemHelper.gemspec.extra_rdoc_files)
end
