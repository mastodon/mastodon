# -*- encoding: utf-8 -*-
# stub: browser 2.5.3 ruby lib

Gem::Specification.new do |s|
  s.name = "browser".freeze
  s.version = "2.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nando Vieira".freeze]
  s.date = "2018-02-27"
  s.description = "Do some browser detection with Ruby.".freeze
  s.email = ["fnando.vieira@gmail.com".freeze]
  s.homepage = "http://github.com/fnando/browser".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Do some browser detection with Ruby.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest-utils>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-meta>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest-autotest>.freeze, [">= 0"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
      s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rails>.freeze, [">= 0"])
      s.add_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<minitest-utils>.freeze, [">= 0"])
      s.add_dependency(%q<pry-meta>.freeze, [">= 0"])
      s.add_dependency(%q<minitest-autotest>.freeze, [">= 0"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
      s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 0"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<minitest-utils>.freeze, [">= 0"])
    s.add_dependency(%q<pry-meta>.freeze, [">= 0"])
    s.add_dependency(%q<minitest-autotest>.freeze, [">= 0"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
  end
end
