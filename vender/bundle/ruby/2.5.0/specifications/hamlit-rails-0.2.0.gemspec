# -*- encoding: utf-8 -*-
# stub: hamlit-rails 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hamlit-rails".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Meng Fung".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-01-31"
  s.description = "hamlit-rails provides generators for Rails 4.".freeze
  s.email = ["meng.fung@gmail.com".freeze]
  s.homepage = "https://github.com/mfung/hamlit-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "hamlit and rails".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hamlit>.freeze, [">= 1.2.0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.0.1"])
      s.add_runtime_dependency(%q<actionpack>.freeze, [">= 4.0.1"])
      s.add_runtime_dependency(%q<railties>.freeze, [">= 4.0.1"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.9"])
      s.add_development_dependency(%q<html2haml>.freeze, [">= 2.0.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rails>.freeze, [">= 4.0.1"])
      s.add_development_dependency(%q<appraisal>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.7"])
    else
      s.add_dependency(%q<hamlit>.freeze, [">= 1.2.0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 4.0.1"])
      s.add_dependency(%q<actionpack>.freeze, [">= 4.0.1"])
      s.add_dependency(%q<railties>.freeze, [">= 4.0.1"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.9"])
      s.add_dependency(%q<html2haml>.freeze, [">= 2.0.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rails>.freeze, [">= 4.0.1"])
      s.add_dependency(%q<appraisal>.freeze, ["~> 1.0"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.7"])
    end
  else
    s.add_dependency(%q<hamlit>.freeze, [">= 1.2.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 4.0.1"])
    s.add_dependency(%q<actionpack>.freeze, [">= 4.0.1"])
    s.add_dependency(%q<railties>.freeze, [">= 4.0.1"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.9"])
    s.add_dependency(%q<html2haml>.freeze, [">= 2.0.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rails>.freeze, [">= 4.0.1"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 1.0"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.7"])
  end
end
