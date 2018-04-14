# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'redis/store/version'

Gem::Specification.new do |s|
  s.name        = 'redis-store'
  s.version     = Redis::Store::VERSION
  s.authors     = ['Luca Guidi']
  s.email       = ['me@lucaguidi.com']
  s.homepage    = 'http://redis-store.org/redis-store'
  s.summary     = %q{Redis stores for Ruby frameworks}
  s.description = %q{Namespaced Rack::Session, Rack::Cache, I18n and cache Redis stores for Ruby web frameworks.}

  s.rubyforge_project = 'redis-store'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.license       = 'MIT'

  s.add_dependency 'redis', '>= 2.2', '< 5'

  s.add_development_dependency 'rake',     '~> 10'
  s.add_development_dependency 'bundler',  '~> 1.3'
  s.add_development_dependency 'mocha',    '~> 0.14.0'
  s.add_development_dependency 'minitest', '~> 5'
  s.add_development_dependency 'git',      '~> 1.2'
  s.add_development_dependency 'pry-nav',  '~> 0.2.4'
  s.add_development_dependency 'pry',      '~> 0.10.4'
  s.add_development_dependency 'redis-store-testing'
end
