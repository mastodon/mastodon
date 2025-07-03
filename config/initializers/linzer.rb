# frozen_string_literal: true

require 'linzer/http/signature_feature'
require 'linzer/message/adapter/http_gem/response'

module Linzer::Message::Adapter
  module ActionDispatch
    class Response < Linzer::Message::Adapter::Generic::Response
      private

      # Incomplete, but sufficient for FASP
      def derived(name)
        case name.value
        when '@status' then @operation.status
        end
      end
    end
  end
end

Linzer::Message.register_adapter(HTTP::Response, Linzer::Message::Adapter::HTTPGem::Response)
Linzer::Message.register_adapter(ActionDispatch::Response, Linzer::Message::Adapter::ActionDispatch::Response)
