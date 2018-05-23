# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'equatable/version'

Gem::Specification.new do |gem|
  gem.name          = "equatable"
  gem.version       = Equatable::VERSION
  gem.authors       = ["Piotr Murach"]
  gem.email         = [""]
  gem.description   = %q{Allows ruby objects to implement equality comparison and inspection methods. By including this module, a class indicates that its instances have explicit general contracts for `hash`, `==` and `eql?` methods.}
  gem.summary       = %q{Allows ruby objects to implement equality comparison and inspection methods.}
  gem.homepage      = "http://github.com/peter-murach/equatable"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "bundler", "~> 1.5"
end
