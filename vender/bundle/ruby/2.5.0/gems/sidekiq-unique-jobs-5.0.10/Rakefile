# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:style)
RSpec::Core::RakeTask.new(:spec)

task default: [:style, :spec]
