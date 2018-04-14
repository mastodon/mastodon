# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/json/version'

Gem::Specification.new do |spec|
  spec.name          = "fog-json"
  spec.version       = Fog::Json::VERSION
  spec.authors       = ["Wesley Beary (geemus)", "Paul Thornthwaite (tokengeek)", "The fog team"]
  spec.email         = ["geemus@gmail.com", "tokengeek@gmail.com"]
  spec.summary       = %q{JSON parsing for fog providers}
  spec.description   = %q{Extraction of the JSON parsing tools shared between a
                          number of providers in the 'fog' gem.}
  spec.homepage      = "http://github.com/fog/fog-json"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fog-core", "~> 1.0"
  spec.add_dependency "multi_json", "~> 1.10"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
