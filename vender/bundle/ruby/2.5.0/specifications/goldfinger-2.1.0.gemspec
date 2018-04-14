# -*- encoding: utf-8 -*-
# stub: goldfinger 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "goldfinger".freeze
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eugen Rochko".freeze]
  s.date = "2016-02-17"
  s.description = "A Webfinger utility for Ruby".freeze
  s.email = "eugen@zeonfederated.com".freeze
  s.homepage = "https://github.com/Gargron/goldfinger".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A Webfinger utility for Ruby".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<http>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.5"])
      s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.8"])
      s.add_runtime_dependency(%q<oj>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.15"])
    else
      s.add_dependency(%q<http>.freeze, ["~> 3.0"])
      s.add_dependency(%q<addressable>.freeze, ["~> 2.5"])
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.8"])
      s.add_dependency(%q<oj>.freeze, ["~> 3.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.15"])
    end
  else
    s.add_dependency(%q<http>.freeze, ["~> 3.0"])
    s.add_dependency(%q<addressable>.freeze, ["~> 2.5"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.8"])
    s.add_dependency(%q<oj>.freeze, ["~> 3.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.15"])
  end
end
