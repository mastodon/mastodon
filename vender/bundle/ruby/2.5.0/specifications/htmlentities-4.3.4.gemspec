# -*- encoding: utf-8 -*-
# stub: htmlentities 4.3.4 ruby lib

Gem::Specification.new do |s|
  s.name = "htmlentities".freeze
  s.version = "4.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Paul Battley".freeze]
  s.date = "2015-07-05"
  s.description = "A module for encoding and decoding (X)HTML entities.".freeze
  s.email = "pbattley@gmail.com".freeze
  s.extra_rdoc_files = ["History.txt".freeze, "COPYING.txt".freeze]
  s.files = ["COPYING.txt".freeze, "History.txt".freeze]
  s.homepage = "https://github.com/threedaymonk/htmlentities".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Encode/decode HTML entities".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, ["~> 0"])
    else
      s.add_dependency(%q<rake>.freeze, ["~> 0"])
    end
  else
    s.add_dependency(%q<rake>.freeze, ["~> 0"])
  end
end
