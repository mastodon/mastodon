# -*- encoding: utf-8 -*-
# stub: ipaddress 0.8.3 ruby lib

Gem::Specification.new do |s|
  s.name = "ipaddress".freeze
  s.version = "0.8.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["bluemonk".freeze, "mikemackintosh".freeze]
  s.date = "2016-02-17"
  s.description = "IPAddress is a Ruby library designed to make manipulation \n      of IPv4 and IPv6 addresses both powerful and simple. It mantains\n      a layer of compatibility with Ruby's own IPAddr, while \n      addressing many of its issues.".freeze
  s.email = ["ceresa@gmail.com".freeze]
  s.homepage = "https://github.com/bluemonk/ipaddress".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "IPv4/IPv6 address manipulation library".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
