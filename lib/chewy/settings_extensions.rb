# frozen_string_literal: true

module Chewy
  module SettingsExtensions
    def enabled?
      settings[:enabled]
    end
  end
end
