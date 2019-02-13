# frozen_string_literal: true

module ExternalProofService
  def self.my_domain
    Rails.configuration.x.local_domain
  end

  def self.my_domain_displayed
    Setting.site_title
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
