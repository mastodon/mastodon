# -*- encoding: utf-8 -*-
# stub: temple 0.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "temple".freeze
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Magnus Holm".freeze, "Daniel Mendler".freeze]
  s.date = "2017-02-12"
  s.email = ["judofyr@gmail.com".freeze, "mail@daniel-mendler.de".freeze]
  s.homepage = "https://github.com/judofyr/temple".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Template compilation framework in Ruby".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<tilt>.freeze, [">= 0"])
      s.add_development_dependency(%q<bacon>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<erubis>.freeze, [">= 0"])
    else
      s.add_dependency(%q<tilt>.freeze, [">= 0"])
      s.add_dependency(%q<bacon>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<erubis>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<tilt>.freeze, [">= 0"])
    s.add_dependency(%q<bacon>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<erubis>.freeze, [">= 0"])
  end
end
