# -*- encoding: utf-8 -*-
# stub: stoplight 2.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "stoplight".freeze
  s.version = "2.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Cameron Desautels".freeze, "Taylor Fausak".freeze, "Justin Steffy".freeze]
  s.date = "2018-04-01"
  s.description = "An implementation of the circuit breaker pattern.".freeze
  s.email = ["camdez@gmail.com".freeze, "taylor@fausak.me".freeze, "steffy@orgsync.com".freeze]
  s.homepage = "https://github.com/orgsync/stoplight".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Traffic control for code.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<benchmark-ips>.freeze, ["~> 2.3"])
      s.add_development_dependency(%q<bugsnag>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<fakeredis>.freeze, ["~> 0.5"])
      s.add_development_dependency(%q<hipchat>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<honeybadger>.freeze, ["~> 2.5"])
      s.add_development_dependency(%q<sentry-raven>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 11.1"])
      s.add_development_dependency(%q<redis>.freeze, ["~> 3.2"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.3"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.40.0"])
      s.add_development_dependency(%q<slack-notifier>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<timecop>.freeze, ["~> 0.8"])
    else
      s.add_dependency(%q<benchmark-ips>.freeze, ["~> 2.3"])
      s.add_dependency(%q<bugsnag>.freeze, ["~> 4.0"])
      s.add_dependency(%q<coveralls>.freeze, ["~> 0.8"])
      s.add_dependency(%q<fakeredis>.freeze, ["~> 0.5"])
      s.add_dependency(%q<hipchat>.freeze, ["~> 1.5"])
      s.add_dependency(%q<honeybadger>.freeze, ["~> 2.5"])
      s.add_dependency(%q<sentry-raven>.freeze, ["~> 1.2"])
      s.add_dependency(%q<rake>.freeze, ["~> 11.1"])
      s.add_dependency(%q<redis>.freeze, ["~> 3.2"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.40.0"])
      s.add_dependency(%q<slack-notifier>.freeze, ["~> 1.3"])
      s.add_dependency(%q<timecop>.freeze, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<benchmark-ips>.freeze, ["~> 2.3"])
    s.add_dependency(%q<bugsnag>.freeze, ["~> 4.0"])
    s.add_dependency(%q<coveralls>.freeze, ["~> 0.8"])
    s.add_dependency(%q<fakeredis>.freeze, ["~> 0.5"])
    s.add_dependency(%q<hipchat>.freeze, ["~> 1.5"])
    s.add_dependency(%q<honeybadger>.freeze, ["~> 2.5"])
    s.add_dependency(%q<sentry-raven>.freeze, ["~> 1.2"])
    s.add_dependency(%q<rake>.freeze, ["~> 11.1"])
    s.add_dependency(%q<redis>.freeze, ["~> 3.2"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.40.0"])
    s.add_dependency(%q<slack-notifier>.freeze, ["~> 1.3"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.8"])
  end
end
