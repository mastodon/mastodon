module Faraday
  class Request::Authorization < Faraday::Middleware
    KEY = "Authorization".freeze unless defined? KEY

    # Public
    def self.header(type, token)
      case token
      when String, Symbol
        "#{type} #{token}"
      when Hash
        build_hash(type.to_s, token)
      else
        raise ArgumentError, "Can't build an Authorization #{type} header from #{token.inspect}"
      end
    end

    # Internal
    def self.build_hash(type, hash)
      comma = ", "
      values = []
      hash.each do |key, value|
        values << "#{key}=#{value.to_s.inspect}"
      end
      "#{type} #{values * comma}"
    end

    def initialize(app, type, token)
      @header_value = self.class.header(type, token)
      super(app)
    end

    # Public
    def call(env)
      unless env.request_headers[KEY]
        env.request_headers[KEY] = @header_value
      end
      @app.call(env)
    end
  end
end

