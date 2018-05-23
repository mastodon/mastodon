# -*- encoding: utf-8 -*-
# stub: ruby-saml 1.7.2 ruby lib

Gem::Specification.new do |s|
  s.name = "ruby-saml".freeze
  s.version = "1.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["OneLogin LLC".freeze]
  s.date = "2018-02-28"
  s.description = "SAML toolkit for Ruby on Rails".freeze
  s.email = "support@onelogin.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.md".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze]
  s.homepage = "http://github.com/onelogin/ruby-saml".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubyforge_project = "http://www.rubygems.org/gems/ruby-saml".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "SAML Ruby Tookit".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.5.10"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.5"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 0.14"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_development_dependency(%q<shoulda>.freeze, ["~> 2.11"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.9.0"])
      s.add_development_dependency(%q<systemu>.freeze, ["~> 2"])
      s.add_development_dependency(%q<timecop>.freeze, ["<= 0.6.0"])
      s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>.freeze, [">= 1.5.10"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.5"])
      s.add_dependency(%q<mocha>.freeze, ["~> 0.14"])
      s.add_dependency(%q<rake>.freeze, ["~> 10"])
      s.add_dependency(%q<shoulda>.freeze, ["~> 2.11"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.9.0"])
      s.add_dependency(%q<systemu>.freeze, ["~> 2"])
      s.add_dependency(%q<timecop>.freeze, ["<= 0.6.0"])
      s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.5.10"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.5"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0.14"])
    s.add_dependency(%q<rake>.freeze, ["~> 10"])
    s.add_dependency(%q<shoulda>.freeze, ["~> 2.11"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.9.0"])
    s.add_dependency(%q<systemu>.freeze, ["~> 2"])
    s.add_dependency(%q<timecop>.freeze, ["<= 0.6.0"])
    s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
  end
end
