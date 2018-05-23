# -*- encoding: utf-8 -*-
# stub: thor 0.20.0 ruby lib

Gem::Specification.new do |s|
  s.name = "thor".freeze
  s.version = "0.20.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yehuda Katz".freeze, "Jos\u00E9 Valim".freeze]
  s.date = "2017-08-16"
  s.description = "Thor is a toolkit for building powerful command-line interfaces.".freeze
  s.email = "ruby-thor@googlegroups.com".freeze
  s.executables = ["thor".freeze]
  s.files = ["bin/thor".freeze]
  s.homepage = "http://whatisthor.com/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Thor is a toolkit for building powerful command-line interfaces.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
  end
end
