# -*- encoding: utf-8 -*-
# stub: http_parser.rb 0.6.0 ruby lib
# stub: ext/ruby_http_parser/extconf.rb

Gem::Specification.new do |s|
  s.name = "http_parser.rb".freeze
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marc-Andre Cournoyer".freeze, "Aman Gupta".freeze]
  s.date = "2013-12-11"
  s.description = "Ruby bindings to http://github.com/ry/http-parser and http://github.com/a2800276/http-parser.java".freeze
  s.email = ["macournoyer@gmail.com".freeze, "aman@tmm1.net".freeze]
  s.extensions = ["ext/ruby_http_parser/extconf.rb".freeze]
  s.files = ["ext/ruby_http_parser/extconf.rb".freeze]
  s.homepage = "http://github.com/tmm1/http_parser.rb".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Simple callback-based HTTP request/response parser".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake-compiler>.freeze, [">= 0.7.9"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 2.0.1"])
      s.add_development_dependency(%q<json>.freeze, [">= 1.4.6"])
      s.add_development_dependency(%q<benchmark_suite>.freeze, [">= 0"])
      s.add_development_dependency(%q<ffi>.freeze, [">= 0"])
      s.add_development_dependency(%q<yajl-ruby>.freeze, [">= 0.8.1"])
    else
      s.add_dependency(%q<rake-compiler>.freeze, [">= 0.7.9"])
      s.add_dependency(%q<rspec>.freeze, [">= 2.0.1"])
      s.add_dependency(%q<json>.freeze, [">= 1.4.6"])
      s.add_dependency(%q<benchmark_suite>.freeze, [">= 0"])
      s.add_dependency(%q<ffi>.freeze, [">= 0"])
      s.add_dependency(%q<yajl-ruby>.freeze, [">= 0.8.1"])
    end
  else
    s.add_dependency(%q<rake-compiler>.freeze, [">= 0.7.9"])
    s.add_dependency(%q<rspec>.freeze, [">= 2.0.1"])
    s.add_dependency(%q<json>.freeze, [">= 1.4.6"])
    s.add_dependency(%q<benchmark_suite>.freeze, [">= 0"])
    s.add_dependency(%q<ffi>.freeze, [">= 0"])
    s.add_dependency(%q<yajl-ruby>.freeze, [">= 0.8.1"])
  end
end
