module Rack
  module Test
    class MockDigestRequest # :nodoc:
      def initialize(params)
        @params = params
      end

      def method_missing(sym)
        if @params.key? k = sym.to_s
          return @params[k]
        end

        super
      end

      def method
        @params['method']
      end

      def response(password)
        Rack::Auth::Digest::MD5.new(nil).send :digest, self, password
      end
    end
  end
end
