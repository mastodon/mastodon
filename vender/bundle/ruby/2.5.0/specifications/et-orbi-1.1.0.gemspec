# -*- encoding: utf-8 -*-
# stub: et-orbi 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "et-orbi".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Mettraux".freeze]
  s.date = "2018-03-25"
  s.description = "Time zones for fugit and rufus-scheduler. Urbi et Orbi.".freeze
  s.email = ["jmettraux+flor@gmail.com".freeze]
  s.homepage = "http://github.com/floraison/et-orbi".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "time with zones".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tzinfo>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.4"])
    else
      s.add_dependency(%q<tzinfo>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
    end
  else
    s.add_dependency(%q<tzinfo>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
  end
end
