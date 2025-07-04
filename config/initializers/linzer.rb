# frozen_string_literal: true

require 'linzer/http/signature_feature'
require 'linzer/message/adapter/http_gem/response'

module Linzer::Message::Adapter
  module ActionDispatch
    class Response < Linzer::Message::Adapter::HTTPGem::Response
    end
  end
end

Linzer::Message.register_adapter(HTTP::Response, Linzer::Message::Adapter::HTTPGem::Response)
Linzer::Message.register_adapter(ActionDispatch::Response, Linzer::Message::Adapter::ActionDispatch::Response)
