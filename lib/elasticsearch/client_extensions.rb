# frozen_string_literal: true

module Elasticsearch
  module ClientExtensions
    def verify_elasticsearch
      @verified = true
    end
  end
end

Elasticsearch::Client.prepend(Elasticsearch::ClientExtensions)
