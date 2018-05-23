require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

require "rake/testtask"
task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*_test.rb']
    t.verbose = true
  end
end

task :default => :test
