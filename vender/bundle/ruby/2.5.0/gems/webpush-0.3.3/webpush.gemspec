# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webpush/version'

Gem::Specification.new do |spec|
  spec.name          = "webpush"
  spec.version       = Webpush::VERSION
  spec.authors       = ["zaru@sakuraba"]
  spec.email         = ["zarutofu@gmail.com"]

  spec.summary       = %q{Encryption Utilities for Web Push payload. }
  spec.homepage      = "https://github.com/zaru/webpush"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hkdf", "~> 0.2"
  spec.add_dependency "jwt", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 1.24"
  spec.add_development_dependency "ece", "~> 0.2"
end
