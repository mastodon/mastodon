require "rake/clean"
require 'bundler/gem_tasks'
require 'concourse'

namespace :test do
  desc "Test MiniPortile by running unit tests"
  task :unit do
    sh "ruby -w -W2 -I. -Ilib -e \"#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- #{ENV['TESTOPTS']} -v"
  end

  desc "Test MiniPortile by compiling examples"
  task :examples do
    Dir.chdir("examples") do
      sh "rake ports:all"
    end
  end
end

task :clean do
  FileUtils.rm_rf ["examples/ports", "examples/tmp"], :verbose => true
end

desc "Run all tests"
task :test => ["test:unit", "test:examples"]

task :default => [:test]


Concourse.new("mini_portile").create_tasks!
