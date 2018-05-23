# -*- encoding: utf-8 -*-
# stub: formatador 0.2.5 ruby lib

Gem::Specification.new do |s|
  s.name = "formatador".freeze
  s.version = "0.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["geemus (Wesley Beary)".freeze]
  s.date = "2014-05-23"
  s.description = "STDOUT text formatting".freeze
  s.email = "geemus@gmail.com".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze]
  s.files = ["README.rdoc".freeze]
  s.homepage = "http://github.com/geemus/formatador".freeze
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubyforge_project = "formatador".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Ruby STDOUT text formatting".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<shindo>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<shindo>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<shindo>.freeze, [">= 0"])
  end
end
