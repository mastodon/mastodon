require File.expand_path('../lib/hashie/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'hashie'
  gem.version       = Hashie::VERSION
  gem.authors       = ['Michael Bleigh', 'Jerry Cheung']
  gem.email         = ['michael@intridea.com', 'jollyjerry@gmail.com']
  gem.description   = 'Hashie is a collection of classes and mixins that make hashes more powerful.'
  gem.summary       = 'Your friendly neighborhood hash library.'
  gem.homepage      = 'https://github.com/intridea/hashie'
  gem.license       = 'MIT'

  gem.require_paths = ['lib']
  gem.files         = %w(.yardopts CHANGELOG.md CONTRIBUTING.md LICENSE README.md UPGRADING.md Rakefile hashie.gemspec)
  gem.files += Dir['lib/**/*.rb']
  gem.files += Dir['spec/**/*.rb']
  gem.test_files = Dir['spec/**/*.rb']

  gem.add_development_dependency 'rake', '< 11'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rspec-pending_for', '~> 0.1'
end
