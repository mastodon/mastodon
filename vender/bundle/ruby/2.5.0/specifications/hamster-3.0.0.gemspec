# -*- encoding: utf-8 -*-
# stub: hamster 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hamster".freeze
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Simon Harris".freeze]
  s.date = "2016-02-20"
  s.description = "Efficient, immutable, thread-safe collection classes for Ruby".freeze
  s.email = ["haruki_zaemon@mac.com".freeze]
  s.homepage = "https://github.com/hamstergem/hamster".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Efficient, immutable, thread-safe collection classes for Ruby".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.1"])
      s.add_development_dependency(%q<yard>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<pry-doc>.freeze, ["~> 0.6"])
      s.add_development_dependency(%q<benchmark-ips>.freeze, ["~> 2.1"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, ["~> 0.4"])
    else
      s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.1"])
      s.add_dependency(%q<yard>.freeze, ["~> 0.8"])
      s.add_dependency(%q<pry>.freeze, ["~> 0.9"])
      s.add_dependency(%q<pry-doc>.freeze, ["~> 0.6"])
      s.add_dependency(%q<benchmark-ips>.freeze, ["~> 2.1"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, ["~> 0.4"])
    end
  else
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.1"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.8"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.9"])
    s.add_dependency(%q<pry-doc>.freeze, ["~> 0.6"])
    s.add_dependency(%q<benchmark-ips>.freeze, ["~> 2.1"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, ["~> 0.4"])
  end
end
