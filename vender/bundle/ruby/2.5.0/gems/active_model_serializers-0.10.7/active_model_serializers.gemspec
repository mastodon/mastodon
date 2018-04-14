# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_model/serializer/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_model_serializers'
  spec.version       = ActiveModel::Serializer::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Steve Klabnik']
  spec.email         = ['steve@steveklabnik.com']
  spec.summary       = 'Conventions-based JSON generation for Rails.'
  spec.description   = 'ActiveModel::Serializers allows you to generate your JSON in an object-oriented and convention-driven manner.'
  spec.homepage      = 'https://github.com/rails-api/active_model_serializers'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.executables   = []

  spec.required_ruby_version = '>= 2.1'

  rails_versions = ['>= 4.1', '< 6']
  spec.add_runtime_dependency 'activemodel', rails_versions
  # 'activesupport', rails_versions
  # 'builder'

  spec.add_runtime_dependency 'actionpack', rails_versions
  # 'activesupport', rails_versions
  # 'rack'
  # 'rack-test', '~> 0.6.2'

  spec.add_development_dependency 'railties', rails_versions
  # 'activesupport', rails_versions
  # 'actionpack', rails_versions
  # 'rake', '>= 0.8.7'

  # 'activesupport', rails_versions
  # 'i18n,
  # 'tzinfo'
  # 'minitest'
  # 'thread_safe'

  spec.add_runtime_dependency 'jsonapi-renderer', ['>= 0.1.1.beta1', '< 0.3']
  spec.add_runtime_dependency 'case_transform', '>= 0.2'

  spec.add_development_dependency 'activerecord', rails_versions
  # arel
  # activesupport
  # activemodel

  # Soft dependency for pagination
  spec.add_development_dependency 'kaminari', ' ~> 0.16.3'
  spec.add_development_dependency 'will_paginate', '~> 3.0', '>= 3.0.7'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'timecop', '~> 0.7'
  spec.add_development_dependency 'grape', ['>= 0.13', '< 0.19.1']
  spec.add_development_dependency 'json_schema'
  spec.add_development_dependency 'rake', ['>= 10.0', '< 12.0']
end
