# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ipaddress/version'

Gem::Specification.new do |spec|
  spec.name          = "ipaddress"
  spec.version       = Ipaddress::VERSION
  spec.authors       = ["bluemonk", "mikemackintosh"]
  spec.email         = ["ceresa@gmail.com"]
  spec.summary       = %q{IPv4/IPv6 address manipulation library}
  spec.description   = %q{IPAddress is a Ruby library designed to make manipulation 
      of IPv4 and IPv6 addresses both powerful and simple. It mantains
      a layer of compatibility with Ruby's own IPAddr, while 
      addressing many of its issues.}
  spec.homepage      = "https://github.com/bluemonk/ipaddress"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
