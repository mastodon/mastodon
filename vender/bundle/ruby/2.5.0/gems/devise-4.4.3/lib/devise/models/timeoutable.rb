# frozen_string_literal: true

require 'devise/hooks/timeoutable'

module Devise
  module Models
    # Timeoutable takes care of verifying whether a user session has already
    # expired or not. When a session expires after the configured time, the user
    # will be asked for credentials again, it means, they will be redirected
    # to the sign in page.
    #
    # == Options
    #
    # Timeoutable adds the following options to devise_for:
    #
    #   * +timeout_in+: the interval to timeout the user session without activity.
    #
    # == Examples
    #
    #   user.timedout?(30.minutes.ago)
    #
    module Timeoutable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        []
      end

      # Checks whether the user session has expired based on configured time.
      def timedout?(last_access)
        !timeout_in.nil? && last_access && last_access <= timeout_in.ago
      end

      def timeout_in
        self.class.timeout_in
      end

      private

      module ClassMethods
        Devise::Models.config(self, :timeout_in)
      end
    end
  end
end
