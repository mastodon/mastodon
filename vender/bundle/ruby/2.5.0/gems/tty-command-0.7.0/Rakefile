# encoding: utf-8

require "bundler/gem_tasks"

FileList['tasks/**/*.rake'].each(&method(:import))

task default: :spec

desc 'Run all specs'
task ci: %w[ spec ]
