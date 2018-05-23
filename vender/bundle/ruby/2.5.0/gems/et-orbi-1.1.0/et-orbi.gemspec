
Gem::Specification.new do |s|

  s.name = 'et-orbi'

  s.version = File.read(
    File.expand_path('../lib/et-orbi.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux+flor@gmail.com' ]
  s.homepage = 'http://github.com/floraison/et-orbi'
  s.license = 'MIT'
  s.summary = 'time with zones'

  s.description = %{
Time zones for fugit and rufus-scheduler. Urbi et Orbi.
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'README.{md,txt}',
    'CHANGELOG.{md,txt}', 'CREDITS.{md,txt}', 'LICENSE.{md,txt}',
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    "#{s.name}.gemspec",
  ]

  s.add_runtime_dependency 'tzinfo'
  #s.add_runtime_dependency 'raabro', '>= 1.1.3'

  s.add_development_dependency 'rspec', '~> 3.4'

  s.require_path = 'lib'
end

