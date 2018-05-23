# frozen_string_literal: true

require File.expand_path('../lib/sidekiq_unique_jobs/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq-unique-jobs'
  spec.version       = SidekiqUniqueJobs::VERSION
  spec.authors       = ['Mikael Henriksson']
  spec.email         = ['mikael@zoolutions.se']

  spec.summary       = 'Uniqueness for Sidekiq Jobs'
  spec.description   = 'Handles various types of unique jobs for Sidekiq'
  spec.homepage      = 'https://github.com/mhenrixon/sidekiq-unique-jobs'
  spec.license       = 'MIT'

  spec.bindir        = 'bin'
  spec.executables   = %w[jobs]
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|gemfiles|pkg|rails_example|tmp)/})
  end

  spec.require_paths = ['lib']
  spec.add_dependency 'sidekiq', '>= 4.0', '<= 6.0'
  spec.add_dependency 'thor', '~> 0'

  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'timecop', '~> 0.8'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'gem-release', '~> 0.7'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0', '>= 1.0.8'
end
