# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tty/color/version'

Gem::Specification.new do |spec|
  spec.name          = 'tty-color'
  spec.version       = TTY::Color::VERSION
  spec.authors       = ['Piotr Murach']
  spec.email         = [""]
  spec.summary       = %q{Terminal color capabilities detection}
  spec.description   = %q{Terminal color capabilities detection}
  spec.homepage      = "http://piotrmurach.github.io/tty"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '>= 1.5.0', '< 2.0'
  spec.add_development_dependency 'rake',    '~> 10.0'
end
