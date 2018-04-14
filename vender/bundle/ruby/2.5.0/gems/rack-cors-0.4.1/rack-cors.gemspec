# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/cors/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-cors"
  spec.version       = Rack::Cors::VERSION
  spec.authors       = ["Calvin Yu"]
  spec.email         = ["me@sourcebender.com"]
  spec.description   = %q{Middleware that will make Rack-based apps CORS compatible.  Read more here: http://blog.sourcebender.com/2010/06/09/introducin-rack-cors.html.  Fork the project here: https://github.com/cyu/rack-cors}
  spec.summary       = %q{Middleware for enabling Cross-Origin Resource Sharing in Rack apps}
  spec.homepage      = "https://github.com/cyu/rack-cors"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).reject { |f| f == '.gitignore' or f =~ /^examples/ }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", ">= 5.3.0"
  spec.add_development_dependency "mocha", ">= 0.14.0"
  spec.add_development_dependency "rack-test", ">= 0"
end
