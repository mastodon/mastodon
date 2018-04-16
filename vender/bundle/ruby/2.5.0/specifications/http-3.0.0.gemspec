# -*- encoding: utf-8 -*-
# stub: http 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "http".freeze
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tony Arcieri".freeze, "Erik Michaels-Ober".freeze, "Alexey V. Zapparov".freeze, "Zachary Anker".freeze]
  s.date = "2017-10-01"
  s.description = "An easy-to-use client library for making requests from Ruby. It uses a simple method chaining system for building requests, similar to Python's Requests.".freeze
  s.email = ["bascule@gmail.com".freeze]
  s.homepage = "https://github.com/httprb/http".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "HTTP should be easy".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<http_parser.rb>.freeze, ["~> 0.6.0"])
      s.add_runtime_dependency(%q<http-form_data>.freeze, ["< 3", ">= 2.0.0.pre.pre2"])
      s.add_runtime_dependency(%q<http-cookie>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.3"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
    else
      s.add_dependency(%q<http_parser.rb>.freeze, ["~> 0.6.0"])
      s.add_dependency(%q<http-form_data>.freeze, ["< 3", ">= 2.0.0.pre.pre2"])
      s.add_dependency(%q<http-cookie>.freeze, ["~> 1.0"])
      s.add_dependency(%q<addressable>.freeze, ["~> 2.3"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<http_parser.rb>.freeze, ["~> 0.6.0"])
    s.add_dependency(%q<http-form_data>.freeze, ["< 3", ">= 2.0.0.pre.pre2"])
    s.add_dependency(%q<http-cookie>.freeze, ["~> 1.0"])
    s.add_dependency(%q<addressable>.freeze, ["~> 2.3"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
  end
end
