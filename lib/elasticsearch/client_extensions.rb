# frozen_string_literal: true

module Elasticsearch
  module ClientExtensions
    def verify_elasticsearch(*_args, &_block)
      @verified = true
    end
  end
end

Elasticsearch::Client.prepend(Elasticsearch::ClientExtensions)
