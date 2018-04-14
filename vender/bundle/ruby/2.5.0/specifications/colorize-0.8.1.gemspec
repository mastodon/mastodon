# -*- encoding: utf-8 -*-
# stub: colorize 0.8.1 ruby lib

Gem::Specification.new do |s|
  s.name = "colorize".freeze
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Micha\u0142 Kalbarczyk".freeze]
  s.date = "2016-06-29"
  s.description = "Extends String class or add a ColorizedString with methods to set text color, background color and text effects.".freeze
  s.email = "fazibear@gmail.com".freeze
  s.homepage = "http://github.com/fazibear/colorize".freeze
  s.licenses = ["GPL-2.0".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Ruby gem for colorizing text using ANSI escape sequences.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, ["~> 0.4"])
    else
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, ["~> 0.4"])
    end
  else
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, ["~> 0.4"])
  end
end
