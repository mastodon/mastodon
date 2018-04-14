# frozen_string_literal: true
module Excon
  module Middleware
    class Mock < Excon::Middleware::Base
      def request_call(datum)
        if datum[:mock]
          # convert File/Tempfile body to string before matching:
          if datum[:body].respond_to?(:read)
           if datum[:body].respond_to?(:binmode)
             datum[:body].binmode
           end
           if datum[:body].respond_to?(:rewind)
             datum[:body].rewind
           end
           datum[:body] = datum[:body].read
          elsif !datum[:body].nil? && !datum[:body].is_a?(String)
            raise Excon::Errors::InvalidStub.new("Request body should be a string or an IO object. #{datum[:body].class} provided")
          end

          if stub = Excon.stub_for(datum)
            datum[:response] = {
              :body       => '',
              :headers    => {},
              :status     => 200,
              :remote_ip  => '127.0.0.1'
            }

            stub_datum = case stub.last
            when Proc
              stub.last.call(datum)
            else
              stub.last
            end

            datum[:response].merge!(stub_datum.reject {|key,value| key == :headers})
            if stub_datum.has_key?(:headers)
              datum[:response][:headers].merge!(stub_datum[:headers])
            end
          elsif datum[:allow_unstubbed_requests] != true
            # if we reach here no stubs matched
            message = StringIO.new
            message.puts('no stubs matched')
            Excon::PrettyPrinter.pp(message, datum)
            raise(Excon::Errors::StubNotFound.new(message.string))
          end
        end

        @stack.request_call(datum)
      end
    end
  end
end
