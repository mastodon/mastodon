# -*- encoding: utf-8 -*-
# stub: timers 4.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "timers".freeze
  s.version = "4.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tony Arcieri".freeze]
  s.date = "2016-11-26"
  s.description = "Schedule procs to run after a certain time, or at periodic intervals, using any API that accepts a timeout.".freeze
  s.email = ["bascule@gmail.com".freeze]
  s.homepage = "https://github.com/celluloid/timers".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Pure Ruby one-shot and periodic timers".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hitimes>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<hitimes>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<hitimes>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
  end
end
