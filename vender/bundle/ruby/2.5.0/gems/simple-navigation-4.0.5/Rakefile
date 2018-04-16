require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'

require 'rdoc/task'

RSpec::Core::RakeTask.new(:spec)

task default: 'spec'

namespace :spec do
  mappers = %w[
    rails-3-2-stable
    rails-4-1-stable
    rails-4-2-stable
  ]

  mappers.each do |gemfile|
    desc "Run Tests against #{gemfile}"
    task gemfile do
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle -j 4 --quiet"
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle exec rake -t spec"
    end
  end

  desc 'Run Tests against all ORMs'
  task all: mappers
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleNavigation'
  rdoc.options << '--inline-source'
  rdoc.rdoc_files.include('README.md', 'lib/**/*.rb')
end
