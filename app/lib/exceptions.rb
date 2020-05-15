# frozen_string_literal: true

module Mastodon
  class Error < StandardError; end
  class NotPermittedError < Error; end
  class ValidationError < Error; end
  class HostValidationError < ValidationError; end
  class LengthValidationError < ValidationError; end
  class DimensionsValidationError < ValidationError; end
  class RaceConditionError < Error; end
  class RateLimitExceededError < Error; end

  class UnexpectedResponseError < Error
    def initialize(response = nil)
      if response.respond_to? :uri
        super("#{response.uri} returned code #{response.code}")
      else
        super
      end
    end
  end
end
