# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mini_portile2/version'

Gem::Specification.new do |spec|
  spec.name          = "mini_portile2"
  spec.version       = MiniPortile::VERSION

  spec.authors       = ['Luis Lavena', 'Mike Dalessio', 'Lars Kanis']
  spec.email         = 'mike.dalessio@gmail.com'

  spec.summary       = "Simplistic port-like solution for developers"
  spec.description   = "Simplistic port-like solution for developers. It provides a standard and simplified way to compile against dependency libraries without messing up your system."

  spec.homepage      = 'http://github.com/flavorjones/mini_portile'
  spec.licenses      = ['MIT']

  begin
    spec.files         = `git ls-files -z`.split("\x0")
  rescue Exception => e
    warn "WARNING: could not set spec.files: #{e.class}: #{e}"
  end

  # omit the `examples` directory from the gem, because it's large and
  # not necessary to be packaged in the gem.
  example_files      = spec.files.grep(%r{^examples/})
  spec.files -= example_files

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|examples)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.8"
  spec.add_development_dependency "minitest-hooks", "~> 1.4"
  spec.add_development_dependency "minitar", "~> 0.5"
  spec.add_development_dependency "concourse", "~> 0.12"

  spec.required_ruby_version = ">= 1.9.2"
end
