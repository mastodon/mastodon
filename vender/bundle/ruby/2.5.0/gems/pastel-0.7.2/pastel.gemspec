# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pastel/version'

Gem::Specification.new do |spec|
  spec.name          = "pastel"
  spec.version       = Pastel::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = [""]
  spec.summary       = %q{Terminal strings styling with intuitive and clean API.}
  spec.description   = %q{Terminal strings styling with intuitive and clean API.}
  spec.homepage      = "https://github.com/piotrmurach/pastel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'equatable', '~> 0.5.0'
  spec.add_dependency 'tty-color', '~> 0.4.0'

  spec.add_development_dependency 'bundler', '>= 1.5.0', '< 2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1'
end
