# frozen_string_literal: true

module Devise
  module TestHelpers
    def self.included(base)
      base.class_eval do
        ActiveSupport::Deprecation.warn <<-DEPRECATION.strip_heredoc
          [Devise] including `Devise::TestHelpers` is deprecated and will be removed from Devise.
          For controller tests, please include `Devise::Test::ControllerHelpers` instead.
        DEPRECATION
        include Devise::Test::ControllerHelpers
      end
    end
  end
end
