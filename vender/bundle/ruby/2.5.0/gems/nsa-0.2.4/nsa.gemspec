# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nsa/version"

Gem::Specification.new do |spec|
  spec.name          = "nsa"
  spec.version       = ::NSA::VERSION
  spec.authors       = ["BJ Neilsen"]
  spec.email         = ["bj.neilsen@gmail.com"]

  spec.summary       = %q{Listen to your Rails ActiveSupport::Notifications and deliver to a Statsd backend.}
  spec.description   = spec.summary
  spec.homepage      = "https://www.github.com/localshred/nsa"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "< 6", ">= 4.2"
  spec.add_dependency "concurrent-ruby", "~> 1.0.0"
  spec.add_dependency "sidekiq", ">= 3.5.0"
  spec.add_dependency "statsd-ruby", "~> 1.2.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "byebug"
end
