# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/clean"

Dir[File.expand_path("../tasks/**/*.rake", __FILE__)].each { |task| load task }

task default: %w[compile spec rubocop]

CLEAN.include "**/*.o", "**/*.so", "**/*.bundle", "**/*.jar", "pkg", "tmp"
