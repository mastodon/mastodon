# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'redis/rack/version'

Gem::Specification.new do |s|
  s.name        = 'redis-rack'
  s.version     = Redis::Rack::VERSION
  s.authors     = ['Luca Guidi']
  s.email       = ['me@lucaguidi.com']
  s.homepage    = 'http://redis-store.org/redis-rack'
  s.summary     = %q{Redis Store for Rack}
  s.description = %q{Redis Store for Rack applications}
  s.license     = 'MIT'

  s.rubyforge_project = 'redis-rack'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'redis-store',   ['< 2', '>= 1.2']
  s.add_runtime_dependency 'rack',          '>= 1.5', '< 3'

  s.add_development_dependency 'rake',     '~> 10'
  s.add_development_dependency 'bundler',  '~> 1.3'
  s.add_development_dependency 'mocha',    '~> 0.14.0'
  s.add_development_dependency 'minitest', '~> 5'
  s.add_development_dependency 'redis-store-testing'
  s.add_development_dependency 'connection_pool',     '~> 1.2.0'
  s.add_development_dependency 'appraisal'
end

