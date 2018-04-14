# -*- encoding: utf-8 -*-
# stub: http-form_data 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "http-form_data".freeze
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Aleksey V Zapparov".freeze]
  s.date = "2018-03-04"
  s.description = "Utility-belt to build form data request bodies. Provides support for `application/x-www-form-urlencoded` and `multipart/form-data` types.".freeze
  s.email = ["ixti@member.fsf.org".freeze]
  s.homepage = "https://github.com/httprb/form_data.rb".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "http-form_data-2.1.0".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
  end
end
