# -*- encoding: utf-8 -*-
# stub: sidekiq-scheduler 2.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sidekiq-scheduler".freeze
  s.version = "2.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Morton Jonuschat".freeze, "Moove-it".freeze]
  s.date = "2018-01-25"
  s.description = "Light weight job scheduling extension for Sidekiq that adds support for queueing jobs in a recurring way.".freeze
  s.email = ["sidekiq-scheduler@moove-it.com".freeze]
  s.homepage = "https://moove-it.github.io/sidekiq-scheduler/".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Light weight job scheduling extension for Sidekiq".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sidekiq>.freeze, [">= 3"])
      s.add_runtime_dependency(%q<redis>.freeze, ["< 5", ">= 3"])
      s.add_runtime_dependency(%q<rufus-scheduler>.freeze, ["~> 3.2"])
      s.add_runtime_dependency(%q<tilt>.freeze, [">= 1.4.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<timecop>.freeze, ["~> 0"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<mock_redis>.freeze, ["~> 0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0"])
      s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<activejob>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_development_dependency(%q<sinatra>.freeze, [">= 0"])
    else
      s.add_dependency(%q<sidekiq>.freeze, [">= 3"])
      s.add_dependency(%q<redis>.freeze, ["< 5", ">= 3"])
      s.add_dependency(%q<rufus-scheduler>.freeze, ["~> 3.2"])
      s.add_dependency(%q<tilt>.freeze, [">= 1.4.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<timecop>.freeze, ["~> 0"])
      s.add_dependency(%q<mocha>.freeze, ["~> 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<mock_redis>.freeze, ["~> 0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0"])
      s.add_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_dependency(%q<activejob>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_dependency(%q<sinatra>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<sidekiq>.freeze, [">= 3"])
    s.add_dependency(%q<redis>.freeze, ["< 5", ">= 3"])
    s.add_dependency(%q<rufus-scheduler>.freeze, ["~> 3.2"])
    s.add_dependency(%q<tilt>.freeze, [">= 1.4.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<mock_redis>.freeze, ["~> 0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<activejob>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<sinatra>.freeze, [">= 0"])
  end
end
