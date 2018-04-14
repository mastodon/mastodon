#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rspec/core/rake_task'
$:.push File.expand_path("../lib", __FILE__)
require "orm_adapter/version"

task :default => :spec

RSpec::Core::RakeTask.new(:spec)

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files   = ['lib/**/*.rb', 'README.rdoc']
  end
rescue LoadError
  task :doc do
    puts "install yard to generate the docs"
  end
end

Bundler::GemHelper.install_tasks
