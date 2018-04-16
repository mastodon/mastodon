# -*- encoding: utf-8 -*-
# stub: rdf-normalize 0.3.3 ruby lib

Gem::Specification.new do |s|
  s.name = "rdf-normalize".freeze
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gregg Kellogg".freeze]
  s.date = "2017-12-13"
  s.description = "RDF::Normalize is a Graph normalizer for the RDF.rb library suite.".freeze
  s.email = "public-rdf-ruby@w3.org".freeze
  s.homepage = "http://github.com/gkellogg/rdf-normalize".freeze
  s.licenses = ["Unlicense".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubyforge_project = "rdf-normalize".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "RDF Graph normalizer for Ruby.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rdf>.freeze, ["< 4.0", ">= 2.2"])
      s.add_development_dependency(%q<rdf-spec>.freeze, ["< 4.0", ">= 2.2"])
      s.add_development_dependency(%q<open-uri-cached>.freeze, [">= 0.0.5", "~> 0.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<json-ld>.freeze, ["< 4.0", ">= 2.1"])
      s.add_development_dependency(%q<yard>.freeze, ["~> 0.0"])
    else
      s.add_dependency(%q<rdf>.freeze, ["< 4.0", ">= 2.2"])
      s.add_dependency(%q<rdf-spec>.freeze, ["< 4.0", ">= 2.2"])
      s.add_dependency(%q<open-uri-cached>.freeze, [">= 0.0.5", "~> 0.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
      s.add_dependency(%q<webmock>.freeze, ["~> 3.0"])
      s.add_dependency(%q<json-ld>.freeze, ["< 4.0", ">= 2.1"])
      s.add_dependency(%q<yard>.freeze, ["~> 0.0"])
    end
  else
    s.add_dependency(%q<rdf>.freeze, ["< 4.0", ">= 2.2"])
    s.add_dependency(%q<rdf-spec>.freeze, ["< 4.0", ">= 2.2"])
    s.add_dependency(%q<open-uri-cached>.freeze, [">= 0.0.5", "~> 0.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
    s.add_dependency(%q<webmock>.freeze, ["~> 3.0"])
    s.add_dependency(%q<json-ld>.freeze, ["< 4.0", ">= 2.1"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.0"])
  end
end
