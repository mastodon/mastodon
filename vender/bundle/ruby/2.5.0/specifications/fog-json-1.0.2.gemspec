# -*- encoding: utf-8 -*-
# stub: fog-json 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "fog-json".freeze
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Wesley Beary (geemus)".freeze, "Paul Thornthwaite (tokengeek)".freeze, "The fog team".freeze]
  s.date = "2015-05-30"
  s.description = "Extraction of the JSON parsing tools shared between a\n                          number of providers in the 'fog' gem.".freeze
  s.email = ["geemus@gmail.com".freeze, "tokengeek@gmail.com".freeze]
  s.homepage = "http://github.com/fog/fog-json".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "JSON parsing for fog providers".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fog-core>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.10"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    else
      s.add_dependency(%q<fog-core>.freeze, ["~> 1.0"])
      s.add_dependency(%q<multi_json>.freeze, ["~> 1.10"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<fog-core>.freeze, ["~> 1.0"])
    s.add_dependency(%q<multi_json>.freeze, ["~> 1.10"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
  end
end
