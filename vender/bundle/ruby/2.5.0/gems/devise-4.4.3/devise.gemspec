# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)
require "devise/version"

Gem::Specification.new do |s|
  s.name        = "devise"
  s.version     = Devise::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ["MIT"]
  s.summary     = "Flexible authentication solution for Rails with Warden"
  s.email       = "contact@plataformatec.com.br"
  s.homepage    = "https://github.com/plataformatec/devise"
  s.description = "Flexible authentication solution for Rails with Warden"
  s.authors     = ['José Valim', 'Carlos Antônio']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency("warden", "~> 1.2.3")
  s.add_dependency("orm_adapter", "~> 0.1")
  s.add_dependency("bcrypt", "~> 3.0")
  s.add_dependency("railties", ">= 4.1.0", "< 6.0")
  s.add_dependency("responders")
end
