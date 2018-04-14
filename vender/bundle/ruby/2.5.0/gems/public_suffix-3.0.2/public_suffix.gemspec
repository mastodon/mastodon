# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "public_suffix/version"

Gem::Specification.new do |s|
  s.name        = "public_suffix"
  s.version     = PublicSuffix::VERSION
  s.authors     = ["Simone Carletti"]
  s.email       = ["weppos@weppos.net"]
  s.homepage    = "https://simonecarletti.com/code/publicsuffix-ruby"
  s.summary     = "Domain name parser based on the Public Suffix List."
  s.description = "PublicSuffix can parse and decompose a domain name into top level domain, domain and subdomains."
  s.licenses    = ["MIT"]

  s.required_ruby_version = ">= 2.1"

  s.require_paths    = ["lib"]
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = %w( LICENSE.txt )

  s.add_development_dependency "rake"
  s.add_development_dependency "mocha"
  s.add_development_dependency "yard"
end
