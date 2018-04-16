# -*- encoding: utf-8 -*-
require "./lib/rotp/version"

Gem::Specification.new do |s|
  s.name        = "rotp"
  s.version     = ROTP::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Mark Percival"]
  s.email       = ["mark@markpercival.us"]
  s.homepage    = "http://github.com/mdp/rotp"
  s.summary     = %q{A Ruby library for generating and verifying one time passwords}
  s.description = %q{Works for both HOTP and TOTP, and includes QR Code provisioning}

  s.rubyforge_project = "rotp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'guard-rspec', '~> 4.5'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'timecop', '~> 0.7'
end
