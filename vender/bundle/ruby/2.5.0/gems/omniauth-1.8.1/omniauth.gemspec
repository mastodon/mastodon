# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'hashie', ['>= 3.4.6', '< 3.6.0']
  spec.add_dependency 'rack', ['>= 1.6.2', '< 3']
  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.authors       = ['Michael Bleigh', 'Erik Michaels-Ober', 'Tom Milewski']
  spec.description   = 'A generalized Rack framework for multiple-provider authentication.'
  spec.email         = ['michael@intridea.com', 'sferik@gmail.com', 'tmilewski@gmail.com']
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.start_with?('spec/') }
  spec.homepage      = 'https://github.com/omniauth/omniauth'
  spec.licenses      = %w[MIT]
  spec.name          = 'omniauth'
  spec.require_paths = %w[lib]
  spec.required_rubygems_version = '>= 1.3.5'
  spec.required_ruby_version = '>= 2.1.9'
  spec.summary       = spec.description
  spec.version       = OmniAuth::VERSION
end
