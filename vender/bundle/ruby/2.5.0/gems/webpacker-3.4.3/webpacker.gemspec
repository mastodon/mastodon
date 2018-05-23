$:.push File.expand_path("../lib", __FILE__)
require "webpacker/version"

Gem::Specification.new do |s|
  s.name     = "webpacker"
  s.version  = Webpacker::VERSION
  s.authors  = [ "David Heinemeier Hansson", "Gaurav Tiwari" ]
  s.email    = [ "david@basecamp.com", "gaurav@gauravtiwari.co.uk" ]
  s.summary  = "Use webpack to manage app-like JavaScript modules in Rails"
  s.homepage = "https://github.com/rails/webpacker"
  s.license  = "MIT"

  s.required_ruby_version = ">= 2.2.0"

  s.add_dependency "activesupport", ">= 4.2"
  s.add_dependency "railties",      ">= 4.2"
  s.add_dependency "rack-proxy",    ">= 0.6.1"

  s.add_development_dependency "bundler", "~> 1.12"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
end
