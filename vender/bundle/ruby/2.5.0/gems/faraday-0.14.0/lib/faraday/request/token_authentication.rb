module Faraday
  class Request::TokenAuthentication < Request.load_middleware(:authorization)
    # Public
    def self.header(token, options = nil)
      options ||= {}
      options[:token] = token
      super(:Token, options)
    end

    def initialize(app, token, options = nil)
      super(app, token, options)
    end
  end
end

