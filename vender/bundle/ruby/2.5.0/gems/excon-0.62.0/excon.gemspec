require File.join(File.dirname(__FILE__), 'lib', 'excon', 'version')

Gem::Specification.new do |s|
  s.name             = 'excon'
  s.version          = Excon::VERSION
  s.summary          = "speed, persistence, http(s)"
  s.description      = "EXtended http(s) CONnections"
  s.authors          = ["dpiddy (Dan Peterson)", "geemus (Wesley Beary)", "nextmat (Matt Sanders)"]
  s.email            = 'geemus@gmail.com'
  s.homepage         = 'https://github.com/excon/excon'
  s.license          = 'MIT'
  s.rdoc_options     = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md CONTRIBUTORS.md CONTRIBUTING.md]
  s.files            = `git ls-files -z`.split("\x0")
  s.test_files       = s.files.select { |path| path =~ /^[spec|tests]\/.*_[spec|tests]\.rb/ }

  s.add_development_dependency('rspec', '>= 3.5.0')
  s.add_development_dependency('activesupport')
  s.add_development_dependency('delorean')
  s.add_development_dependency('eventmachine', '>= 1.0.4')
  s.add_development_dependency('open4')
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('shindo')
  s.add_development_dependency('sinatra')
  s.add_development_dependency('sinatra-contrib')
  s.add_development_dependency('json', '>= 1.8.5')
  s.add_development_dependency('puma')
end
