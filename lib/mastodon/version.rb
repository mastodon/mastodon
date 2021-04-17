# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def major
      3
    end

    def minor
      1
    end

    def patch
      1
    end

    def flags
      ''
    end

    def suffix
      ''
    end

    def to_a
      [major, minor, patch].compact
    end

    def to_s
      [to_a.join('.'), flags, suffix].join
    end

    def repository
      ENV.fetch('GITHUB_REPOSITORY') { 'tootsuite/mastodon' }
    end

    def source_base_url
      ENV.fetch('SOURCE_BASE_URL') { "https://github.com/#{repository}" }
    end

    # specify git tag or commit hash here
    def source_tag
      ENV.fetch('SOURCE_TAG') { nil }
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
