# frozen_string_literal: true

require_relative '../mastodon/configuration/schema'
require_relative '../mastodon/configuration/env_scanner'

namespace :mastodon do
  namespace :config do
    desc <<~DESC
      Print the JSON Schema for Mastodon environment-variable configuration.

      The schema describes every environment variable recognised by this
      Mastodon instance, including its type, default value, and a human-readable description.
      Offers a machine-readable description of the configuration surface.

      Usage:
        bundle exec rails mastodon:config:schema
        bundle exec rails mastodon:config:schema > mastodon-config.schema.json
    DESC
    task :schema do
      require 'json'
      puts JSON.pretty_generate(Mastodon::Configuration::Schema.generate)
    end

    desc <<~DESC
      Check that every environment variable used in the source code is
      documented in the JSON Schema.

      The task statically scans #{Mastodon::Configuration::EnvScanner::SCAN_PATHS.join(', ')} for
      literal ENV.fetch / ENV[] accesses and reports any key that is absent
      from the schema and not listed in EnvScanner::EXCLUDED_VARS.

      Exits non-zero if undocumented variables are found.

      Usage:
        bundle exec rails mastodon:config:lint
    DESC
    task :lint do
      undocumented = Mastodon::Configuration::EnvScanner.undocumented

      if undocumented.empty?
        puts 'All environment variables are documented in the schema.'
      else
        warn "#{undocumented.size} environment variable(s) are used in the source code but not documented in the schema:\n"
        undocumented.sort.each do |key, files|
          warn "  #{key}"
          files.each { |f| warn "    #{f}" }
        end
        warn "\nTo fix, add entries for these variables to lib/mastodon/configuration/annotations.yml"
        warn 'then regenerate: bundle exec rails mastodon:config:schema > mastodon-config.schema.json'
        exit 1
      end
    end
  end
end
