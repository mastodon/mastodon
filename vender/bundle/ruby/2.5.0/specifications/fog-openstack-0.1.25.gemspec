# -*- encoding: utf-8 -*-
# stub: fog-openstack 0.1.25 ruby lib

Gem::Specification.new do |s|
  s.name = "fog-openstack".freeze
  s.version = "0.1.25"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Matt Darby".freeze]
  s.bindir = "exe".freeze
  s.date = "2018-03-20"
  s.description = "OpenStack fog provider gem.".freeze
  s.email = ["matt.darby@rackspace.com".freeze]
  s.homepage = "https://github.com/fog/fog-openstack".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "OpenStack fog provider gem".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fog-core>.freeze, ["~> 1.40"])
      s.add_runtime_dependency(%q<fog-json>.freeze, [">= 1.0"])
      s.add_runtime_dependency(%q<ipaddress>.freeze, [">= 0.8"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_development_dependency(%q<mime-types>.freeze, [">= 0"])
      s.add_development_dependency(%q<mime-types-data>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_development_dependency(%q<shindo>.freeze, ["~> 0.3"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<vcr>.freeze, [">= 0"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 1.24.6"])
    else
      s.add_dependency(%q<fog-core>.freeze, ["~> 1.40"])
      s.add_dependency(%q<fog-json>.freeze, [">= 1.0"])
      s.add_dependency(%q<ipaddress>.freeze, [">= 0.8"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.6"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<mime-types>.freeze, [">= 0"])
      s.add_dependency(%q<mime-types-data>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_dependency(%q<shindo>.freeze, ["~> 0.3"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<vcr>.freeze, [">= 0"])
      s.add_dependency(%q<webmock>.freeze, ["~> 1.24.6"])
    end
  else
    s.add_dependency(%q<fog-core>.freeze, ["~> 1.40"])
    s.add_dependency(%q<fog-json>.freeze, [">= 1.0"])
    s.add_dependency(%q<ipaddress>.freeze, [">= 0.8"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.6"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<mime-types>.freeze, [">= 0"])
    s.add_dependency(%q<mime-types-data>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<shindo>.freeze, ["~> 0.3"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<vcr>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, ["~> 1.24.6"])
  end
end
