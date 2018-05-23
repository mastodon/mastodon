# frozen_string_literal: true

module Goldfinger
  module Utils
    def perform_get(path, options = {})
      perform_request(:get, path, options)
    end

    def perform_request(request_method, path, options = {})
      Goldfinger::Request.new(request_method, path, options).perform
    end
  end
end
