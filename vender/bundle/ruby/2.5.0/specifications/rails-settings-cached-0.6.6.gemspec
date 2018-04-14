# -*- encoding: utf-8 -*-
# stub: rails-settings-cached 0.6.6 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-settings-cached".freeze
  s.version = "0.6.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jason Lee".freeze, "Squeegy".freeze, "Georg Ledermann".freeze, "100hz".freeze]
  s.date = "2017-08-01"
  s.description = "\n  This is improved from rails-settings, added caching.\n  Settings plugin for Rails that makes managing a table of global key,\n  value pairs easy. Think of it like a global Hash stored in you database,\n  that uses simple ActiveRecord like methods for manipulation.\n\n  Keep track of any global setting that you dont want to hard code into your rails app.\n  You can store any kind of object.  Strings, numbers, arrays, or any object.\n  ".freeze
  s.email = "huacnlee@gmail.com".freeze
  s.homepage = "https://github.com/huacnlee/rails-settings-cached".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.1".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Settings plugin for Rails that makes managing a table of global keys.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 4.2.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<codecov>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 4.2.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<codecov>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 4.2.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<codecov>.freeze, [">= 0"])
  end
end
