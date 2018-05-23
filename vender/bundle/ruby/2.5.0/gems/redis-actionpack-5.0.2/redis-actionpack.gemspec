# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'redis/actionpack/version'

Gem::Specification.new do |s|
  s.name        = 'redis-actionpack'
  s.version     = Redis::ActionPack::VERSION
  s.authors     = ['Luca Guidi']
  s.email       = ['me@lucaguidi.com']
  s.homepage    = 'http://redis-store.org/redis-actionpack'
  s.summary     = %q{Redis session store for ActionPack}
  s.description = %q{Redis session store for ActionPack}
  s.license     = 'MIT'

  s.rubyforge_project = 'redis-actionpack'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'redis-store', '>= 1.1.0', '< 2'
  s.add_runtime_dependency 'redis-rack',  '>= 1', '< 3'
  s.add_runtime_dependency 'actionpack',  '>= 4.0', '< 6'

  s.add_development_dependency 'rake',     '~> 10'
  s.add_development_dependency 'bundler',  '~> 1.3'
  s.add_development_dependency 'mocha',    '~> 0.14.0'
  s.add_development_dependency 'minitest-rails'
  s.add_development_dependency 'tzinfo'
  # s.add_development_dependency 'mini_backtrace'
  s.add_development_dependency 'redis-store-testing'
end
