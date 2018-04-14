# -*- encoding: utf-8 -*-
# stub: redis-activesupport 5.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "redis-activesupport".freeze
  s.version = "5.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luca Guidi".freeze, "Ryan Bigg".freeze]
  s.date = "2017-10-16"
  s.description = "Redis store for ActiveSupport".freeze
  s.email = ["me@lucaguidi.com".freeze, "me@ryanbigg.com".freeze]
  s.homepage = "http://redis-store.org/redis-activesupport".freeze
  s.licenses = ["MIT".freeze]
  s.rubyforge_project = "redis-activesupport".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Redis store for ActiveSupport".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.3"])
      s.add_runtime_dependency(%q<activesupport>.freeze, ["< 6", ">= 3"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
      s.add_development_dependency(%q<minitest>.freeze, ["< 6", ">= 4.2"])
      s.add_development_dependency(%q<connection_pool>.freeze, ["~> 2.2.0"])
      s.add_development_dependency(%q<redis-store-testing>.freeze, [">= 0"])
    else
      s.add_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.3"])
      s.add_dependency(%q<activesupport>.freeze, ["< 6", ">= 3"])
      s.add_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
      s.add_dependency(%q<minitest>.freeze, ["< 6", ">= 4.2"])
      s.add_dependency(%q<connection_pool>.freeze, ["~> 2.2.0"])
      s.add_dependency(%q<redis-store-testing>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.3"])
    s.add_dependency(%q<activesupport>.freeze, ["< 6", ">= 3"])
    s.add_dependency(%q<rake>.freeze, ["~> 10"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
    s.add_dependency(%q<minitest>.freeze, ["< 6", ">= 4.2"])
    s.add_dependency(%q<connection_pool>.freeze, ["~> 2.2.0"])
    s.add_dependency(%q<redis-store-testing>.freeze, [">= 0"])
  end
end
