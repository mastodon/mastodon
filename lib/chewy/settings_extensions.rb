# frozen_string_literal: true

module Chewy
  module SettingsExtensions
    def enabled?
      settings[:enabled]
    end
  end
end

Chewy.extend(Chewy::SettingsExtensions)
