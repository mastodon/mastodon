# -*- encoding: utf-8 -*-
# stub: bootsnap 1.2.1 ruby lib
# stub: ext/bootsnap/extconf.rb

Gem::Specification.new do |s|
  s.name = "bootsnap".freeze
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Burke Libbey".freeze]
  s.date = "2018-03-22"
  s.description = "Boot large ruby/rails apps faster".freeze
  s.email = ["burke.libbey@shopify.com".freeze]
  s.extensions = ["ext/bootsnap/extconf.rb".freeze]
  s.files = ["ext/bootsnap/extconf.rb".freeze]
  s.homepage = "https://github.com/Shopify/bootsnap".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Boot large ruby/rails apps faster".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 1.2"])
      s.add_runtime_dependency(%q<msgpack>.freeze, ["~> 1.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rake-compiler>.freeze, ["~> 0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_dependency(%q<mocha>.freeze, ["~> 1.2"])
      s.add_dependency(%q<msgpack>.freeze, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rake-compiler>.freeze, ["~> 0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.2"])
    s.add_dependency(%q<msgpack>.freeze, ["~> 1.0"])
  end
end
