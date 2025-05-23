# frozen_string_literal: true

require 'linzer/http/signature_feature'
require 'linzer/message/adapter/http_gem/response'

module Linzer::Message::Adapter
  module ActionDispatch
    class Response < Linzer::Message::Adapter::Abstract
      def initialize(operation, **_options) # rubocop:disable Lint/MissingSuper
        @operation = operation
      end

      def header(name)
        @operation.headers[name]
      end

      def attach!(signature)
        signature.to_h.each { |h, v| @operation.headers[h] = v }
      end

      # Incomplete, but sufficient for FASP
      def [](field_name)
        return @operation.status if field_name == '@status'

        @operation.headers[field_name]
      end
    end
  end
end

Linzer::Message.register_adapter(HTTP::Response, Linzer::Message::Adapter::HTTPGem::Response)
Linzer::Message.register_adapter(ActionDispatch::Response, Linzer::Message::Adapter::ActionDispatch::Response)
