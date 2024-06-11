# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def major
      4
    end

    def minor
      4
    end

    def patch
      0
    end

    def default_prerelease
      'alpha.1'
    end

    def prerelease
      configuration.version[:prerelease] || default_prerelease
    end

    def build_metadata
      configuration.version[:metadata]
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
        mastodon: 2,
      }
    end

    def repository
      configuration.source[:repository]
    end

    def source_base_url
      configuration.source[:base_url] || "https://github.com/#{repository}"
    end

    # specify git tag or commit hash here
    def source_tag
      configuration.source[:tag]
    end

    def source_url
      if source_tag
        "#{source_base_url}/tree/#{source_tag}"
      else
        source_base_url
      end
    end

    def user_agent
      @user_agent ||= "Mastodon/#{Version} (#{HTTP::Request::USER_AGENT}; +http#{Rails.configuration.x.use_https ? 's' : ''}://#{Rails.configuration.x.web_domain}/)"
    end

    def configuration
      Rails.configuration.x.mastodon
    end
  end
end
