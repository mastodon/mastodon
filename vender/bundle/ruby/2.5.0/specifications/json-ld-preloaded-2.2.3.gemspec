# -*- encoding: utf-8 -*-
# stub: json-ld-preloaded 2.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "json-ld-preloaded".freeze
  s.version = "2.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gregg Kellogg".freeze]
  s.date = "2017-12-13"
  s.description = "A meta-release of the json-ld gem including preloaded vocabularies.".freeze
  s.email = "public-linked-json@w3.org".freeze
  s.homepage = "http://github.com/ruby-rdf/json-ld-preloaded".freeze
  s.licenses = ["Unlicense".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "JSON-LD with preloaded contexts.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rdf>.freeze, ["< 4.0", ">= 2.2"])
      s.add_runtime_dependency(%q<json-ld>.freeze, ["< 4.0", ">= 2.2"])
      s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.12"])
      s.add_development_dependency(%q<oj>.freeze, ["~> 2.18"])
      s.add_development_dependency(%q<rdf-turtle>.freeze, ["< 4.0", ">= 2.2"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
      s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
    else
      s.add_dependency(%q<rdf>.freeze, ["< 4.0", ">= 2.2"])
      s.add_dependency(%q<json-ld>.freeze, ["< 4.0", ">= 2.2"])
      s.add_dependency(%q<multi_json>.freeze, ["~> 1.12"])
      s.add_dependency(%q<oj>.freeze, ["~> 2.18"])
      s.add_dependency(%q<rdf-turtle>.freeze, ["< 4.0", ">= 2.2"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
      s.add_dependency(%q<yard>.freeze, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<rdf>.freeze, ["< 4.0", ">= 2.2"])
    s.add_dependency(%q<json-ld>.freeze, ["< 4.0", ">= 2.2"])
    s.add_dependency(%q<multi_json>.freeze, ["~> 1.12"])
    s.add_dependency(%q<oj>.freeze, ["~> 2.18"])
    s.add_dependency(%q<rdf-turtle>.freeze, ["< 4.0", ">= 2.2"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.9"])
  end
end
