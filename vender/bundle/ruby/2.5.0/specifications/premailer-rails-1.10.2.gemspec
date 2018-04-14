# -*- encoding: utf-8 -*-
# stub: premailer-rails 1.10.2 ruby lib

Gem::Specification.new do |s|
  s.name = "premailer-rails".freeze
  s.version = "1.10.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Philipe Fatio".freeze]
  s.date = "2018-03-15"
  s.description = "This gem brings you the power of the premailer gem to Rails\n                     without any configuration needs. Create HTML emails,\n                     include a CSS file as you do in a normal HTML document and\n                     premailer will inline the included CSS.".freeze
  s.email = ["philipe.fatio@gmail.com".freeze]
  s.homepage = "https://github.com/fphilipe/premailer-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Easily create styled HTML emails in Rails.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<premailer>.freeze, [">= 1.7.9", "~> 1.7"])
      s.add_runtime_dependency(%q<actionmailer>.freeze, ["< 6", ">= 3"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.3"])
      s.add_development_dependency(%q<nokogiri>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
    else
      s.add_dependency(%q<premailer>.freeze, [">= 1.7.9", "~> 1.7"])
      s.add_dependency(%q<actionmailer>.freeze, ["< 6", ">= 3"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
      s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<premailer>.freeze, [">= 1.7.9", "~> 1.7"])
    s.add_dependency(%q<actionmailer>.freeze, ["< 6", ">= 3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
  end
end
