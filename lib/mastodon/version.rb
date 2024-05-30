# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def major
      4
    end

    def minor
      3
    end

    def patch
      0
    end

    def default_prerelease
      'alpha.4'
    end

    def prerelease
      ENV['MASTODON_VERSION_PRERELEASE'].presence || default_prerelease
    end

    def build_metadata
      ['glitch', ENV.fetch('MASTODON_VERSION_METADATA', nil)].compact_blank.join('.')
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

    def repository
      ENV.fetch('GITHUB_REPOSITORY', 'glitch-soc/mastodon')
    end

    def source_base_url
      ENV.fetch('SOURCE_BASE_URL', "https://github.com/#{repository}")
    end

    # specify git tag or commit hash here
    def source_tag
      ENV.fetch('SOURCE_TAG', nil)
    end

    def source_url
      if source_tag
        "#{source_base_url}/tree/#{source_tag}"
      else
        source_base_url
      end
    end

    def user_agent
      @user_agent ||= "#{HTTP::Request::USER_AGENT} (Mastodon/#{Version}; +http#{Rails.configuration.x.use_https ? 's' : ''}://#{Rails.configuration.x.web_domain}/)"
    end
  end
end
