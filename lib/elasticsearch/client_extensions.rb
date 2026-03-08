# frozen_string_literal: true

module Elasticsearch
  module ClientExtensions
    def initialize(arguments = {}, &block)
      super

      @verified = true
    end
  end
end

Elasticsearch::Client.prepend(Elasticsearch::ClientExtensions)
