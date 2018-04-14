module Aws
  module Json
    class Handler < Seahorse::Client::Handler

      CONTENT_TYPE = 'application/x-amz-json-%s'

      # @param [Seahorse::Client::RequestContext] context
      # @return [Seahorse::Client::Response]
      def call(context)
        build_request(context)
        response = @handler.call(context)
        response.on(200..299) { |resp| parse_response(resp) }
        response.on(200..599) { |resp| apply_request_id(context) }
        response
      end

      private

      def build_request(context)
        context.http_request.http_method = 'POST'
        context.http_request.headers['Content-Type'] = content_type(context)
        context.http_request.headers['X-Amz-Target'] = target(context)
        context.http_request.body = build_body(context)
      end

      def build_body(context)
        if simple_json?(context)
          Json.dump(context.params)
        else
          Builder.new(context.operation.input).serialize(context.params)
        end
      end

      def parse_response(response)
        response.data = parse_body(response.context)
      end

      def parse_body(context)
        if simple_json?(context)
          Json.load(context.http_response.body_contents)
        elsif rules = context.operation.output
          json = context.http_response.body_contents
          Parser.new(rules).parse(json == '' ? '{}' : json)
        else
          EmptyStructure.new
        end
      end

      def content_type(context)
        CONTENT_TYPE % [context.config.api.metadata['jsonVersion']]
      end

      def target(context)
        prefix = context.config.api.metadata['targetPrefix']
        "#{prefix}.#{context.operation.name}"
      end

      def apply_request_id(context)
        context[:request_id] = context.http_response.headers['x-amzn-requestid']
      end

      def simple_json?(context)
        context.config.simple_json
      end

    end
  end
end
