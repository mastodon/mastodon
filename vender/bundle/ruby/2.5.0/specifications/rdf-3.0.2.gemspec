# -*- encoding: utf-8 -*-
# stub: rdf 3.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "rdf".freeze
  s.version = "3.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Arto Bendiken".freeze, "Ben Lavender".freeze, "Gregg Kellogg".freeze]
  s.date = "2018-03-21"
  s.description = "RDF.rb is a pure-Ruby library for working with Resource Description Framework (RDF) data.".freeze
  s.email = "public-rdf-ruby@w3.org".freeze
  s.executables = ["rdf".freeze]
  s.files = ["bin/rdf".freeze]
  s.homepage = "http://ruby-rdf.github.com/".freeze
  s.licenses = ["Unlicense".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A Ruby library for working with Resource Description Framework (RDF) data.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<link_header>.freeze, [">= 0.0.8", "~> 0.0"])
      s.add_runtime_dependency(%q<hamster>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rdf-spec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rdf-turtle>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rdf-vocab>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rdf-xsd>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rest-client>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
      s.add_development_dependency(%q<rspec-its>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 3.1"])
      s.add_development_dependency(%q<yard>.freeze, ["~> 0.9.12"])
      s.add_development_dependency(%q<faraday>.freeze, ["~> 0.13"])
      s.add_development_dependency(%q<faraday_middleware>.freeze, ["~> 0.12"])
    else
      s.add_dependency(%q<link_header>.freeze, [">= 0.0.8", "~> 0.0"])
      s.add_dependency(%q<hamster>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rdf-spec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rdf-turtle>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rdf-vocab>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rdf-xsd>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rest-client>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
      s.add_dependency(%q<rspec-its>.freeze, ["~> 1.2"])
      s.add_dependency(%q<webmock>.freeze, ["~> 3.1"])
      s.add_dependency(%q<yard>.freeze, ["~> 0.9.12"])
      s.add_dependency(%q<faraday>.freeze, ["~> 0.13"])
      s.add_dependency(%q<faraday_middleware>.freeze, ["~> 0.12"])
    end
  else
    s.add_dependency(%q<link_header>.freeze, [">= 0.0.8", "~> 0.0"])
    s.add_dependency(%q<hamster>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rdf-spec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rdf-turtle>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rdf-vocab>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rdf-xsd>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rest-client>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
    s.add_dependency(%q<rspec-its>.freeze, ["~> 1.2"])
    s.add_dependency(%q<webmock>.freeze, ["~> 3.1"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.9.12"])
    s.add_dependency(%q<faraday>.freeze, ["~> 0.13"])
    s.add_dependency(%q<faraday_middleware>.freeze, ["~> 0.12"])
  end
end
