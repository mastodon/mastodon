# -*- encoding: utf-8 -*-
# stub: doorkeeper 4.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "doorkeeper".freeze
  s.version = "4.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Felipe Elias Philipp".freeze, "Tute Costa".freeze, "Jon Moss".freeze, "Nikita Bulai".freeze]
  s.date = "2018-03-28"
  s.description = "Doorkeeper is an OAuth 2 provider for Rails and Grape.".freeze
  s.email = ["bulaj.nikita@gmail.com".freeze]
  s.homepage = "https://github.com/doorkeeper-gem/doorkeeper".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "OAuth 2 provider for Rails and Grape".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 4.2"])
      s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_development_dependency(%q<grape>.freeze, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<factory_bot>.freeze, ["~> 4.8"])
      s.add_development_dependency(%q<generator_spec>.freeze, ["~> 0.9.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 11.3.0"])
      s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 4.2"])
      s.add_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<grape>.freeze, [">= 0"])
      s.add_dependency(%q<database_cleaner>.freeze, ["~> 1.6"])
      s.add_dependency(%q<factory_bot>.freeze, ["~> 4.8"])
      s.add_dependency(%q<generator_spec>.freeze, ["~> 0.9.3"])
      s.add_dependency(%q<rake>.freeze, [">= 11.3.0"])
      s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 4.2"])
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<grape>.freeze, [">= 0"])
    s.add_dependency(%q<database_cleaner>.freeze, ["~> 1.6"])
    s.add_dependency(%q<factory_bot>.freeze, ["~> 4.8"])
    s.add_dependency(%q<generator_spec>.freeze, ["~> 0.9.3"])
    s.add_dependency(%q<rake>.freeze, [">= 11.3.0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
  end
end
