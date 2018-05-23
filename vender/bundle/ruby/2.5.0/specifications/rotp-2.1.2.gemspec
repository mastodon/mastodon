# -*- encoding: utf-8 -*-
# stub: rotp 2.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "rotp".freeze
  s.version = "2.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mark Percival".freeze]
  s.date = "2016-04-12"
  s.description = "Works for both HOTP and TOTP, and includes QR Code provisioning".freeze
  s.email = ["mark@markpercival.us".freeze]
  s.executables = ["rotp".freeze]
  s.files = ["bin/rotp".freeze]
  s.homepage = "http://github.com/mdp/rotp".freeze
  s.licenses = ["MIT".freeze]
  s.rubyforge_project = "rotp".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A Ruby library for generating and verifying one time passwords".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<guard-rspec>.freeze, ["~> 4.5"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.4"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.1"])
      s.add_development_dependency(%q<timecop>.freeze, ["~> 0.7"])
    else
      s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.5"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.4"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.1"])
      s.add_dependency(%q<timecop>.freeze, ["~> 0.7"])
    end
  else
    s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.5"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.4"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.1"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.7"])
  end
end
