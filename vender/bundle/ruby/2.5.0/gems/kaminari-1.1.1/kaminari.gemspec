# -*- encoding: utf-8 -*-
# frozen_string_literal: true
$:.push File.expand_path("../lib", __FILE__)
require "kaminari/version"

Gem::Specification.new do |spec|
  spec.name        = 'kaminari'
  spec.version     = Kaminari::VERSION
  spec.authors     = ['Akira Matsuda', 'Yuki Nishijima', 'Zachary Scott', 'Hiroshi Shibata']
  spec.email       = ['ronnie@dio.jp']
  spec.homepage    = 'https://github.com/kaminari/kaminari'
  spec.summary     = 'A pagination engine plugin for Rails 4+ and other modern frameworks'
  spec.description = 'Kaminari is a Scope & Engine based, clean, powerful, agnostic, customizable and sophisticated paginator for Rails 4+'
  spec.license       = "MIT"

  spec.files         = `git ls-files | egrep -v 'kaminari-(core|actionview|activerecord)' | grep -v '^test'`.split("\n")
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'activesupport', '>= 4.1.0'
  spec.add_dependency 'kaminari-core', Kaminari::VERSION
  spec.add_dependency 'kaminari-actionview', Kaminari::VERSION
  spec.add_dependency 'kaminari-activerecord', Kaminari::VERSION

  spec.add_development_dependency 'test-unit-rails'
  spec.add_development_dependency 'bundler', '>= 1.0.0'
  spec.add_development_dependency 'rake', '>= 0'
  spec.add_development_dependency 'rr', '>= 0'
  spec.add_development_dependency 'capybara', '>= 1.0'
end
