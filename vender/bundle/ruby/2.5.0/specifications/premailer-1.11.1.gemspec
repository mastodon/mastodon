# -*- encoding: utf-8 -*-
# stub: premailer 1.11.1 ruby lib

Gem::Specification.new do |s|
  s.name = "premailer".freeze
  s.version = "1.11.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "yard.run" => "yri" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Dunae".freeze]
  s.date = "2017-11-14"
  s.description = "Improve the rendering of HTML emails by making CSS inline, converting links and warning about unsupported code.".freeze
  s.email = "akzhan.abdulin@gmail.com".freeze
  s.executables = ["premailer".freeze]
  s.files = ["bin/premailer".freeze]
  s.homepage = "https://github.com/premailer/premailer".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Preflight for HTML e-mail.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<css_parser>.freeze, [">= 1.6.0"])
      s.add_runtime_dependency(%q<htmlentities>.freeze, [">= 4.0.0"])
      s.add_runtime_dependency(%q<addressable>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1.3"])
      s.add_development_dependency(%q<rake>.freeze, ["!= 0.9.0", "> 0.8"])
      s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.7"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0"])
      s.add_development_dependency(%q<redcarpet>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<maxitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_development_dependency(%q<nokogumbo>.freeze, [">= 0"])
    else
      s.add_dependency(%q<css_parser>.freeze, [">= 1.6.0"])
      s.add_dependency(%q<htmlentities>.freeze, [">= 4.0.0"])
      s.add_dependency(%q<addressable>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.3"])
      s.add_dependency(%q<rake>.freeze, ["!= 0.9.0", "> 0.8"])
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.7"])
      s.add_dependency(%q<yard>.freeze, [">= 0"])
      s.add_dependency(%q<redcarpet>.freeze, ["~> 3.0"])
      s.add_dependency(%q<maxitest>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_dependency(%q<nokogumbo>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<css_parser>.freeze, [">= 1.6.0"])
    s.add_dependency(%q<htmlentities>.freeze, [">= 4.0.0"])
    s.add_dependency(%q<addressable>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_dependency(%q<rake>.freeze, ["!= 0.9.0", "> 0.8"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.7"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
    s.add_dependency(%q<redcarpet>.freeze, ["~> 3.0"])
    s.add_dependency(%q<maxitest>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_dependency(%q<nokogumbo>.freeze, [">= 0"])
  end
end
