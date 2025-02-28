# frozen_string_literal: true

module Mastodon
  module Feature
    FASP_ENABLED = ENV['EXPERIMENTAL_FASP'] == 'true'

    def self.fasp_enabled?
      FASP_ENABLED
    end
  end
end
