# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "strong_migrations/version"

Gem::Specification.new do |spec|
  spec.name          = "strong_migrations"
  spec.version       = StrongMigrations::VERSION
  spec.authors       = ["Bob Remeika", "David Waller", "Andrew Kane"]
  spec.email         = ["bob.remeika@gmail.com", "andrew@chartkick.com"]

  spec.summary       = "Catch unsafe migrations at dev time"
  spec.homepage      = "https://github.com/ankane/strong_migrations"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 3.2.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pg", "< 1"
end
