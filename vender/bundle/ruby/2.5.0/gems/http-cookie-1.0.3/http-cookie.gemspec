# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http/cookie/version'

Gem::Specification.new do |gem|
  gem.name          = "http-cookie"
  gem.version       = HTTP::Cookie::VERSION
  gem.authors, gem.email = {
    'Akinori MUSHA'   => 'knu@idaemons.org',
    'Aaron Patterson' => 'aaronp@rubyforge.org',
    'Eric Hodel'      => 'drbrain@segment7.net',
    'Mike Dalessio'   => 'mike.dalessio@gmail.com',
  }.instance_eval { [keys, values] }

  gem.description   = %q{HTTP::Cookie is a Ruby library to handle HTTP Cookies based on RFC 6265.  It has with security, standards compliance and compatibility in mind, to behave just the same as today's major web browsers.  It has builtin support for the legacy cookies.txt and the latest cookies.sqlite formats of Mozilla Firefox, and its modular API makes it easy to add support for a new backend store.}
  gem.summary       = %q{A Ruby library to handle HTTP Cookies based on RFC 6265}
  gem.homepage      = "https://github.com/sparklemotion/http-cookie"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.extra_rdoc_files = ['README.md', 'LICENSE.txt']

  gem.add_runtime_dependency("domain_name", ["~> 0.5"])
  gem.add_development_dependency("sqlite3", ["~> 1.3.3"]) unless defined?(JRUBY_VERSION)
  gem.add_development_dependency("bundler", [">= 1.2.0"])
  gem.add_development_dependency("test-unit", [">= 2.4.3", *("< 3" if RUBY_VERSION < "1.9")])
  gem.add_development_dependency("rake", [">= 0.9.2.2", *("< 11" if RUBY_VERSION < "1.9")])
  gem.add_development_dependency("rdoc", ["> 2.4.2"])
  gem.add_development_dependency("simplecov", [">= 0"])
end
