# encoding: utf-8
# frozen_string_literal: true

require "bundler/gem_tasks"

require 'rake/testtask'
require 'kaminari'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "{test,#{File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'test')}}/**/*_test.rb"
  t.warning = true
  t.verbose = true
end

task default: "test:all"

namespace :test do
  mappers = %w(
    active_record_edge
    active_record_51
    active_record_50
    active_record_42
    active_record_41
  )

  mappers.each do |gemfile|
    desc "Run Tests against #{gemfile}"
    task gemfile do
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle --quiet"
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle exec rake -t test"
    end
  end

  desc "Run Tests against all ORMs"
  task :all do
    mappers.each do |gemfile|
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle --quiet"
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle exec rake test"
    end
  end
end

task :install_tasks_for_sub_gems do
  Bundler::GemHelper.install_tasks dir: File.join(__dir__, 'kaminari-core'), name: 'kaminari-core'
  Bundler::GemHelper.install_tasks dir: File.join(__dir__, 'kaminari-actionview'), name: 'kaminari-actionview'
  Bundler::GemHelper.install_tasks dir: File.join(__dir__, 'kaminari-activerecord'), name: 'kaminari-activerecord'
end

Rake::Task[:build].enhance [:install_tasks_for_sub_gems]

begin
  require 'rdoc/task'

  Rake::RDocTask.new do |rdoc|
    require 'kaminari/version'

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "kaminari #{Kaminari::VERSION}"
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError
  puts 'RDocTask is not supported on this VM and platform combination.'
end
