# -*- encoding: utf-8 -*-
# stub: httplog 0.99.7 ruby lib

Gem::Specification.new do |s|
  s.name = "httplog".freeze
  s.version = "0.99.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thilo Rusche".freeze]
  s.date = "2017-07-19"
  s.description = "Log outgoing HTTP requests made from your application. Helpful for tracking API calls\n                     of third party gems that don't provide their own log output.".freeze
  s.email = "thilorusche@gmail.com".freeze
  s.homepage = "http://github.com/trusche/httplog".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Logs outgoing HTTP requests.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<thin>.freeze, [">= 0"])
      s.add_development_dependency(%q<httpclient>.freeze, [">= 0"])
      s.add_development_dependency(%q<httparty>.freeze, [">= 0"])
      s.add_development_dependency(%q<faraday>.freeze, [">= 0"])
      s.add_development_dependency(%q<excon>.freeze, [">= 0.18.0"])
      s.add_development_dependency(%q<ethon>.freeze, [">= 0"])
      s.add_development_dependency(%q<patron>.freeze, [">= 0"])
      s.add_development_dependency(%q<http>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<listen>.freeze, ["~> 3.0.8"])
      s.add_runtime_dependency(%q<colorize>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<rack>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<guard-rspec>.freeze, [">= 0"])
      s.add_dependency(%q<thin>.freeze, [">= 0"])
      s.add_dependency(%q<httpclient>.freeze, [">= 0"])
      s.add_dependency(%q<httparty>.freeze, [">= 0"])
      s.add_dependency(%q<faraday>.freeze, [">= 0"])
      s.add_dependency(%q<excon>.freeze, [">= 0.18.0"])
      s.add_dependency(%q<ethon>.freeze, [">= 0"])
      s.add_dependency(%q<patron>.freeze, [">= 0"])
      s.add_dependency(%q<http>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<listen>.freeze, ["~> 3.0.8"])
      s.add_dependency(%q<colorize>.freeze, [">= 0"])
      s.add_dependency(%q<rack>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<guard-rspec>.freeze, [">= 0"])
    s.add_dependency(%q<thin>.freeze, [">= 0"])
    s.add_dependency(%q<httpclient>.freeze, [">= 0"])
    s.add_dependency(%q<httparty>.freeze, [">= 0"])
    s.add_dependency(%q<faraday>.freeze, [">= 0"])
    s.add_dependency(%q<excon>.freeze, [">= 0.18.0"])
    s.add_dependency(%q<ethon>.freeze, [">= 0"])
    s.add_dependency(%q<patron>.freeze, [">= 0"])
    s.add_dependency(%q<http>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<listen>.freeze, ["~> 3.0.8"])
    s.add_dependency(%q<colorize>.freeze, [">= 0"])
    s.add_dependency(%q<rack>.freeze, [">= 0"])
  end
end
