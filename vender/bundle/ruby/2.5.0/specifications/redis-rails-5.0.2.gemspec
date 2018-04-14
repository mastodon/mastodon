# -*- encoding: utf-8 -*-
# stub: redis-rails 5.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "redis-rails".freeze
  s.version = "5.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luca Guidi".freeze, "Ryan Bigg".freeze]
  s.date = "2017-04-06"
  s.description = "Redis for Ruby on Rails".freeze
  s.email = ["me@lucaguidi.com".freeze, "me@ryanbigg.com".freeze]
  s.homepage = "http://redis-store.org/redis-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubyforge_project = "redis-rails".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Redis for Ruby on Rails".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.2"])
      s.add_runtime_dependency(%q<redis-activesupport>.freeze, ["< 6", ">= 5.0"])
      s.add_runtime_dependency(%q<redis-actionpack>.freeze, ["< 6", ">= 5.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
      s.add_development_dependency(%q<minitest>.freeze, ["< 6", ">= 4.2"])
      s.add_development_dependency(%q<redis-store-testing>.freeze, [">= 0"])
    else
      s.add_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.2"])
      s.add_dependency(%q<redis-activesupport>.freeze, ["< 6", ">= 5.0"])
      s.add_dependency(%q<redis-actionpack>.freeze, ["< 6", ">= 5.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
      s.add_dependency(%q<minitest>.freeze, ["< 6", ">= 4.2"])
      s.add_dependency(%q<redis-store-testing>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.2"])
    s.add_dependency(%q<redis-activesupport>.freeze, ["< 6", ">= 5.0"])
    s.add_dependency(%q<redis-actionpack>.freeze, ["< 6", ">= 5.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
    s.add_dependency(%q<minitest>.freeze, ["< 6", ">= 4.2"])
    s.add_dependency(%q<redis-store-testing>.freeze, [">= 0"])
  end
end
