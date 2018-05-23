# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'necromancer/version'

Gem::Specification.new do |spec|
  spec.name          = 'necromancer'
  spec.version       = Necromancer::VERSION
  spec.authors       = ['Piotr Murach']
  spec.email         = ['']
  spec.summary       = %q{Conversion from one object type to another with a bit of black magic.}
  spec.description   = %q{Conversion from one object type to another with a bit of black magic.}
  spec.homepage      = 'https://github.com/piotrmurach/necromancer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.5.0'
end
