# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "climate_control/version"

Gem::Specification.new do |gem|
  gem.name          = "climate_control"
  gem.version       = ClimateControl::VERSION
  gem.authors       = ["Joshua Clayton"]
  gem.email         = ["joshua.clayton@gmail.com"]
  gem.description   = %q{Modify your ENV}
  gem.summary       = %q{Modify your ENV easily with ClimateControl}
  gem.homepage      = "https://github.com/thoughtbot/climate_control"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec", "~> 3.1.0"
  gem.add_development_dependency "rake", "~> 10.3.2"
  gem.add_development_dependency "simplecov", "~> 0.9.1"
end
