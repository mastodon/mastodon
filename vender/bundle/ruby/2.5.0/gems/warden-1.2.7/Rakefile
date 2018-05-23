# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require 'rubygems'
require 'rake'
$:.unshift  File.join(File.dirname(__FILE__), "lib")

require 'rspec/core'
require 'rspec/core/rake_task'

task :default => :spec

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec)
