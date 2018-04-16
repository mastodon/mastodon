# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rake/version'

Gem::Specification.new do |s|
  s.name = "rake".freeze
  s.version = Rake::VERSION
  s.authors = ["Hiroshi SHIBATA".freeze, "Eric Hodel".freeze, "Jim Weirich".freeze]
  s.email = ["hsbt@ruby-lang.org".freeze, "drbrain@segment7.net".freeze, "".freeze]

  s.summary = "Rake is a Make-like program implemented in Ruby".freeze
  s.description = <<-DESCRIPTION
Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
specified in standard Ruby syntax.
Rake has the following features:
  * Rakefiles (rake's version of Makefiles) are completely defined in standard Ruby syntax.
    No XML files to edit. No quirky Makefile syntax to worry about (is that a tab or a space?)
  * Users can specify tasks with prerequisites.
  * Rake supports rule patterns to synthesize implicit tasks.
  * Flexible FileLists that act like arrays but know about manipulating file names and paths.
  * Supports parallel execution of tasks.
  DESCRIPTION
  s.homepage = "https://github.com/ruby/rake".freeze
  s.licenses = ["MIT".freeze]

  s.files = %x[git ls-files -z].split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) } -
            %w[.rubocop.yml .travis.yml appveyor.yml]
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib".freeze]

  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "2.6.1".freeze
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.2".freeze)
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]

  s.add_development_dependency(%q<bundler>.freeze)
  s.add_development_dependency(%q<minitest>.freeze)
  s.add_development_dependency(%q<rdoc>.freeze)
  s.add_development_dependency(%q<coveralls>.freeze)
  s.add_development_dependency(%q<rubocop>.freeze)
end
