# frozen_string_literal: true

module Mastodon
  module Source
    module_function

    def base_url
      'https://github.com/tootsuite/mastodon'
    end

    # specify Mastodon::Version.to_s, tag, or commit hash here
    def tag
      nil
    end

    def url
      if tag
        "#{base_url}/tree/#{tag}"
      else
        base_url
      end
    end
  end
end
