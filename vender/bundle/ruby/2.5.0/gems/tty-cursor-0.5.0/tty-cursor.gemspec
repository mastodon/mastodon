# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tty/version'

Gem::Specification.new do |spec|
  spec.name          = 'tty-cursor'
  spec.version       = TTY::Cursor::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = [""]
  spec.summary       = %q{Terminal cursor positioning, visibility and text manipulation.}
  spec.description   = %q{The purpose of this library is to help move the terminal cursor around and manipulate text by using intuitive method calls.}
  spec.homepage       = 'http://piotrmurach.github.io/tty/'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.5.0'
end
