# -*- encoding: utf-8 -*-
# stub: redis-store 1.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "redis-store".freeze
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luca Guidi".freeze]
  s.date = "2017-10-13"
  s.description = "Namespaced Rack::Session, Rack::Cache, I18n and cache Redis stores for Ruby web frameworks.".freeze
  s.email = ["me@lucaguidi.com".freeze]
  s.homepage = "http://redis-store.org/redis-store".freeze
  s.licenses = ["MIT".freeze]
  s.rubyforge_project = "redis-store".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Redis stores for Ruby frameworks".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>.freeze, ["< 5", ">= 2.2"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5"])
      s.add_development_dependency(%q<git>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<pry-nav>.freeze, ["~> 0.2.4"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0.10.4"])
      s.add_development_dependency(%q<redis-store-testing>.freeze, [">= 0"])
    else
      s.add_dependency(%q<redis>.freeze, ["< 5", ">= 2.2"])
      s.add_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5"])
      s.add_dependency(%q<git>.freeze, ["~> 1.2"])
      s.add_dependency(%q<pry-nav>.freeze, ["~> 0.2.4"])
      s.add_dependency(%q<pry>.freeze, ["~> 0.10.4"])
      s.add_dependency(%q<redis-store-testing>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<redis>.freeze, ["< 5", ">= 2.2"])
    s.add_dependency(%q<rake>.freeze, ["~> 10"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5"])
    s.add_dependency(%q<git>.freeze, ["~> 1.2"])
    s.add_dependency(%q<pry-nav>.freeze, ["~> 0.2.4"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.10.4"])
    s.add_dependency(%q<redis-store-testing>.freeze, [">= 0"])
  end
end
