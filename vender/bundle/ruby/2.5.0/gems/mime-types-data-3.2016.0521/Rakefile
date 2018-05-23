# frozen_string_literal: true

require 'rubygems'
require 'hoe'
require 'rake/clean'

Hoe.plugin :doofus
Hoe.plugin :gemspec2
Hoe.plugin :git
Hoe.plugin :travis
Hoe.plugin :email unless ENV['CI'] or ENV['TRAVIS']

Hoe.spec 'mime-types-data' do
  developer('Austin Ziegler', 'halostatue@gmail.com')

  require_ruby_version '>= 2.0'

  self.history_file = 'History.md'
  self.readme_file = 'README.md'

  license 'MIT'

  extra_dev_deps << ['nokogiri', '~> 1.6']
  extra_dev_deps << ['hoe-doofus', '~> 1.0']
  extra_dev_deps << ['hoe-gemspec2', '~> 1.1']
  extra_dev_deps << ['hoe-git', '~> 1.6']
  extra_dev_deps << ['hoe-rubygems', '~> 1.0']
  extra_dev_deps << ['rake', '~> 10.0']
  extra_dev_deps << ['mime-types', '~> 3.0']
end

$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'support'

namespace :mime do
  desc 'Download the current MIME type registrations from IANA.'
  task :iana, [ :destination ] do |_, args|
    require 'iana_registry'
    IANARegistry.download(to: args.destination)
  end

  desc 'Download the current MIME type configuration from Apache.'
  task :apache, [ :destination ] do |_, args|
    require 'apache_mime_types'
    ApacheMIMETypes.download(to: args.destination)
  end
end

namespace :convert do
  namespace :yaml do
    desc 'Convert from YAML to JSON'
    task :json, [ :source, :destination, :multiple_files ] => :support do |_, args|
      require 'convert'
      Convert.from_yaml_to_json(args)
    end

    desc 'Convert from YAML to Columnar'
    task :columnar, [ :source, :destination ] => :support do |_, args|
      require 'convert/columnar'
      Convert::Columnar.from_yaml_to_columnar(args)
    end
  end

  namespace :json do
    desc 'Convert from JSON to YAML'
    task :yaml, [ :source, :destination, :multiple_files ] => :support do |_, args|
      require 'convert'
      Convert.from_json_to_yaml(args)
    end
  end
end

desc 'Default conversion from YAML to JSON and Columnar'
task convert: [ 'convert:yaml:json', 'convert:yaml:columnar' ]

Rake::Task['gem'].prerequisites.unshift('convert')
Rake::Task['gem'].prerequisites.unshift('git:manifest')
Rake::Task['gem'].prerequisites.unshift('gemspec')

# vim: syntax=ruby
