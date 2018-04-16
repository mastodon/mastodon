# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/local/version'

Gem::Specification.new do |spec|
  spec.name          = "fog-local"
  spec.version       = Fog::Local::VERSION
  spec.authors       = ["Wesley Beary", "Ville Lautanala"]
  spec.email         = ["geemus@gmail.com", "lautis@gmail.com"]

  spec.summary       = %q{Module for the 'fog' gem to support local filesystem storage.}
  spec.description   = %q{This library can be used as a module for `fog` or as standalone provider
                       to use local filesystem storage.}
  spec.homepage      = "https://github.com/fog/fog-local"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'shindo',  '~> 0.3'

  spec.add_dependency 'fog-core',  '>= 1.27', '< 3.0'
end
