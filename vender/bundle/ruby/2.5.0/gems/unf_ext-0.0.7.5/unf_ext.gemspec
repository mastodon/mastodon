# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unf_ext/version'

Gem::Specification.new do |gem|
  gem.name          = "unf_ext"
  gem.version       = UNF::Normalizer::VERSION
  gem.authors       = ["Takeru Ohta", "Akinori MUSHA"]
  gem.email         = ["knu@idaemons.org"]
  gem.description   = %q{Unicode Normalization Form support library for CRuby}
  gem.summary       = %q{Unicode Normalization Form support library for CRuby}
  gem.homepage      = "https://github.com/knu/ruby-unf_ext"
  gem.licenses      = ["MIT"]

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/}).grep(%r{/test_[^/]+\.rb$})
  gem.require_paths = ["lib"]
  gem.extensions    = ["ext/unf_ext/extconf.rb"]

  gem.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]

  if RUBY_VERSION < "1.9"
    gem.add_development_dependency("rake", [">= 0.9.2.2", "< 11"])
    gem.add_development_dependency('i18n', '< 0.7.0')
    # Cap dependency on activesupport with < 4.0 on behalf of
    # shoulda-matchers to satisfy bundler.
    gem.add_development_dependency("activesupport", ["< 4.0"])
    gem.add_development_dependency("test-unit", ["= 3.1.5"])
  else
    gem.add_development_dependency("rake", [">= 0.9.2.2"])
    gem.add_development_dependency("test-unit")
  end
  gem.add_development_dependency("rdoc", ["> 2.4.2"])
  gem.add_development_dependency("bundler", [">= 1.2"])
  gem.add_development_dependency("rake-compiler", [">= 0.7.9"])
  gem.add_development_dependency("rake-compiler-dock", ["~> 0.6.0"])
end
