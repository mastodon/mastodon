# Rakefile for rake        -*- ruby -*-

# Copyright 2004, 2005, 2006 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.

require 'rake/clean'
require 'rake/testtask'
begin
  require 'rubygems'
  require 'rubygems/package_task'
  require 'rdoc/task'
rescue Exception
  nil
end

require './lib/builder/version'

# Determine the current version of the software

CLOBBER.include('pkg', 'html')
CLEAN.include('pkg/builder-*').include('pkg/blankslate-*').exclude('pkg/*.gem')

PKG_VERSION = Builder::VERSION

SRC_RB = FileList['lib/**/*.rb']

# The default task is run if rake is given no explicit arguments.

desc "Default Task"
task :default => :test_all

# Test Tasks ---------------------------------------------------------

desc "Run all tests"
task :test_all => [:test_units]
task :ta => [:test_all]

task :tu => [:test_units]

Rake::TestTask.new("test_units") do |t|
  t.test_files = FileList['test/test*.rb']
  t.libs << "."
  t.verbose = false
end

# Create a task to build the RDOC documentation tree.

if defined?(RDoc)
  rd = RDoc::Task.new("rdoc") { |rdoc|
    rdoc.rdoc_dir = 'html'
    rdoc.title    = "Builder for Markup"
    rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc'
    rdoc.rdoc_files.include('lib/**/*.rb', '[A-Z]*', 'doc/**/*.rdoc').exclude("TAGS")
    rdoc.template = 'doc/jamis.rb'
  }
else
  rd = Struct.new(:rdoc_files).new([])
end

# ====================================================================
# Create a task that will package the Rake software into distributable
# gem files.

PKG_FILES = FileList[
  '[A-Z]*',
  'doc/**/*',
  'lib/**/*.rb',
  'test/**/*.rb',
  'rakelib/**/*'
]
PKG_FILES.exclude('test/test_cssbuilder.rb')
PKG_FILES.exclude('lib/builder/css.rb')
PKG_FILES.exclude('TAGS')

BLANKSLATE_FILES = FileList[
  'lib/blankslate.rb',
  'test/test_blankslate.rb'
]

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|

    #### Basic information.

    s.name = 'builder'
    s.version = PKG_VERSION
    s.summary = "Builders for MarkUp."
    s.description = %{\
Builder provides a number of builder objects that make creating structured data
simple to do.  Currently the following builder objects are supported:

* XML Markup
* XML Events
}

    s.files = PKG_FILES.to_a
    s.require_path = 'lib'

    s.test_files = PKG_FILES.select { |fn| fn =~ /^test\/test/ }

    s.has_rdoc = true
    s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
    s.rdoc_options <<
      '--title' <<  'Builder -- Easy XML Building' <<
      '--main' << 'README.rdoc' <<
      '--line-numbers'

    s.author = "Jim Weirich"
    s.email = "jim.weirich@gmail.com"
    s.homepage = "http://onestepback.org"
    s.license = 'MIT'
  end

  blankslate_spec = Gem::Specification.new do |s|

    #### Basic information.

    s.name = 'blankslate'
    s.version = PKG_VERSION
    s.summary = "Blank Slate base class."
    s.description = %{\
BlankSlate provides a base class where almost all of the methods from Object and
Kernel have been removed.  This is useful when providing proxy object and other
classes that make heavy use of method_missing.
}

    s.files = BLANKSLATE_FILES.to_a
    s.require_path = 'lib'

    s.test_files = PKG_FILES.select { |fn| fn =~ /^test\/test/ }

    s.has_rdoc = true
    s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
    s.rdoc_options <<
      '--title' <<  'BlankSlate -- Base Class for building proxies.' <<
      '--main' << 'README.rdoc' <<
      '--line-numbers'

    s.author = "Jim Weirich"
    s.email = "jim.weirich@gmail.com"
    s.homepage = "http://onestepback.org"
    s.license = 'MIT'
  end

  namespace 'builder' do
    Gem::PackageTask.new(spec) do |t|
      t.need_tar = false
    end
  end

  namespace 'blankslate' do
    Gem::PackageTask.new(blankslate_spec) do |t|
      t.need_tar = false
    end
  end

  task :package => [:remove_tags, 'builder:package', 'blankslate:package']
end

task :remove_tags do
  rm "TAGS" rescue nil
end

# RCov ---------------------------------------------------------------
begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.rcov_opts = [
      '-xRakefile', '--text-report'
    ]
    t.test_files = FileList[
      'test/test*.rb'
    ]
    t.output_dir = 'coverage'
    t.verbose = true
  end
rescue LoadError
  # No rcov available
end

desc "Install the jamis RDoc template"
task :install_jamis_template do
  require 'rbconfig'
  dest_dir = File.join(Config::CONFIG['rubylibdir'], "rdoc/generators/template/html")
  fail "Unabled to write to #{dest_dir}" unless File.writable?(dest_dir)
  install "doc/jamis.rb", dest_dir, :verbose => true
end
