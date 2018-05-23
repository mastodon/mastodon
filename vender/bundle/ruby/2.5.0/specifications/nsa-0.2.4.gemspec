# -*- encoding: utf-8 -*-
# stub: nsa 0.2.4 ruby lib

Gem::Specification.new do |s|
  s.name = "nsa".freeze
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["BJ Neilsen".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-06-14"
  s.description = "Listen to your Rails ActiveSupport::Notifications and deliver to a Statsd backend.".freeze
  s.email = ["bj.neilsen@gmail.com".freeze]
  s.homepage = "https://www.github.com/localshred/nsa".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Listen to your Rails ActiveSupport::Notifications and deliver to a Statsd backend.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.2"])
      s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<sidekiq>.freeze, [">= 3.5.0"])
      s.add_runtime_dependency(%q<statsd-ruby>.freeze, ["~> 1.2.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
      s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.2"])
      s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0.0"])
      s.add_dependency(%q<sidekiq>.freeze, [">= 3.5.0"])
      s.add_dependency(%q<statsd-ruby>.freeze, ["~> 1.2.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<mocha>.freeze, [">= 0"])
      s.add_dependency(%q<byebug>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.2"])
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0.0"])
    s.add_dependency(%q<sidekiq>.freeze, [">= 3.5.0"])
    s.add_dependency(%q<statsd-ruby>.freeze, ["~> 1.2.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<mocha>.freeze, [">= 0"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
  end
end
