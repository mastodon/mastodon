# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hamlit-rails/version'

Gem::Specification.new do |spec|
  spec.name          = "hamlit-rails"
  spec.version       = Hamlit::Rails::VERSION
  spec.authors       = ["Meng Fung"]
  spec.email         = ["meng.fung@gmail.com"]

  spec.summary       = %q{hamlit and rails}
  spec.description   = %q{hamlit-rails provides generators for Rails 4.}
  spec.homepage      = "https://github.com/mfung/hamlit-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "hamlit", ">= 1.2.0"
  spec.add_runtime_dependency "activesupport", ">= 4.0.1"
  spec.add_runtime_dependency "actionpack", ">= 4.0.1"
  spec.add_runtime_dependency "railties", ">= 4.0.1"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "html2haml", ">= 2.0.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rails", ">= 4.0.1"
  spec.add_development_dependency "appraisal", "~> 1.0"
  spec.add_development_dependency "codeclimate-test-reporter", ">= 0.4.7"
end
