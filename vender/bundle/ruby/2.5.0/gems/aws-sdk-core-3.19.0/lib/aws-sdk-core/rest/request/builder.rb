module Aws
  module Rest
    module Request
      class Builder

        def apply(context)
          populate_http_method(context)
          populate_endpoint(context)
          populate_headers(context)
          populate_body(context)
        end

        private

        def populate_http_method(context)
          context.http_request.http_method = context.operation.http_method
        end

        def populate_endpoint(context)
          context.http_request.endpoint = Endpoint.new(
            context.operation.input,
            context.operation.http_request_uri,
          ).uri(context.http_request.endpoint, context.params)
        end

        def populate_headers(context)
          headers = Headers.new(context.operation.input)
          headers.apply(context.http_request, context.params)
        end

        def populate_body(context)
          Body.new(
            serializer_class(context),
            context.operation.input
          ).apply(context.http_request, context.params)
        end

        def serializer_class(context)
          protocol = context.config.api.metadata['protocol']
          case protocol
          when 'rest-xml' then Xml::Builder
          when 'rest-json' then Json::Builder
          when 'api-gateway' then Json::Builder
          else raise "unsupported protocol #{protocol}"
          end
        end

      end
    end
  end
end
