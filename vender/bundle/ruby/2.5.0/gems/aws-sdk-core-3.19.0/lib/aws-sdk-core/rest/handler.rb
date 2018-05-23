module Aws
  # @api private
  module Rest
    class Handler < Seahorse::Client::Handler

      def call(context)
        Rest::Request::Builder.new.apply(context)
        resp = @handler.call(context)
        resp.on(200..299) { |response| Response::Parser.new.apply(response) }
        resp.on(200..599) { |response| apply_request_id(context) }
        resp
      end

      private

      def apply_request_id(context)
        h = context.http_response.headers
        context[:request_id] = h['x-amz-request-id'] || h['x-amzn-requestid']
      end

    end
  end
end
