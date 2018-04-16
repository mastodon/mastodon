# -*- encoding: utf-8 -*-
# stub: sidekiq 5.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "sidekiq".freeze
  s.version = "5.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Perham".freeze]
  s.date = "2018-04-02"
  s.description = "Simple, efficient background processing for Ruby.".freeze
  s.email = ["mperham@gmail.com".freeze]
  s.executables = ["sidekiq".freeze, "sidekiqctl".freeze]
  s.files = ["bin/sidekiq".freeze, "bin/sidekiqctl".freeze]
  s.homepage = "http://sidekiq.org".freeze
  s.licenses = ["LGPL-3.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Simple, efficient background processing for Ruby".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>.freeze, ["< 5", ">= 3.3.5"])
      s.add_runtime_dependency(%q<connection_pool>.freeze, [">= 2.2.0", "~> 2.2"])
      s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<rack-protection>.freeze, [">= 1.5.0"])
      s.add_development_dependency(%q<redis-namespace>.freeze, [">= 1.5.2", "~> 1.5"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 5.10.1", "~> 5.10"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rails>.freeze, [">= 3.2.0"])
    else
      s.add_dependency(%q<redis>.freeze, ["< 5", ">= 3.3.5"])
      s.add_dependency(%q<connection_pool>.freeze, [">= 2.2.0", "~> 2.2"])
      s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rack-protection>.freeze, [">= 1.5.0"])
      s.add_dependency(%q<redis-namespace>.freeze, [">= 1.5.2", "~> 1.5"])
      s.add_dependency(%q<minitest>.freeze, [">= 5.10.1", "~> 5.10"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rails>.freeze, [">= 3.2.0"])
    end
  else
    s.add_dependency(%q<redis>.freeze, ["< 5", ">= 3.3.5"])
    s.add_dependency(%q<connection_pool>.freeze, [">= 2.2.0", "~> 2.2"])
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rack-protection>.freeze, [">= 1.5.0"])
    s.add_dependency(%q<redis-namespace>.freeze, [">= 1.5.2", "~> 1.5"])
    s.add_dependency(%q<minitest>.freeze, [">= 5.10.1", "~> 5.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rails>.freeze, [">= 3.2.0"])
  end
end
