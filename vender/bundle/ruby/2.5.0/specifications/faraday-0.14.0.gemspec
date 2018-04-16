# -*- encoding: utf-8 -*-
# stub: faraday 0.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday".freeze
  s.version = "0.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rick Olson".freeze]
  s.date = "2018-01-19"
  s.email = "technoweenie@gmail.com".freeze
  s.homepage = "https://github.com/lostisland/faraday".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "HTTP/REST API client library.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multipart-post>.freeze, ["< 3", ">= 1.2"])
    else
      s.add_dependency(%q<multipart-post>.freeze, ["< 3", ">= 1.2"])
    end
  else
    s.add_dependency(%q<multipart-post>.freeze, ["< 3", ">= 1.2"])
  end
end
