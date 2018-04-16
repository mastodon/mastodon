#!/usr/bin/env rake
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
desc 'Default: run specs.'
task default: :spec

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--require spec_helper --color --order rand'
end

task :test do
  fail %q{This application uses RSpec. Try running "rake spec"}
end
