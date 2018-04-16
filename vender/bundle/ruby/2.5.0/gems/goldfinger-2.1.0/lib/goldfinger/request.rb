# frozen_string_literal: true

require 'http'
require 'addressable'

module Goldfinger
  class Request
    def initialize(request_method, path, options = {})
      @request_method = request_method
      @uri            = Addressable::URI.parse(path)
      @options        = options
    end

    def perform
      http_client.request(@request_method, @uri.to_s, @options)
    end

    private

    def http_client
      HTTP.timeout(:per_operation, write: 60, connect: 20, read: 60).follow
    end
  end
end
