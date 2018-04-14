# -*- encoding: utf-8 -*-
# stub: mimemagic 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "mimemagic".freeze
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Mendler".freeze]
  s.date = "2016-08-02"
  s.description = "Fast mime detection by extension or content in pure ruby (Uses freedesktop.org.xml shared-mime-info database)".freeze
  s.email = ["mail@daniel-mendler.de".freeze]
  s.homepage = "https://github.com/minad/mimemagic".freeze
  s.licenses = ["MIT".freeze]
  s.rubyforge_project = "mimemagic".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Fast mime detection by extension or content".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bacon>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bacon>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bacon>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
