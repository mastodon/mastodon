# -*- encoding: utf-8 -*-
# stub: webpush 0.3.3 ruby lib

Gem::Specification.new do |s|
  s.name = "webpush".freeze
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["zaru@sakuraba".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-11-06"
  s.email = ["zarutofu@gmail.com".freeze]
  s.homepage = "https://github.com/zaru/webpush".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Encryption Utilities for Web Push payload.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hkdf>.freeze, ["~> 0.2"])
      s.add_runtime_dependency(%q<jwt>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.11"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 1.24"])
      s.add_development_dependency(%q<ece>.freeze, ["~> 0.2"])
    else
      s.add_dependency(%q<hkdf>.freeze, ["~> 0.2"])
      s.add_dependency(%q<jwt>.freeze, ["~> 2.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.11"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<webmock>.freeze, ["~> 1.24"])
      s.add_dependency(%q<ece>.freeze, ["~> 0.2"])
    end
  else
    s.add_dependency(%q<hkdf>.freeze, ["~> 0.2"])
    s.add_dependency(%q<jwt>.freeze, ["~> 2.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.11"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<webmock>.freeze, ["~> 1.24"])
    s.add_dependency(%q<ece>.freeze, ["~> 0.2"])
  end
end
