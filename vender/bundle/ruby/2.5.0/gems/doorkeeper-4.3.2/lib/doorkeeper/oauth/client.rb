require 'doorkeeper/oauth/client/credentials'

module Doorkeeper
  module OAuth
    class Client
      attr_accessor :application

      delegate :id, :name, :uid, :redirect_uri, :scopes, to: :@application

      def initialize(application)
        @application = application
      end

      def self.find(uid, method = Application.method(:by_uid))
        if (application = method.call(uid))
          new(application)
        end
      end

      def self.authenticate(credentials, method = Application.method(:by_uid_and_secret))
        return false if credentials.blank?

        if (application = method.call(credentials.uid, credentials.secret))
          new(application)
        end
      end
    end
  end
end
