# -*- encoding: utf-8 -*-
# stub: redis-actionpack 5.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "redis-actionpack".freeze
  s.version = "5.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luca Guidi".freeze]
  s.date = "2017-10-16"
  s.description = "Redis session store for ActionPack".freeze
  s.email = ["me@lucaguidi.com".freeze]
  s.homepage = "http://redis-store.org/redis-actionpack".freeze
  s.licenses = ["MIT".freeze]
  s.rubyforge_project = "redis-actionpack".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Redis session store for ActionPack".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.1.0"])
      s.add_runtime_dependency(%q<redis-rack>.freeze, ["< 3", ">= 1"])
      s.add_runtime_dependency(%q<actionpack>.freeze, ["< 6", ">= 4.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
      s.add_development_dependency(%q<minitest-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<tzinfo>.freeze, [">= 0"])
      s.add_development_dependency(%q<redis-store-testing>.freeze, [">= 0"])
    else
      s.add_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.1.0"])
      s.add_dependency(%q<redis-rack>.freeze, ["< 3", ">= 1"])
      s.add_dependency(%q<actionpack>.freeze, ["< 6", ">= 4.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
      s.add_dependency(%q<minitest-rails>.freeze, [">= 0"])
      s.add_dependency(%q<tzinfo>.freeze, [">= 0"])
      s.add_dependency(%q<redis-store-testing>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<redis-store>.freeze, ["< 2", ">= 1.1.0"])
    s.add_dependency(%q<redis-rack>.freeze, ["< 3", ">= 1"])
    s.add_dependency(%q<actionpack>.freeze, ["< 6", ">= 4.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0.14.0"])
    s.add_dependency(%q<minitest-rails>.freeze, [">= 0"])
    s.add_dependency(%q<tzinfo>.freeze, [">= 0"])
    s.add_dependency(%q<redis-store-testing>.freeze, [">= 0"])
  end
end
