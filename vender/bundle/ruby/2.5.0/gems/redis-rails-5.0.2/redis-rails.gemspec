# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis-rails/version"

Gem::Specification.new do |s|
  s.name        = "redis-rails"
  s.version     = Redis::Rails::VERSION
  s.authors     = ["Luca Guidi", "Ryan Bigg"]
  s.email       = ["me@lucaguidi.com", "me@ryanbigg.com"]
  s.homepage    = "http://redis-store.org/redis-rails"
  s.summary     = %q{Redis for Ruby on Rails}
  s.description = %q{Redis for Ruby on Rails}
  s.license     = 'MIT'

  s.rubyforge_project = "redis-rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "redis-store",         [">= 1.2", "< 2"]
  s.add_dependency "redis-activesupport", [">= 5.0", "< 6"]
  s.add_dependency "redis-actionpack",    [">= 5.0", "< 6"]

  s.add_development_dependency "rake",     "~> 10"
  s.add_development_dependency "bundler",  "~> 1.3"
  s.add_development_dependency "mocha",    "~> 0.14.0"
  s.add_development_dependency "minitest", [">= 4.2", "< 6"]
  s.add_development_dependency "redis-store-testing"
end
