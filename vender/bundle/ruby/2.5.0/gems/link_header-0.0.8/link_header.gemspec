# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'link_header/version'

Gem::Specification.new do |spec|
  spec.name          = "link_header"
  spec.version       = LinkHeader::VERSION
  spec.authors       = ["Mike Burrows"]
  spec.email         = ["mjb@asplake.co.uk"]
  spec.description   = %q{Converts conforming link headers to and from text, LinkHeader objects and corresponding (JSON-friendly) Array representations, also HTML link elements.}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/asplake/link_header"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
