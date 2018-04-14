# -*- encoding: utf-8 -*-
# stub: kaminari 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "kaminari".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Akira Matsuda".freeze, "Yuki Nishijima".freeze, "Zachary Scott".freeze, "Hiroshi Shibata".freeze]
  s.date = "2017-10-21"
  s.description = "Kaminari is a Scope & Engine based, clean, powerful, agnostic, customizable and sophisticated paginator for Rails 4+".freeze
  s.email = ["ronnie@dio.jp".freeze]
  s.homepage = "https://github.com/kaminari/kaminari".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A pagination engine plugin for Rails 4+ and other modern frameworks".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.1.0"])
      s.add_runtime_dependency(%q<kaminari-core>.freeze, ["= 1.1.1"])
      s.add_runtime_dependency(%q<kaminari-actionview>.freeze, ["= 1.1.1"])
      s.add_runtime_dependency(%q<kaminari-activerecord>.freeze, ["= 1.1.1"])
      s.add_development_dependency(%q<test-unit-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1.0.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rr>.freeze, [">= 0"])
      s.add_development_dependency(%q<capybara>.freeze, [">= 1.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, [">= 4.1.0"])
      s.add_dependency(%q<kaminari-core>.freeze, ["= 1.1.1"])
      s.add_dependency(%q<kaminari-actionview>.freeze, ["= 1.1.1"])
      s.add_dependency(%q<kaminari-activerecord>.freeze, ["= 1.1.1"])
      s.add_dependency(%q<test-unit-rails>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rr>.freeze, [">= 0"])
      s.add_dependency(%q<capybara>.freeze, [">= 1.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 4.1.0"])
    s.add_dependency(%q<kaminari-core>.freeze, ["= 1.1.1"])
    s.add_dependency(%q<kaminari-actionview>.freeze, ["= 1.1.1"])
    s.add_dependency(%q<kaminari-activerecord>.freeze, ["= 1.1.1"])
    s.add_dependency(%q<test-unit-rails>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rr>.freeze, [">= 0"])
    s.add_dependency(%q<capybara>.freeze, [">= 1.0"])
  end
end
