# encoding: utf-8
require './lib/crass/version'

Gem::Specification.new do |s|
  s.name        = 'crass'
  s.summary     = 'CSS parser based on the CSS Syntax Level 3 spec.'
  s.description = 'Crass is a pure Ruby CSS parser based on the CSS Syntax Level 3 spec.'
  s.version     = Crass::VERSION
  s.authors     = ['Ryan Grove']
  s.email       = ['ryan@wonko.com']
  s.homepage    = 'https://github.com/rgrove/crass/'
  s.license     = 'MIT'

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = Gem::Requirement.new('>= 1.9.2')

  s.require_paths = ['lib']

  s.files      = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Development dependencies.
  s.add_development_dependency 'minitest', '~> 5.0.8'
  s.add_development_dependency 'rake',     '~> 10.1.0'
end
