require 'active_support'
require 'active_support/message_verifier'

class GlobalID
  class Verifier < ActiveSupport::MessageVerifier
    private
      def encode(data)
        ::Base64.urlsafe_encode64(data)
      end

      def decode(data)
        ::Base64.urlsafe_decode64(data)
      end
  end
end
