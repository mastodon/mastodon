# frozen_string_literal: true

require 'pathname'
require 'set'

module Mastodon
  module Configuration
    # Scans the Mastodon source tree for every *literal* environment variable
    # key that is read via ENV[], ENV.fetch(), ENV.key?(), or ENV.include?().
    #
    # Keys with dynamic names (e.g. ENV.fetch("#{prefix}REDIS_URL")) cannot be
    # statically determined and are therefore omitted; they must be documented
    # in the schema by the code that generates them.
    #
    # Usage:
    #   results = Mastodon::Configuration::EnvScanner.scan          # → Hash
    #   results['REDIS_HOST']  # => ["config/initializers/...", ...]
    module EnvScanner
      # Directories and individual files to scan, relative to the project root.
      SCAN_PATHS = %w[
        config
        lib/mastodon
        app/lib
        app/workers/scheduler
      ].freeze

      # Files/directories inside SCAN_PATHS to skip.
      EXCLUDE_PATHS = %w[
        lib/mastodon/configuration
        spec
        test
      ].freeze

      # Variables that are deliberately absent from the schema.
      #
      # Two categories:
      #   :deprecated – old names superseded by a documented replacement
      #   :internal   – framework, tooling, or dev-only vars that are not
      #                 meaningful Mastodon configuration knobs
      EXCLUDED_VARS = {
        # Deprecated aliases – document the canonical name instead
        'WHITELIST_MODE'          => :deprecated, # → LIMITED_FEDERATION_MODE
        'EMAIL_DOMAIN_BLACKLIST'  => :deprecated, # → EMAIL_DOMAIN_DENYLIST
        'EMAIL_DOMAIN_WHITELIST'  => :deprecated, # → EMAIL_DOMAIN_ALLOWLIST

        # Standard Rails / Rack / system variables
        'DATABASE_URL'            => :internal,
        'OTHER_DATABASE_URL'      => :internal,
        'RAILS_ENV'               => :internal,
        'RAILS_SERVE_STATIC_FILES' => :internal,
        'RACK_ENV'                => :internal,
        'BUNDLE_GEMFILE'          => :internal,
        'SECRET_KEY_BASE_DUMMY'   => :internal, # used only during asset pre-compilation
        'USER'                    => :internal,

        # Third-party gem internals
        'PGHERO_STATS_DATABASE_URL' => :internal,

        # Development / CI / test variables
        'CI'                      => :internal,
        'GITHUB_ACTIONS'          => :internal,
        'GITHUB_RSPEC'            => :internal,
        'BACKTRACE'               => :internal,
        'VAGRANT'                 => :internal,
        'HEROKU'                  => :internal,
        'REMOTE_DEV'              => :internal,
        'COVERAGE'                => :internal,
        'TEST_ENV_NUMBER'         => :internal,
        'VITE_DEV_SERVER_PUBLIC'  => :internal,
        'DISABLE_FORGERY_REQUEST_PROTECTION' => :internal,
        'ANNOTATERB_SKIP_ON_DB_TASKS'        => :internal,
        'FORCE_DEFAULT_LOCALE'               => :internal,
        'SKIP_POST_DEPLOYMENT_MIGRATIONS'    => :internal,
        'IGNORE_ALREADY_SET_SECRETS'         => :internal,
        'MIGRATION_IGNORE_INVALID_OTP_SECRET' => :internal,
        'RAILS_LOG_TO_STDOUT'                => :internal,
      }.freeze

      # Matches literal ENV key accesses; does NOT match interpolated keys.
      # Captures group 1 from ENV['KEY'] / ENV["KEY"],
      # or group 2 from ENV.fetch('KEY') / ENV.key?('KEY') / etc.
      LITERAL_KEY_PATTERN = /\bENV(?:\[['"]([A-Z][A-Z0-9_]*)["']\]|\.(?:fetch|key\?|include\?|has_key\?)\(\s*['"]([A-Z][A-Z0-9_]*)["'])/

      # Returns a Hash of { 'VAR_NAME' => ['relative/path', ...] } for every
      # literal ENV key found in SCAN_PATHS, excluding EXCLUDE_PATHS.
      # rubocop:disable Metrics/MethodLength
      def self.scan(root = nil)
        root = resolve_root(root)
        results = Hash.new { |h, k| h[k] = [] }

        each_file(root) do |abs_path|
          rel = abs_path.relative_path_from(root).to_s
          File.read(abs_path).scan(LITERAL_KEY_PATTERN) do |bracket_key, method_key|
            key = bracket_key || method_key
            results[key] << rel unless results[key].include?(rel)
          end
        end

        results
      end
      # rubocop:enable Metrics/MethodLength

      # Returns the subset of scan results whose keys are absent from the
      # schema *and* not in EXCLUDED_VARS.  These are the undocumented vars
      # that the lint task should report.
      def self.undocumented(root = nil)
        require_relative 'schema'
        schema_keys = Schema.generate['properties'].keys.to_set
        scan(root).reject { |key, _| schema_keys.include?(key) || EXCLUDED_VARS.key?(key) }
      end

      # ---------------------------------------------------------------------------

      def self.resolve_root(root)
        return Pathname.new(root) if root

        # Walk up from this file to find the Rails root (the directory that
        # contains Gemfile), so this module works without Rails being loaded.
        Pathname.new(__dir__).ascend do |dir|
          return dir if dir.join('Gemfile').exist?
        end

        raise 'Cannot determine project root: no Gemfile found in parent directories'
      end
      private_class_method :resolve_root

      def self.each_file(root)
        SCAN_PATHS.each do |scan_path|
          full = root.join(scan_path)
          next unless full.exist?

          candidates = full.directory? ? full.glob('**/*.{rb,erb,yml}') : [full]
          candidates.each do |path|
            next if EXCLUDE_PATHS.any? { |ex| path.to_s.include?(root.join(ex).to_s) }
            next unless path.file?

            yield path
          end
        end
      end
      private_class_method :each_file
    end
  end
end
