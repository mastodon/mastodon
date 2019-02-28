# frozen_string_literal: true

module ExternalProofService
  def self.my_domain
    Rails.env.development? ? 'mastodon.social' : Rails.configuration.x.local_domain
  end

  def self.my_domain_displayed
    Setting.site_title
  end

  module Keybase
    def self.base_url
      ENV["KEYBASE_BASE_URL"] || 'https://keybase.io'
    end
  end
end
