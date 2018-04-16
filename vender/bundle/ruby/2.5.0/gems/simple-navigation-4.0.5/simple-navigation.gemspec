# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_navigation/version'

Gem::Specification.new do |spec|
  spec.name             = 'simple-navigation'
  spec.version          = SimpleNavigation::VERSION
  spec.authors          = ['Andi Schacke', 'Mark J. Titorenko', 'Simon Courtois']
  spec.email            = ['andi@codeplant.ch']
  spec.description      = "With the simple-navigation gem installed you can easily " \
                          "create multilevel navigations for your Rails, Sinatra or "\
                          "Padrino applications. The navigation is defined in a "    \
                          "single configuration file. It supports automatic as well "\
                          "as explicit highlighting of the currently active "        \
                          "navigation through regular expressions."
  spec.summary          = "simple-navigation is a ruby library for creating navigations "\
                          "(with multiple levels) for your Rails, Sinatra or "  \
                          "Padrino application."
  spec.homepage         = 'http://github.com/codeplant/simple-navigation'
  spec.license          = 'MIT'

  spec.files            = `git ls-files -z`.split("\x0")
  spec.executables      = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files       = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths    = ['lib']

  spec.rdoc_options     = ['--inline-source', '--charset=UTF-8']

  spec.add_runtime_dependency 'activesupport', '>= 2.3.2'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'guard-rspec', '~> 4.2'
  spec.add_development_dependency 'memfs', '~> 0.4.1'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'tzinfo', '>= 0'
end
