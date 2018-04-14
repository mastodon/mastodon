# -*- encoding: utf-8 -*-
# stub: crass 1.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "crass".freeze
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Grove".freeze]
  s.date = "2017-11-13"
  s.description = "Crass is a pure Ruby CSS parser based on the CSS Syntax Level 3 spec.".freeze
  s.email = ["ryan@wonko.com".freeze]
  s.homepage = "https://github.com/rgrove/crass/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "CSS parser based on the CSS Syntax Level 3 spec.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0.8"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.1.0"])
    else
      s.add_dependency(%q<minitest>.freeze, ["~> 5.0.8"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.1.0"])
    end
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0.8"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.1.0"])
  end
end
