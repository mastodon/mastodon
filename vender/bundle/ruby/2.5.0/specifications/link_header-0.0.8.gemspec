# -*- encoding: utf-8 -*-
# stub: link_header 0.0.8 ruby lib

Gem::Specification.new do |s|
  s.name = "link_header".freeze
  s.version = "0.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Burrows".freeze]
  s.date = "2013-12-04"
  s.description = "Converts conforming link headers to and from text, LinkHeader objects and corresponding (JSON-friendly) Array representations, also HTML link elements.".freeze
  s.email = ["mjb@asplake.co.uk".freeze]
  s.homepage = "https://github.com/asplake/link_header".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Converts conforming link headers to and from text, LinkHeader objects and corresponding (JSON-friendly) Array representations, also HTML link elements.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
