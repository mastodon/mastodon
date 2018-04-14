# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tty/prompt/version'

Gem::Specification.new do |spec|
  spec.name          = "tty-prompt"
  spec.version       = TTY::Prompt::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = [""]
  spec.summary       = %q{A beautiful and powerful interactive command line prompt.}
  spec.description   = %q{A beautiful and powerful interactive command line prompt with a robust API for getting and validating complex inputs.}
  spec.homepage      = "https://piotrmurach.github.io/tty"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
                          f.match(%r{^(test|spec|features)/})
                        end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'necromancer',  '~> 0.4.0'
  spec.add_dependency 'pastel',       '~> 0.7.0'
  spec.add_dependency 'timers',       '~> 4.0'
  spec.add_dependency 'tty-cursor',   '~> 0.5.0'
  spec.add_dependency 'tty-reader',   '~> 0.2.0'

  spec.add_development_dependency 'bundler', '>= 1.5.0', '< 2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
