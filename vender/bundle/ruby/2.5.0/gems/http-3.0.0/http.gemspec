# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "http/version"

Gem::Specification.new do |gem|
  gem.authors       = ["Tony Arcieri", "Erik Michaels-Ober", "Alexey V. Zapparov", "Zachary Anker"]
  gem.email         = ["bascule@gmail.com"]

  gem.description   = <<-DESCRIPTION.strip.gsub(/\s+/, " ")
    An easy-to-use client library for making requests from Ruby.
    It uses a simple method chaining system for building requests,
    similar to Python's Requests.
  DESCRIPTION

  gem.summary       = "HTTP should be easy"
  gem.homepage      = "https://github.com/httprb/http"
  gem.licenses      = ["MIT"]

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "http"
  gem.require_paths = ["lib"]
  gem.version       = HTTP::VERSION

  gem.required_ruby_version = ">= 2.0"

  gem.add_runtime_dependency "http_parser.rb", "~> 0.6.0"
  gem.add_runtime_dependency "http-form_data", ">= 2.0.0-pre2", "< 3"
  gem.add_runtime_dependency "http-cookie",    "~> 1.0"
  gem.add_runtime_dependency "addressable",    "~> 2.3"

  gem.add_development_dependency "bundler", "~> 1.0"
end
