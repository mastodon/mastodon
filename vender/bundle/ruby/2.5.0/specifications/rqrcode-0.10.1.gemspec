# -*- encoding: utf-8 -*-
# stub: rqrcode 0.10.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rqrcode".freeze
  s.version = "0.10.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bj\u00F6rn Blomqvist".freeze, "Duncan Robertson".freeze]
  s.date = "2016-02-11"
  s.description = "rQRCode is a library for encoding QR Codes. The simple\ninterface allows you to create QR Code data structures\nready to be displayed in the way you choose.\n".freeze
  s.email = ["darwin@bits2life.com".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "CHANGELOG".freeze, "LICENSE".freeze]
  s.files = ["CHANGELOG".freeze, "LICENSE".freeze, "README.md".freeze]
  s.homepage = "https://github.com/whomwah/rqrcode".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A library to encode QR Codes".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<chunky_png>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1.0.0"])
    else
      s.add_dependency(%q<chunky_png>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<chunky_png>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.0.0"])
  end
end
