# frozen_string_literal: true

module Elasticsearch
  module ClientExtensions
    def verify_elasticsearch(*args, &block)
      @transport.perform_request(*args, &block).tap do
        @verified = true
      end
    end
  end
end

Elasticsearch::Client.prepend(Elasticsearch::ClientExtensions)
