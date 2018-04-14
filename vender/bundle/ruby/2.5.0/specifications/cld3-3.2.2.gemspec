# -*- encoding: utf-8 -*-
# stub: cld3 3.2.2 ruby lib
# stub: ext/cld3/extconf.rb

Gem::Specification.new do |s|
  s.name = "cld3".freeze
  s.version = "3.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Akihiko Odaki".freeze]
  s.date = "2017-12-25"
  s.description = "Compact Language Detector v3 (CLD3) is a neural network model for language identification.".freeze
  s.email = "akihiko.odaki.4i@stu.hosei.ac.jp".freeze
  s.extensions = ["ext/cld3/extconf.rb".freeze]
  s.files = ["ext/cld3/extconf.rb".freeze]
  s.homepage = "https://github.com/akihikodaki/cld3-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(["< 2.6.0".freeze, ">= 2.3.0".freeze])
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Compact Language Detector v3 (CLD3)".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>.freeze, ["< 1.10.0", ">= 1.1.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["< 3.8.0", ">= 3.0.0"])
    else
      s.add_dependency(%q<ffi>.freeze, ["< 1.10.0", ">= 1.1.0"])
      s.add_dependency(%q<rspec>.freeze, ["< 3.8.0", ">= 3.0.0"])
    end
  else
    s.add_dependency(%q<ffi>.freeze, ["< 1.10.0", ">= 1.1.0"])
    s.add_dependency(%q<rspec>.freeze, ["< 3.8.0", ">= 3.0.0"])
  end
end
