# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tty/command/version'

Gem::Specification.new do |spec|
  spec.name          = "tty-command"
  spec.version       = TTY::Command::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = [""]

  spec.summary       = %q{Execute shell commands with pretty output logging and capture their stdout, stderr and exit status.}
  spec.description   = %q{Execute shell commands with pretty output logging and capture their stdout, stderr and exit status. Redirect stdin, stdout and stderr of each command to a file or a string.}
  spec.homepage      = "https://piotrmurach.github.io/tty"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'pastel', '~> 0.7.0'

  spec.add_development_dependency 'bundler', '>= 1.5.0', '< 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
