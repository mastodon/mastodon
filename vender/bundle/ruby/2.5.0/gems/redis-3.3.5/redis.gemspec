# -*- encoding: utf-8 -*-

$:.unshift File.expand_path("../lib", __FILE__)

require "redis/version"

Gem::Specification.new do |s|
  s.name = "redis"

  s.version = Redis::VERSION

  s.homepage = "https://github.com/redis/redis-rb"

  s.summary = "A Ruby client library for Redis"

  s.description = <<-EOS
    A Ruby client that tries to match Redis' API one-to-one, while still
    providing an idiomatic interface. It features thread-safety,
    client-side sharding, pipelining, and an obsession for performance.
  EOS

  s.license = "MIT"

  s.authors = [
    "Ezra Zygmuntowicz",
    "Taylor Weibley",
    "Matthew Clark",
    "Brian McKinney",
    "Salvatore Sanfilippo",
    "Luca Guidi",
    "Michel Martens",
    "Damian Janowski",
    "Pieter Noordhuis"
  ]

  s.email = ["redis-db@googlegroups.com"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_development_dependency("rake", "<11.0.0")
  s.add_development_dependency("test-unit", "3.1.5")
end
