# frozen_string_literal: true

module Devise
  module Models
    # Registerable is responsible for everything related to registering a new
    # resource (ie user sign up).
    module Registerable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        []
      end

      module ClassMethods
        # A convenience method that receives both parameters and session to
        # initialize a user. This can be used by OAuth, for example, to send
        # in the user token and be stored on initialization.
        #
        # By default discards all information sent by the session by calling
        # new with params.
        def new_with_session(params, session)
          new(params)
        end
      end
    end
  end
end
