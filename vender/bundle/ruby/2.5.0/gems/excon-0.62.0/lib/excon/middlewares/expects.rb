# frozen_string_literal: true
module Excon
  module Middleware
    class Expects < Excon::Middleware::Base
      def response_call(datum)
        if datum.has_key?(:expects) && ![*datum[:expects]].include?(datum[:response][:status])
          raise(
            Excon::Errors.status_error(
              datum.reject {|key,value| key == :response},
              Excon::Response.new(datum[:response])
            )
          )
        else
          @stack.response_call(datum)
        end
      end
    end
  end
end
