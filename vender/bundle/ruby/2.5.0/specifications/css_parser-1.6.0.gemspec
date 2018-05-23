# -*- encoding: utf-8 -*-
# stub: css_parser 1.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "css_parser".freeze
  s.version = "1.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Dunae".freeze]
  s.date = "2017-09-08"
  s.description = "A set of classes for parsing CSS in Ruby.".freeze
  s.email = "code@dunae.ca".freeze
  s.homepage = "https://github.com/premailer/css_parser".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Ruby CSS parser.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>.freeze, [">= 0"])
    else
      s.add_dependency(%q<addressable>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<addressable>.freeze, [">= 0"])
  end
end
