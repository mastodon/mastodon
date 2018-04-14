# -*- encoding: utf-8 -*-
# stub: hiredis 0.6.1 ruby lib
# stub: ext/hiredis_ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "hiredis".freeze
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Pieter Noordhuis".freeze]
  s.date = "2015-12-29"
  s.description = "Ruby wrapper for hiredis (protocol serialization/deserialization and blocking I/O)".freeze
  s.email = ["pcnoordhuis@gmail.com".freeze]
  s.extensions = ["ext/hiredis_ext/extconf.rb".freeze]
  s.files = ["ext/hiredis_ext/extconf.rb".freeze]
  s.homepage = "http://github.com/redis/hiredis-rb".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Ruby wrapper for hiredis (protocol serialization/deserialization and blocking I/O)".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, ["= 10.0"])
      s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 0.7.1"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.5.1"])
    else
      s.add_dependency(%q<rake>.freeze, ["= 10.0"])
      s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.7.1"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.5.1"])
    end
  else
    s.add_dependency(%q<rake>.freeze, ["= 10.0"])
    s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.7.1"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.5.1"])
  end
end
