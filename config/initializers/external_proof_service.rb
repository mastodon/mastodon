# frozen_string_literal: true

module ExternalProofService
  def self.my_domain
    'mastodon.social'
  end

  def self.my_domain_displayed
    my_domain.gsub('.', ' ').capitalize
  end

  module Keybase
    def self.base_url
      'https://keybase.io'
    end

    def self.my_contacts
      ["admin@#{ExternalProofService.my_domain}", "yournamehere@keybase"]
    end
  end
end
