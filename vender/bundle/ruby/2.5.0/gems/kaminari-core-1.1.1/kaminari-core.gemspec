# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kaminari/core/version'

Gem::Specification.new do |spec|
  spec.name          = "kaminari-core"
  spec.version       = Kaminari::Core::VERSION
  spec.authors       = ["Akira Matsuda"]
  spec.email         = ["ronnie@dio.jp"]

  spec.summary       = "Kaminari's core pagination library"
  spec.description   = 'kaminari-core includes pagination logic independent from ORMs and view libraries'
  spec.homepage      = 'https://github.com/kaminari/kaminari'
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.13"
  spec.add_development_dependency "rake", ">= 10.0"
end
