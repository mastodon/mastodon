# frozen_string_literal: true

require_relative '../mastodon/configuration/schema'
require_relative '../mastodon/configuration/env_scanner'
require_relative '../mastodon/configuration/docs_generator'

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
      Generate Hugo-flavored Markdown for content/en/admin/config.md from the JSON schema.

      Reads `mastodon-config.schema.json` (or the path supplied as an argument)
      and emits Markdown to stdout.  The docs structure is driven by the
      `x-docs-layout` key, which is populated from the `docs:` block in
      `lib/mastodon/configuration/annotations.yml`.

      Usage:
        bundle exec rails mastodon:config:docs
        bundle exec rails mastodon:config:docs > /path/to/documentation/content/en/admin/config.md
    DESC
    task :docs, [:schema_path] do |_t, args|
      require 'json'
      path   = args[:schema_path] || File.expand_path('../../../mastodon-config.schema.json', __dir__)
      schema = JSON.parse(File.read(path))
      puts Mastodon::Configuration::DocsGenerator.render(schema)
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
