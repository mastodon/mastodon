# -*- encoding: utf-8 -*-
# stub: sanitize 4.6.4 ruby lib

Gem::Specification.new do |s|
  s.name = "sanitize".freeze
  s.version = "4.6.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2.0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Grove".freeze]
  s.date = "2018-03-20"
  s.description = "Sanitize is a whitelist-based HTML and CSS sanitizer. Given a list of acceptable elements, attributes, and CSS properties, Sanitize will remove all unacceptable HTML and/or CSS from a string.".freeze
  s.email = "ryan@wonko.com".freeze
  s.homepage = "https://github.com/rgrove/sanitize/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Whitelist-based HTML and CSS sanitizer.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<crass>.freeze, ["~> 1.0.2"])
      s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.4.4"])
      s.add_runtime_dependency(%q<nokogumbo>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.10.2"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.0.0"])
    else
      s.add_dependency(%q<crass>.freeze, ["~> 1.0.2"])
      s.add_dependency(%q<nokogiri>.freeze, [">= 1.4.4"])
      s.add_dependency(%q<nokogumbo>.freeze, ["~> 1.4"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.10.2"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.0.0"])
    end
  else
    s.add_dependency(%q<crass>.freeze, ["~> 1.0.2"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.4.4"])
    s.add_dependency(%q<nokogumbo>.freeze, ["~> 1.4"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.10.2"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0.0"])
  end
end
