# -*- encoding: utf-8 -*-
# stub: mario-redis-lock 1.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "mario-redis-lock".freeze
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mario Izquierdo".freeze]
  s.date = "2018-01-08"
  s.description = "Yet another Ruby distributed lock using Redis, with emphasis in transparency. Requires Redis >= 2.6.12, because it uses the new syntax for SET to easily implement the robust algorithm described in the SET command documentation (http://redis.io/commands/set).".freeze
  s.email = ["tomario@gmail.com".freeze]
  s.homepage = "https://github.com/marioizquierdo/mario-redis-lock".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Yet another Ruby distributed lock using Redis, with emphasis in transparency.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>.freeze, [">= 3.0.5"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1"])
      s.add_development_dependency(%q<rake>.freeze, [">= 10"])
    else
      s.add_dependency(%q<redis>.freeze, [">= 3.0.5"])
      s.add_dependency(%q<bundler>.freeze, [">= 1"])
      s.add_dependency(%q<rake>.freeze, [">= 10"])
    end
  else
    s.add_dependency(%q<redis>.freeze, [">= 3.0.5"])
    s.add_dependency(%q<bundler>.freeze, [">= 1"])
    s.add_dependency(%q<rake>.freeze, [">= 10"])
  end
end
