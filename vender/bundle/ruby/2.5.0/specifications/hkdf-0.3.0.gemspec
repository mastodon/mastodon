# -*- encoding: utf-8 -*-
# stub: hkdf 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hkdf".freeze
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Downey".freeze]
  s.date = "2016-11-09"
  s.description = "A ruby implementation of RFC5869: HMAC-based Extract-and-Expand Key Derivation Function (HKDF). The goal of HKDF is to take some source key material and generate suitable cryptographic keys from it.".freeze
  s.email = ["jdowney@gmail.com".freeze]
  s.homepage = "http://github.com/jtdowney/hkdf".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "HMAC-based Key Derivation Function".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rake>.freeze, ["= 10.5.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["= 3.4.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rake>.freeze, ["= 10.5.0"])
      s.add_dependency(%q<rspec>.freeze, ["= 3.4.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rake>.freeze, ["= 10.5.0"])
    s.add_dependency(%q<rspec>.freeze, ["= 3.4.0"])
  end
end
