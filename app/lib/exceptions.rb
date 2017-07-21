# frozen_string_literal: true

module Mastodon
  class Error < StandardError; end
  class NotPermittedError < Error; end
  class ValidationError < Error; end
  class RaceConditionError < Error; end

  class UnexpectedResponseError < Error
    def initialize(response = nil)
      @response = response
    end

    def to_s
      "#{@response.uri} returned code #{@response.code}"
    end
  end
end
