# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def major
      4
    end

    def minor
      6
    end

    def patch
      0
    end

    def default_prerelease
      'alpha.4'
    end

    def prerelease
      version_configuration[:prerelease].presence || default_prerelease
    end

    def build_metadata
      version_configuration[:metadata]
    end

    def to_a
      [major, minor, patch].compact
    end

    def to_s
      components = [to_a.join('.')]
      components << "-#{prerelease}" if prerelease.present?
      components << "+#{build_metadata}" if build_metadata.present?
      components.join
    end

    def gem_version
      @gem_version ||= Gem::Version.new(to_s.split('+')[0])
    end

    def api_versions
      {
        mastodon: 7,
      }
    end

    def repository
      source_configuration[:repository]
    end

    def source_base_url
      source_configuration[:base_url] || "https://github.com/#{repository}"
    end

    # specify git tag or commit hash here
    def source_tag
      source_configuration[:tag]
    end

    def source_url
      if source_tag
        "#{source_base_url}/tree/#{source_tag}"
      else
        source_base_url
      end
    end

    def source_commit
      ENV.fetch('SOURCE_COMMIT', nil)
    end

    def user_agent
      @user_agent ||= "Mastodon/#{Version} (#{HTTP::Request::USER_AGENT}; +http#{'s' if Rails.configuration.x.use_https}://#{Rails.configuration.x.web_domain}/)"
    end

    def version_configuration
      mastodon_configuration.version
    end

    def source_configuration
      mastodon_configuration.source
    end

    def mastodon_configuration
      Rails.configuration.x.mastodon
    end
  end
end
