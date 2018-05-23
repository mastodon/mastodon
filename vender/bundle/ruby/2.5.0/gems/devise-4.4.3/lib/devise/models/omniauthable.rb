# frozen_string_literal: true

require 'devise/omniauth'

module Devise
  module Models
    # Adds OmniAuth support to your model.
    #
    # == Options
    #
    # Oauthable adds the following options to devise_for:
    #
    #   * +omniauth_providers+: Which providers are available to this model. It expects an array:
    #
    #       devise_for :database_authenticatable, :omniauthable, omniauth_providers: [:twitter]
    #
    module Omniauthable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        []
      end

      module ClassMethods
        Devise::Models.config(self, :omniauth_providers)
      end
    end
  end
end
