# -*- encoding: utf-8 -*-
# stub: simple-navigation 4.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "simple-navigation".freeze
  s.version = "4.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andi Schacke".freeze, "Mark J. Titorenko".freeze, "Simon Courtois".freeze]
  s.date = "2017-03-20"
  s.description = "With the simple-navigation gem installed you can easily create multilevel navigations for your Rails, Sinatra or Padrino applications. The navigation is defined in a single configuration file. It supports automatic as well as explicit highlighting of the currently active navigation through regular expressions.".freeze
  s.email = ["andi@codeplant.ch".freeze]
  s.homepage = "http://github.com/codeplant/simple-navigation".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--inline-source".freeze, "--charset=UTF-8".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "simple-navigation is a ruby library for creating navigations (with multiple levels) for your Rails, Sinatra or Padrino application.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 2.3.2"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<guard-rspec>.freeze, ["~> 4.2"])
      s.add_development_dependency(%q<memfs>.freeze, ["~> 0.4.1"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<tzinfo>.freeze, [">= 0"])
    else
      s.add_dependency(%q<activesupport>.freeze, [">= 2.3.2"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
      s.add_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, ["~> 0.7"])
      s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.2"])
      s.add_dependency(%q<memfs>.freeze, ["~> 0.4.1"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<tzinfo>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 2.3.2"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, ["~> 0.7"])
    s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.2"])
    s.add_dependency(%q<memfs>.freeze, ["~> 0.4.1"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<tzinfo>.freeze, [">= 0"])
  end
end
