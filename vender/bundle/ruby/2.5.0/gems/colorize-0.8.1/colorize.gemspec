Gem::Specification.new do |s|
  s.name = 'colorize'
  s.version = '0.8.1'

  s.authors = ['Michał Kalbarczyk']
  s.email = 'fazibear@gmail.com'

  s.date = Time.now.strftime('%Y-%m-%d')

  s.homepage = 'http://github.com/fazibear/colorize'
  s.description = 'Extends String class or add a ColorizedString with methods to set text color, background color and text effects.'
  s.summary = 'Ruby gem for colorizing text using ANSI escape sequences.'
  s.license = 'GPL-2.0'

  s.require_paths = ['lib']

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'

  s.files = [
    'LICENSE',
    'CHANGELOG',
    'README.md',
    'Rakefile',
    'colorize.gemspec',
    'lib/colorize.rb',
    'lib/colorized_string.rb',
    'lib/colorize/class_methods.rb',
    'lib/colorize/instance_methods.rb',
    'test/test_colorize.rb',
  ]
  s.test_files = [
    'test/test_colorize.rb'
  ]
end
