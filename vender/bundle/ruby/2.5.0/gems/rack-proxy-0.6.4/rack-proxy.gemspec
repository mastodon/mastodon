# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack-proxy"

Gem::Specification.new do |s|
  s.name        = "rack-proxy"
  s.version     = Rack::Proxy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jacek Becela"]
  s.email       = ["jacek.becela@gmail.com"]
  s.homepage    = "https://github.com/ncr/rack-proxy"
  s.summary     = %q{A request/response rewriting HTTP proxy. A Rack app.}
  s.description = %q{A Rack app that provides request/response rewriting proxy capabilities with streaming.}

  s.rubyforge_project = "rack-proxy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("rack")
  s.add_development_dependency("rack-test")
  s.add_development_dependency("test-unit")
end
