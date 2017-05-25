# frozen_string_literal: true

module Settings
  module Extend
    extend ActiveSupport::Concern

    def settings
      @settings ||= ScopedSettings.new(self)
    end
  end
end
