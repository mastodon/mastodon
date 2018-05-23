# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__) unless $:.include?('lib')
require 'thread_safe/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Charles Oliver Nutter", "thedarkone"]
  gem.email         = ["headius@headius.com", "thedarkone2@gmail.com"]
  gem.summary       = %q{Thread-safe collections and utilities for Ruby}
  gem.description   = %q{A collection of data structures and utilities to make thread-safe programming in Ruby easier}
  gem.homepage      = "https://github.com/ruby-concurrency/thread_safe"

  gem.files         = `git ls-files`.split($\)
  gem.files        += ['lib/thread_safe/jruby_cache_backend.jar'] if defined?(JRUBY_VERSION)
  gem.files        -= ['.gitignore'] # see https://github.com/headius/thread_safe/issues/40#issuecomment-42315441
  gem.platform      = 'java' if defined?(JRUBY_VERSION)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "thread_safe"
  gem.require_paths = ["lib"]
  gem.version       = ThreadSafe::VERSION
  gem.license       = "Apache-2.0"

  gem.add_development_dependency 'atomic', '= 1.1.16'
  gem.add_development_dependency 'rake', '< 12.0'
  gem.add_development_dependency 'rspec', '~> 3.2'
end
