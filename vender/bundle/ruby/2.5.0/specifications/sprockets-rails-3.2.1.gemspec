# -*- encoding: utf-8 -*-
# stub: sprockets-rails 3.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sprockets-rails".freeze
  s.version = "3.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joshua Peek".freeze]
  s.date = "2017-08-31"
  s.email = "josh@joshpeek.com".freeze
  s.homepage = "https://github.com/rails/sprockets-rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Sprockets Rails integration".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sprockets>.freeze, [">= 3.0.0"])
      s.add_runtime_dependency(%q<actionpack>.freeze, [">= 4.0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.0"])
      s.add_development_dependency(%q<railties>.freeze, [">= 4.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<sass>.freeze, [">= 0"])
      s.add_development_dependency(%q<uglifier>.freeze, [">= 0"])
    else
      s.add_dependency(%q<sprockets>.freeze, [">= 3.0.0"])
      s.add_dependency(%q<actionpack>.freeze, [">= 4.0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 4.0"])
      s.add_dependency(%q<railties>.freeze, [">= 4.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<sass>.freeze, [">= 0"])
      s.add_dependency(%q<uglifier>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<sprockets>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<actionpack>.freeze, [">= 4.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 4.0"])
    s.add_dependency(%q<railties>.freeze, [">= 4.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<sass>.freeze, [">= 0"])
    s.add_dependency(%q<uglifier>.freeze, [">= 0"])
  end
end
