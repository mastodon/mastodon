# -*- encoding: utf-8 -*-
# stub: strong_migrations 0.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "strong_migrations".freeze
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bob Remeika".freeze, "David Waller".freeze, "Andrew Kane".freeze]
  s.bindir = "exe".freeze
  s.date = "2018-02-14"
  s.email = ["bob.remeika@gmail.com".freeze, "andrew@chartkick.com".freeze]
  s.homepage = "https://github.com/ankane/strong_migrations".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Catch unsafe migrations at dev time".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>.freeze, [">= 3.2.0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<pg>.freeze, ["< 1"])
    else
      s.add_dependency(%q<activerecord>.freeze, [">= 3.2.0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<pg>.freeze, ["< 1"])
    end
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 3.2.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<pg>.freeze, ["< 1"])
  end
end
