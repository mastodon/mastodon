# -*- encoding: utf-8 -*-
# stub: elasticsearch 6.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "elasticsearch".freeze
  s.version = "6.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Karel Minarik".freeze]
  s.date = "2018-03-22"
  s.description = "Ruby integrations for Elasticsearch (client, API, etc.)\n".freeze
  s.email = ["karel.minarik@elasticsearch.org".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "LICENSE.txt".freeze]
  s.files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "http://github.com/elasticsearch/elasticsearch-ruby".freeze
  s.licenses = ["Apache 2".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Ruby integrations for Elasticsearch".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<elasticsearch-transport>.freeze, ["= 6.0.2"])
      s.add_runtime_dependency(%q<elasticsearch-api>.freeze, ["= 6.0.2"])
      s.add_development_dependency(%q<bundler>.freeze, ["> 1"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 11.1"])
      s.add_development_dependency(%q<elasticsearch-extensions>.freeze, [">= 0"])
      s.add_development_dependency(%q<ansi>.freeze, [">= 0"])
      s.add_development_dependency(%q<shoulda-context>.freeze, [">= 0"])
      s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
      s.add_development_dependency(%q<turn>.freeze, [">= 0"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<ruby-prof>.freeze, [">= 0"])
      s.add_development_dependency(%q<require-prof>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
      s.add_development_dependency(%q<cane>.freeze, [">= 0"])
      s.add_development_dependency(%q<test-unit>.freeze, ["~> 2"])
    else
      s.add_dependency(%q<elasticsearch-transport>.freeze, ["= 6.0.2"])
      s.add_dependency(%q<elasticsearch-api>.freeze, ["= 6.0.2"])
      s.add_dependency(%q<bundler>.freeze, ["> 1"])
      s.add_dependency(%q<rake>.freeze, ["~> 11.1"])
      s.add_dependency(%q<elasticsearch-extensions>.freeze, [">= 0"])
      s.add_dependency(%q<ansi>.freeze, [">= 0"])
      s.add_dependency(%q<shoulda-context>.freeze, [">= 0"])
      s.add_dependency(%q<mocha>.freeze, [">= 0"])
      s.add_dependency(%q<turn>.freeze, [">= 0"])
      s.add_dependency(%q<yard>.freeze, [">= 0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 4.0"])
      s.add_dependency(%q<ruby-prof>.freeze, [">= 0"])
      s.add_dependency(%q<require-prof>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
      s.add_dependency(%q<cane>.freeze, [">= 0"])
      s.add_dependency(%q<test-unit>.freeze, ["~> 2"])
    end
  else
    s.add_dependency(%q<elasticsearch-transport>.freeze, ["= 6.0.2"])
    s.add_dependency(%q<elasticsearch-api>.freeze, ["= 6.0.2"])
    s.add_dependency(%q<bundler>.freeze, ["> 1"])
    s.add_dependency(%q<rake>.freeze, ["~> 11.1"])
    s.add_dependency(%q<elasticsearch-extensions>.freeze, [">= 0"])
    s.add_dependency(%q<ansi>.freeze, [">= 0"])
    s.add_dependency(%q<shoulda-context>.freeze, [">= 0"])
    s.add_dependency(%q<mocha>.freeze, [">= 0"])
    s.add_dependency(%q<turn>.freeze, [">= 0"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 4.0"])
    s.add_dependency(%q<ruby-prof>.freeze, [">= 0"])
    s.add_dependency(%q<require-prof>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
    s.add_dependency(%q<cane>.freeze, [">= 0"])
    s.add_dependency(%q<test-unit>.freeze, ["~> 2"])
  end
end
