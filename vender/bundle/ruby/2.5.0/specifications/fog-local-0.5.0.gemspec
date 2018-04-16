# -*- encoding: utf-8 -*-
# stub: fog-local 0.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "fog-local".freeze
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Wesley Beary".freeze, "Ville Lautanala".freeze]
  s.date = "2018-02-25"
  s.description = "This library can be used as a module for `fog` or as standalone provider\n                       to use local filesystem storage.".freeze
  s.email = ["geemus@gmail.com".freeze, "lautis@gmail.com".freeze]
  s.homepage = "https://github.com/fog/fog-local".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Module for the 'fog' gem to support local filesystem storage.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<shindo>.freeze, ["~> 0.3"])
      s.add_runtime_dependency(%q<fog-core>.freeze, ["< 3.0", ">= 1.27"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<shindo>.freeze, ["~> 0.3"])
      s.add_dependency(%q<fog-core>.freeze, ["< 3.0", ">= 1.27"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<shindo>.freeze, ["~> 0.3"])
    s.add_dependency(%q<fog-core>.freeze, ["< 3.0", ">= 1.27"])
  end
end
