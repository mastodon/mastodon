
Gem::Specification.new do |s|

  s.name = 'rufus-scheduler'

  s.version = File.read(
    File.expand_path('../lib/rufus/scheduler.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux@gmail.com' ]
  s.homepage = 'http://github.com/jmettraux/rufus-scheduler'
  s.rubyforge_project = 'rufus'
  s.license = 'MIT'
  s.summary = 'job scheduler for Ruby (at, cron, in and every jobs)'

  s.description = %{
Job scheduler for Ruby (at, cron, in and every jobs). Not a replacement for crond.
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.required_ruby_version = '>= 1.9'

  s.add_runtime_dependency 'et-orbi', '~> 1.0'

  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'chronic'

  s.require_path = 'lib'
end

