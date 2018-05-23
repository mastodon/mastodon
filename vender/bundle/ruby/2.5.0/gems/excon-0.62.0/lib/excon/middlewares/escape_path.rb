# frozen_string_literal: true
module Excon
  module Middleware
    class EscapePath < Excon::Middleware::Base
      def request_call(datum)
        # make sure path is encoded, prevent double encoding
        datum[:path] = Excon::Utils.escape_uri(Excon::Utils.unescape_uri(datum[:path]))
        @stack.request_call(datum)
      end
    end
  end
end
