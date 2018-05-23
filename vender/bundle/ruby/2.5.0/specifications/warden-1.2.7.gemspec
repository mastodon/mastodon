# -*- encoding: utf-8 -*-
# stub: warden 1.2.7 ruby lib

Gem::Specification.new do |s|
  s.name = "warden".freeze
  s.version = "1.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Neighman".freeze]
  s.date = "2017-01-24"
  s.email = "has.sox@gmail.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.textile".freeze]
  s.files = ["LICENSE".freeze, "README.textile".freeze]
  s.homepage = "http://github.com/hassox/warden".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubyforge_project = "warden".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Rack middleware that provides authentication for rack applications".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, [">= 1.0"])
    else
      s.add_dependency(%q<rack>.freeze, [">= 1.0"])
    end
  else
    s.add_dependency(%q<rack>.freeze, [">= 1.0"])
  end
end
