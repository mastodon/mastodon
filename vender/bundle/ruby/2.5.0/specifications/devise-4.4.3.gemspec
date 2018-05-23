# -*- encoding: utf-8 -*-
# stub: devise 4.4.3 ruby lib

Gem::Specification.new do |s|
  s.name = "devise".freeze
  s.version = "4.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jos\u00E9 Valim".freeze, "Carlos Ant\u00F4nio".freeze]
  s.date = "2018-03-18"
  s.description = "Flexible authentication solution for Rails with Warden".freeze
  s.email = "contact@plataformatec.com.br".freeze
  s.homepage = "https://github.com/plataformatec/devise".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Flexible authentication solution for Rails with Warden".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<warden>.freeze, ["~> 1.2.3"])
      s.add_runtime_dependency(%q<orm_adapter>.freeze, ["~> 0.1"])
      s.add_runtime_dependency(%q<bcrypt>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<railties>.freeze, ["< 6.0", ">= 4.1.0"])
      s.add_runtime_dependency(%q<responders>.freeze, [">= 0"])
    else
      s.add_dependency(%q<warden>.freeze, ["~> 1.2.3"])
      s.add_dependency(%q<orm_adapter>.freeze, ["~> 0.1"])
      s.add_dependency(%q<bcrypt>.freeze, ["~> 3.0"])
      s.add_dependency(%q<railties>.freeze, ["< 6.0", ">= 4.1.0"])
      s.add_dependency(%q<responders>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<warden>.freeze, ["~> 1.2.3"])
    s.add_dependency(%q<orm_adapter>.freeze, ["~> 0.1"])
    s.add_dependency(%q<bcrypt>.freeze, ["~> 3.0"])
    s.add_dependency(%q<railties>.freeze, ["< 6.0", ">= 4.1.0"])
    s.add_dependency(%q<responders>.freeze, [">= 0"])
  end
end
