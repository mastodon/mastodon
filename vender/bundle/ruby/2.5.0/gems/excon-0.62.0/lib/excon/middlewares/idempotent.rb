# frozen_string_literal: true
module Excon
  module Middleware
    class Idempotent < Excon::Middleware::Base
      def error_call(datum)
        if datum[:idempotent]
          if datum.has_key?(:request_block)
            if datum[:request_block].respond_to?(:rewind)
              datum[:request_block].rewind
            else
              Excon.display_warning('Excon requests with a :request_block must implement #rewind in order to be :idempotent.')
              datum[:idempotent] = false
            end
          end
          if datum.has_key?(:response_block) && datum[:response_block].respond_to?(:rewind)
            datum[:response_block].rewind
          end
          if datum.has_key?(:pipeline)
            Excon.display_warning("Excon requests can not be :idempotent when pipelining.")
            datum[:idempotent] = false
          end
        end

        if datum[:idempotent] && [Excon::Errors::Timeout, Excon::Errors::SocketError,
            Excon::Errors::HTTPStatusError].any? {|ex| datum[:error].kind_of?(ex) } && datum[:retries_remaining] > 1

          sleep(datum[:retry_interval]) if datum[:retry_interval]

          # reduces remaining retries, reset connection, and restart request_call
          datum[:retries_remaining] -= 1
          connection = datum.delete(:connection)
          datum.reject! {|key, _| !Excon::VALID_REQUEST_KEYS.include?(key) }
          connection.request(datum)
        else
          @stack.error_call(datum)
        end
      end
    end
  end
end
