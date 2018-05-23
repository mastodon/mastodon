# -*- encoding: utf-8 -*-
# stub: twitter-text 1.14.7 ruby lib

Gem::Specification.new do |s|
  s.name = "twitter-text".freeze
  s.version = "1.14.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Matt Sanford".freeze, "Patrick Ewing".freeze, "Ben Cherry".freeze, "Britt Selvitelle".freeze, "Raffi Krikorian".freeze, "J.P. Cummins".freeze, "Yoshimasa Niwa".freeze, "Keita Fujii".freeze, "James Koval".freeze]
  s.date = "2017-07-03"
  s.description = "A gem that provides text handling for Twitter".freeze
  s.email = ["matt@twitter.com".freeze, "patrick.henry.ewing@gmail.com".freeze, "bcherry@gmail.com".freeze, "bs@brittspace.com".freeze, "raffi@twitter.com".freeze, "jcummins@twitter.com".freeze, "niw@niw.at".freeze, "keita@twitter.com".freeze, "jkoval@twitter.com".freeze]
  s.homepage = "http://twitter.com".freeze
  s.licenses = ["Apache 2.0".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Twitter text handling library".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
      s.add_development_dependency(%q<multi_json>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.5.10"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 11.1"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.14.0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.8.0"])
      s.add_runtime_dependency(%q<unf>.freeze, ["~> 0.1.0"])
    else
      s.add_dependency(%q<test-unit>.freeze, [">= 0"])
      s.add_dependency(%q<multi_json>.freeze, ["~> 1.3"])
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.5.10"])
      s.add_dependency(%q<rake>.freeze, ["~> 11.1"])
      s.add_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.14.0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.8.0"])
      s.add_dependency(%q<unf>.freeze, ["~> 0.1.0"])
    end
  else
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
    s.add_dependency(%q<multi_json>.freeze, ["~> 1.3"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.5.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 11.1"])
    s.add_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.14.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.8.0"])
    s.add_dependency(%q<unf>.freeze, ["~> 0.1.0"])
  end
end
