# -*- ruby encoding: utf-8 -*-
# vim: syntax=ruby

require 'rake/testtask'
require 'rubocop/rake_task'
require 'bundler'

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
  t.description = 'Run tests, set INTEGRATION=openldap to run integration tests, INTEGRATION_HOST and INTEGRATION_PORT are also supported'
end

desc 'Run tests and RuboCop (RuboCop runs on mri only)'
task ci: [:test]

desc 'Run tests and RuboCop'
task rubotest: [:test, :rubocop]

task default: Bundler.current_ruby.mri? ? [:test, :rubocop] : [:test]
