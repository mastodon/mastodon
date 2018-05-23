# -*- encoding: utf-8 -*-
# stub: rails 5.1.6 ruby lib

Gem::Specification.new do |s|
  s.name = "rails".freeze
  s.version = "5.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.11".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2018-03-29"
  s.description = "Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "http://rubyonrails.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Full-stack web application framework.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<actionpack>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<actionview>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<activemodel>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<activerecord>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<actionmailer>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<activejob>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<actioncable>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<railties>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<bundler>.freeze, [">= 1.3.0"])
      s.add_runtime_dependency(%q<sprockets-rails>.freeze, [">= 2.0.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<actionpack>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<actionview>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<activemodel>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<activerecord>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<actionmailer>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<activejob>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<actioncable>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<railties>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.3.0"])
      s.add_dependency(%q<sprockets-rails>.freeze, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<actionpack>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<actionview>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<activemodel>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<activerecord>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<actionmailer>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<activejob>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<actioncable>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<railties>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.3.0"])
    s.add_dependency(%q<sprockets-rails>.freeze, [">= 2.0.0"])
  end
end
