module Webpush
  class Error < RuntimeError; end

  class ConfigurationError < Error; end

  class ResponseError < Error;
    attr_reader :response, :host

    def initialize(response, host)
      @response = response
      @host = host
      super "host: #{host}, #{@response.inspect}\nbody:\n#{@response.body}"
    end
  end

  class InvalidSubscription < ResponseError; end

  class ExpiredSubscription < ResponseError; end

  class PayloadTooLarge < ResponseError; end

  class TooManyRequests < ResponseError; end
end
