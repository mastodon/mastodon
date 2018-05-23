# -*- coding: utf-8 -*-
require 'bundler/gem_tasks'

gemspec = Bundler::GemHelper.gemspec

require 'rake/extensiontask'
Rake::ExtensionTask.new('unf_ext', gemspec) do |ext|
  ext.cross_compile = true
  ext.cross_platform = %w[x86-mingw32 x64-mingw32]
  ext.cross_config_options << '--with-ldflags="-static-libgcc"' << '--with-static-libstdc++'
end

namespace :gem do
  task :native do
    require 'rake_compiler_dock'
    RakeCompilerDock.sh "(bundle --local --quiet || bundle) && rake cross native gem"
  end

  task :all => [:build, :native]
end

task :gems => :'gem:all'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.test_files = gemspec.test_files
  test.verbose = true
end

task :default => :test
